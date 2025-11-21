<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Major extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'code',
        'name',
        'description',
        'department',
        'duration_years',
        'total_credits_required',
        'degree_type',
        'is_active',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'duration_years' => 'integer',
        'total_credits_required' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Get the students enrolled in this major.
     */
    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }

    /**
     * Get all courses linked to this major through program_courses.
     */
    public function courses(): BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'program_courses')
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
     * Get courses for a specific year level.
     */
    public function getCoursesByYear(int $yearLevel): BelongsToMany
    {
        return $this->courses()->wherePivot('year_level', $yearLevel);
    }

    /**
     * Get courses for a specific year and semester.
     */
    public function getCoursesByYearAndSemester(int $yearLevel, int $semester): BelongsToMany
    {
        return $this->courses()
            ->wherePivot('year_level', $yearLevel)
            ->wherePivot('semester', $semester);
    }

    /**
     * Get required courses.
     */
    public function getRequiredCourses(): BelongsToMany
    {
        return $this->courses()->wherePivot('is_required', true);
    }

    /**
     * Get elective courses.
     */
    public function getElectiveCourses(): BelongsToMany
    {
        return $this->courses()->wherePivot('is_required', false);
    }

    /**
     * Get the curriculum structure organized by year and semester.
     */
    public function getCurriculum(): array
    {
        $curriculum = [];
        
        for ($year = 1; $year <= $this->duration_years; $year++) {
            $curriculum["Year {$year}"] = [
                'Semester 1' => $this->getCoursesByYearAndSemester($year, 1)->get(),
                'Semester 2' => $this->getCoursesByYearAndSemester($year, 2)->get(),
            ];
        }
        
        return $curriculum;
    }

    /**
     * Get total credits for a specific year.
     */
    public function getCreditsByYear(int $yearLevel): int
    {
        return $this->getCoursesByYear($yearLevel)->sum('credits');
    }
}
