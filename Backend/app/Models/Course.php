<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Course extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'course_code',
        'name',
        'description',
        'instructor',
        'credits',
        'schedule',
        'room',
        'academic_calendar_id',
    ];

    protected $casts = [
        'credits' => 'integer',
    ];

    /**
     * Get the academic calendar this course belongs to.
     */
    public function academicCalendar(): BelongsTo
    {
        return $this->belongsTo(AcademicCalendar::class);
    }

    /**
     * Get all majors this course belongs to through program_courses.
     */
    public function majors(): BelongsToMany
    {
        return $this->belongsToMany(Major::class, 'program_courses')
            ->withPivot([
                'year_level',
                'semester',
                'is_required',
                'cc_weight',
                'ds_weight',
                'exam_weight',
            ])
            ->withTimestamps();
    }

    /**
     * Get all student enrollments for this course.
     */
    public function studentCourses(): HasMany
    {
        return $this->hasMany(StudentCourse::class);
    }

    /**
     * Get students enrolled in this course.
     */
    public function students(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'student_courses')
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
     * Get attendance records for this course.
     */
    public function attendanceRecords(): HasMany
    {
        return $this->hasMany(AttendanceRecord::class);
    }

    /**
     * Get schedules through program courses.
     */
    public function schedules()
    {
        return $this->hasManyThrough(
            Schedule::class,
            ProgramCourse::class,
            'course_id',      // Foreign key on program_courses table
            'program_course_id', // Foreign key on schedules table
            'id',             // Local key on courses table
            'id'              // Local key on program_courses table
        );
    }

    /**
     * Get enrolled students count.
     */
    public function getEnrolledCountAttribute(): int
    {
        return $this->students()->wherePivot('status', 'enrolled')->count();
    }

    /**
     * Get average grade for this course.
     */
    public function getAverageGrade(): ?float
    {
        $average = $this->students()
            ->wherePivotNotNull('final_grade')
            ->avg('student_courses.final_grade');

        return $average ? round($average, 2) : null;
    }

    /**
     * Parse schedule to get days and time.
     */
    public function getScheduleDetails(): array
    {
        // Parse schedule like "Mon, Wed 10:00-11:30"
        $parts = explode(' ', $this->schedule);
        return [
            'days' => $parts[0] ?? '',
            'time' => $parts[1] ?? '',
        ];
    }
}
