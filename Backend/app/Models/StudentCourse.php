<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class StudentCourse extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'student_courses';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'student_id',
        'course_id',
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
        'status',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'year_taken' => 'integer',
        'semester_taken' => 'integer',
        'cc_score' => 'decimal:2',
        'ds_score' => 'decimal:2',
        'exam_score' => 'decimal:2',
        'cc_weight' => 'integer',
        'ds_weight' => 'integer',
        'exam_weight' => 'integer',
        'final_grade' => 'decimal:2',
    ];

    /**
     * The "booted" method of the model.
     */
    protected static function booted(): void
    {
        static::saving(function (StudentCourse $studentCourse) {
            $studentCourse->calculateFinalGrade();
        });
    }

    /**
     * Get the student that owns this enrollment.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the course for this enrollment.
     */
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    /**
     * Get the program course configuration.
     */
    public function programCourse(): BelongsTo
    {
        return $this->belongsTo(ProgramCourse::class);
    }

    /**
     * Calculate the final grade based on component scores and weights.
     */
    public function calculateFinalGrade(): void
    {
        if ($this->cc_score === null || $this->ds_score === null || $this->exam_score === null) {
            $this->final_grade = null;
            $this->letter_grade = null;
            return;
        }

        // Calculate weighted average
        $ccContribution = ($this->cc_score * $this->cc_weight) / 100;
        $dsContribution = ($this->ds_score * $this->ds_weight) / 100;
        $examContribution = ($this->exam_score * $this->exam_weight) / 100;

        $this->final_grade = $ccContribution + $dsContribution + $examContribution;
        $this->letter_grade = $this->calculateLetterGrade($this->final_grade);
    }

    /**
     * Convert numeric grade to letter grade.
     */
    protected function calculateLetterGrade(float $grade): string
    {
        return match (true) {
            $grade >= 90 => 'A',
            $grade >= 80 => 'B',
            $grade >= 70 => 'C',
            $grade >= 60 => 'D',
            default => 'F',
        };
    }

    /**
     * Check if the student passed this course.
     */
    public function isPassed(): bool
    {
        return $this->final_grade !== null && $this->final_grade >= 60;
    }

    /**
     * Check if the student failed this course.
     */
    public function isFailed(): bool
    {
        return $this->final_grade !== null && $this->final_grade < 60;
    }

    /**
     * Check if grades are complete.
     */
    public function hasCompleteGrades(): bool
    {
        return $this->cc_score !== null
            && $this->ds_score !== null
            && $this->exam_score !== null;
    }

    /**
     * Get grade point for GPA calculation (4.0 scale).
     */
    public function getGradePoint(): float
    {
        if ($this->letter_grade === null) {
            return 0.0;
        }

        return match ($this->letter_grade) {
            'A' => 4.0,
            'B' => 3.0,
            'C' => 2.0,
            'D' => 1.0,
            default => 0.0,
        };
    }

    /**
     * Scope to filter completed courses.
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope to filter enrolled courses.
     */
    public function scopeEnrolled($query)
    {
        return $query->where('status', 'enrolled');
    }

    /**
     * Scope to filter by year.
     */
    public function scopeByYear($query, int $year)
    {
        return $query->where('year_taken', $year);
    }

    /**
     * Scope to filter by semester.
     */
    public function scopeBySemester($query, int $semester)
    {
        return $query->where('semester_taken', $semester);
    }
}
