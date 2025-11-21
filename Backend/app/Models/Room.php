<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Room extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'room_code',
        'name',
        'type',
        'building',
        'floor',
        'capacity',
        'facilities',
        'is_available',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'capacity' => 'integer',
        'facilities' => 'array',
        'is_available' => 'boolean',
    ];

    /**
     * Get schedules for this room.
     */
    public function schedules(): HasMany
    {
        return $this->hasMany(Schedule::class);
    }

    /**
     * Check if room is available at specific day and time slot.
     */
    public function isAvailableAt(string $day, int $timeSlot): bool
    {
        if (!$this->is_available) {
            return false;
        }

        return !$this->schedules()
            ->where('day_of_week', $day)
            ->where('time_slot', $timeSlot)
            ->exists();
    }

    /**
     * Get availability for the entire week.
     */
    public function getWeeklyAvailability(): array
    {
        $availability = [];
        $days = Schedule::getDaysOfWeek();
        $timeSlots = Schedule::getTimeSlots();

        foreach ($days as $day) {
            $availability[$day] = [];
            foreach (array_keys($timeSlots) as $slot) {
                $availability[$day][$slot] = $this->isAvailableAt($day, $slot);
            }
        }

        return $availability;
    }

    /**
     * Scope for specific room type.
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Scope for available rooms.
     */
    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }
}
