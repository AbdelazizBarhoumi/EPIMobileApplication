<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class ProgramCourse extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'program_courses';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'major_id',
        'course_id',
        'year_level',
        'semester',
        'is_required',
        'cc_weight',
        'ds_weight',
        'exam_weight',
        'teacher_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'year_level' => 'integer',
        'semester' => 'integer',
        'is_required' => 'boolean',
        'cc_weight' => 'integer',
        'ds_weight' => 'integer',
        'exam_weight' => 'integer',
    ];

    /**
     * Get the major this program course belongs to.
     */
    public function major(): BelongsTo
    {
        return $this->belongsTo(Major::class);
    }

    /**
     * Get the course.
     */
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    /**
     * Get the teacher.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }

    /**
     * Get the schedules for this program course.
     */
    public function schedules(): HasMany
    {
        return $this->hasMany(Schedule::class);
    }

    /**
     * Validate that weights sum to 100.
     */
    public function validateWeights(): bool
    {
        return ($this->cc_weight + $this->ds_weight + $this->exam_weight) === 100;
    }

    /**
     * Get weekly schedule organized by day.
     */
    public function getWeeklySchedule(): array
    {
        $schedules = $this->schedules()->orderBy('day_of_week')->orderBy('time_slot')->get();
        
        $weeklySchedule = [];
        foreach (Schedule::getDaysOfWeek() as $day) {
            $weeklySchedule[$day] = $schedules->where('day_of_week', $day)->values()->toArray();
        }
        
        return $weeklySchedule;
    }
}
