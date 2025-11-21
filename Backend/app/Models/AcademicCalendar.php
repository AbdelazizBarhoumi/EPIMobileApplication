<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class AcademicCalendar extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'start_date',
        'end_date',
        'status',
        'planned_credits',
        'important_dates',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'planned_credits' => 'integer',
        'important_dates' => 'array',
    ];

    /**
     * Get courses in this semester.
     */
    public function courses(): HasMany
    {
        return $this->hasMany(Course::class);
    }

    /**
     * Get the active academic calendar.
     */
    public static function getActive(): ?self
    {
        return self::where('status', 'active')->first();
    }

    /**
     * Check if semester is currently active.
     */
    public function isActive(): bool
    {
        $now = now();
        return $now->between($this->start_date, $this->end_date);
    }

    /**
     * Get total courses in this semester.
     */
    public function getCoursesCountAttribute(): int
    {
        return $this->courses()->count();
    }
}
