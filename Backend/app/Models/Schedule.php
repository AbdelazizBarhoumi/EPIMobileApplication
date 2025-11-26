<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Schedule extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'program_course_id',
        'day_of_week',
        'time_slot',
        'start_time',
        'end_time',
        'room_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'time_slot' => 'integer',
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
    ];

    /**
     * Get the program course this schedule belongs to.
     */
    public function programCourse(): BelongsTo
    {
        return $this->belongsTo(ProgramCourse::class);
    }

    /**
     * Get the room.
     */
    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class);
    }

    /**
     * Get attendance records for this schedule.
     */
    public function attendances()
    {
        return $this->hasMany(StudentAttendance::class);
    }

    /**
     * Get the course through program course.
     */
    public function course()
    {
        return $this->programCourse->course();
    }

    /**
     * Get formatted time range.
     */
    public function getTimeRangeAttribute(): string
    {
        return $this->start_time->format('H:i') . ' - ' . $this->end_time->format('H:i');
    }

    /**
     * Get all schedules for a specific day.
     */
    public function scopeForDay($query, string $day)
    {
        return $query->where('day_of_week', $day);
    }

    /**
     * Get all schedules for a specific time slot.
     */
    public function scopeForTimeSlot($query, int $slot)
    {
        return $query->where('time_slot', $slot);
    }

    /**
     * Standard time slots for the day.
     */
    public static function getTimeSlots(): array
    {
        return [
            1 => ['start' => '08:30', 'end' => '10:00'],
            2 => ['start' => '10:15', 'end' => '11:45'],
            3 => ['start' => '12:00', 'end' => '13:30'],
            4 => ['start' => '13:45', 'end' => '15:15'],
            5 => ['start' => '15:30', 'end' => '17:00'],
            6 => ['start' => '17:15', 'end' => '18:45'],
            7 => ['start' => '19:00', 'end' => '20:30'],
        ];
    }

    /**
     * Get days of the week.
     */
    public static function getDaysOfWeek(): array
    {
        return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    }
}
