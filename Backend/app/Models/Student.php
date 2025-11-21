<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Student extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'student_id',
        'user_id',
        'major_id',
        'name',
        'email',
        'avatar_url',
        'year_level',
        'gpa',
        'credits_taken',
        'total_credits',
        'tuition_fees',
        'academic_year',
        'class',
    ];

    protected $casts = [
        'major_id' => 'integer',
        'year_level' => 'integer',
        'gpa' => 'decimal:2',
        'credits_taken' => 'integer',
        'total_credits' => 'integer',
        'tuition_fees' => 'decimal:3',
    ];

    protected $appends = [
        'credits_progress_percentage',
        'outstanding_balance',
    ];

    /**
     * Get the user associated with the student.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the major (program) the student is enrolled in.
     */
    public function major(): BelongsTo
    {
        return $this->belongsTo(Major::class);
    }

    /**
     * Get student courses (enrollments with grades).
     */
    public function studentCourses()
    {
        return $this->hasMany(StudentCourse::class);
    }

    /**
     * Get attendance records.
     */
    public function attendances()
    {
        return $this->hasMany(StudentAttendance::class);
    }

    /**
     * Get the courses the student is enrolled in.
     */
    public function courses(): BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'student_courses')
            ->withPivot([
                'program_course_id',
                'year_taken',
                'semester_taken',
                'cc_score',
                'ds_score',
                'exam_score',
                'cc_weight',
                'ds_weight',
                'exam_weight',
                'final_grade',
                'letter_grade',
                'status'
            ])
            ->withTimestamps();
    }

    /**
     * Get all enrolled courses (active enrollment).
     */
    public function enrolledCourses(): BelongsToMany
    {
        return $this->courses()->wherePivot('status', 'enrolled');
    }

    /**
     * Get all attendance records.
     */
    public function attendanceRecords(): HasMany
    {
        return $this->hasMany(AttendanceRecord::class);
    }

    /**
     * Get all bills for the student.
     */
    public function bills(): HasMany
    {
        return $this->hasMany(Bill::class);
    }

    /**
     * Get all payments made by the student.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Get all event registrations.
     */
    public function eventRegistrations(): HasMany
    {
        return $this->hasMany(EventRegistration::class);
    }

    /**
     * Get events the student is registered for.
     */
    public function events(): BelongsToMany
    {
        return $this->belongsToMany(Event::class, 'event_registrations')
            ->withPivot(['registered_at', 'status'])
            ->withTimestamps();
    }

    /**
     * Get all club memberships.
     */
    public function clubMemberships(): HasMany
    {
        return $this->hasMany(ClubMembership::class);
    }

    /**
     * Get clubs the student is a member of.
     */
    public function clubs(): BelongsToMany
    {
        return $this->belongsToMany(Club::class, 'club_memberships')
            ->withPivot(['join_date', 'role', 'status'])
            ->withTimestamps();
    }

    /**
     * Get credits progress percentage.
     */
    public function getCreditsProgressPercentageAttribute(): float
    {
        if ($this->total_credits == 0) {
            return 0;
        }
        return round(($this->credits_taken / $this->total_credits) * 100, 2);
    }

    /**
     * Get outstanding balance (pending bills).
     */
    public function getOutstandingBalanceAttribute(): float
    {
        return $this->bills()->where('status', 'pending')->sum('amount');
    }

    /**
     * Calculate overall attendance percentage.
     */
    public function getAttendancePercentage(): float
    {
        $totalRecords = $this->attendanceRecords()->count();
        if ($totalRecords == 0) {
            return 0;
        }
        $presentRecords = $this->attendanceRecords()->where('status', 'present')->count();
        return round(($presentRecords / $totalRecords) * 100, 2);
    }

    /**
     * Get current semester courses.
     */
    public function getCurrentSemesterCourses()
    {
        return $this->enrolledCourses()
            ->whereHas('academicCalendar', function ($query) {
                $query->where('status', 'active');
            })
            ->get();
    }

    /**
     * Get all grades across all years (full transcript).
     */
    public function getFullTranscript()
    {
        return $this->studentCourses()
            ->with(['course', 'programCourse'])
            ->orderBy('year_taken')
            ->orderBy('semester_taken')
            ->get();
    }

    /**
     * Get transcript for a specific year.
     */
    public function getTranscriptByYear(int $year)
    {
        return $this->studentCourses()
            ->with(['course', 'programCourse'])
            ->where('year_taken', $year)
            ->orderBy('semester_taken')
            ->get();
    }

    /**
     * Get transcript for a specific year and semester.
     */
    public function getTranscriptByYearAndSemester(int $year, int $semester)
    {
        return $this->studentCourses()
            ->with(['course', 'programCourse'])
            ->where('year_taken', $year)
            ->where('semester_taken', $semester)
            ->get();
    }

    /**
     * Calculate GPA across all completed courses.
     */
    public function calculateOverallGPA(): float
    {
        $completedCourses = $this->studentCourses()
            ->where('status', 'completed')
            ->whereNotNull('final_grade')
            ->with('course')
            ->get();

        if ($completedCourses->isEmpty()) {
            return 0.0;
        }

        $totalPoints = 0;
        $totalCredits = 0;

        foreach ($completedCourses as $enrollment) {
            $gradePoint = $enrollment->getGradePoint();
            $credits = $enrollment->course->credits;
            $totalPoints += $gradePoint * $credits;
            $totalCredits += $credits;
        }

        return $totalCredits > 0 ? round($totalPoints / $totalCredits, 2) : 0.0;
    }

    /**
     * Calculate GPA for a specific year.
     */
    public function calculateYearGPA(int $year): float
    {
        $courses = $this->studentCourses()
            ->where('year_taken', $year)
            ->where('status', 'completed')
            ->whereNotNull('final_grade')
            ->with('course')
            ->get();

        if ($courses->isEmpty()) {
            return 0.0;
        }

        $totalPoints = 0;
        $totalCredits = 0;

        foreach ($courses as $enrollment) {
            $gradePoint = $enrollment->getGradePoint();
            $credits = $enrollment->course->credits;
            $totalPoints += $gradePoint * $credits;
            $totalCredits += $credits;
        }

        return $totalCredits > 0 ? round($totalPoints / $totalCredits, 2) : 0.0;
    }

    /**
     * Get courses available for the student's current year level.
     */
    public function getAvailableCourses()
    {
        return $this->major->getCoursesByYear($this->year_level)->get();
    }

    /**
     * Get required courses for student's current year that aren't completed.
     */
    public function getRemainingRequiredCourses()
    {
        $completedCourseIds = $this->studentCourses()
            ->where('status', 'completed')
            ->pluck('course_id')
            ->toArray();

        return $this->major->getRequiredCourses()
            ->whereNotIn('courses.id', $completedCourseIds)
            ->get();
    }

    /**
     * Get all teachers for student's current year courses.
     */
    public function getCurrentYearTeachers()
    {
        return Teacher::whereHas('programCourses', function ($query) {
            $query->where('major_id', $this->major_id)
                ->where('year_level', $this->year_level);
        })->with(['programCourses' => function ($query) {
            $query->where('major_id', $this->major_id)
                ->where('year_level', $this->year_level)
                ->with('course');
        }])->get();
    }

    /**
     * Get attendance for a specific course.
     */
    public function getCourseAttendance(int $courseId)
    {
        $scheduleIds = Schedule::whereHas('programCourse', function ($query) use ($courseId) {
            $query->where('course_id', $courseId);
        })->pluck('id');

        $total = $this->attendances()->whereIn('schedule_id', $scheduleIds)->count();
        $present = $this->attendances()
            ->whereIn('schedule_id', $scheduleIds)
            ->whereIn('status', ['present', 'late'])
            ->count();

        return [
            'total' => $total,
            'present' => $present,
            'percentage' => $total > 0 ? round(($present / $total) * 100, 2) : 0,
        ];
    }
}

