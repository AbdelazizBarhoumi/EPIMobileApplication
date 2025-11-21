<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Teacher extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'teacher_id',
        'name',
        'email',
        'phone',
        'department',
        'title',
        'specialization',
        'bio',
        'office_location',
        'office_hours',
        'is_active',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'office_hours' => 'array',
        'is_active' => 'boolean',
    ];

    /**
     * Get the user account.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the program courses taught by this teacher.
     */
    public function programCourses(): HasMany
    {
        return $this->hasMany(ProgramCourse::class);
    }

    /**
     * Get attendance records marked by this teacher.
     */
    public function attendanceRecords(): HasMany
    {
        return $this->hasMany(StudentAttendance::class, 'marked_by');
    }

    /**
     * Get all courses taught by this teacher (through program courses).
     */
    public function courses()
    {
        return $this->hasManyThrough(
            Course::class,
            ProgramCourse::class,
            'teacher_id',
            'id',
            'id',
            'course_id'
        )->distinct();
    }

    /**
     * Get courses for a specific semester.
     */
    public function getCoursesForSemester(int $year, int $semester)
    {
        return $this->programCourses()
            ->where('year_level', $year)
            ->where('semester', $semester)
            ->with(['course', 'major', 'schedules'])
            ->get();
    }

    /**
     * Get all students taught by this teacher.
     */
    public function getStudents()
    {
        return Student::whereHas('studentCourses', function ($query) {
            $query->whereHas('programCourse', function ($q) {
                $q->where('teacher_id', $this->id);
            });
        })->distinct()->get();
    }

    /**
     * Get teaching schedule.
     */
    public function getSchedule()
    {
        return Schedule::whereHas('programCourse', function ($query) {
            $query->where('teacher_id', $this->id);
        })->with(['programCourse.course', 'programCourse.major', 'room'])
            ->orderBy('day_of_week')
            ->orderBy('time_slot')
            ->get();
    }
}
