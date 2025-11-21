<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Event extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'event_date',
        'event_end_date',
        'location',
        'category',
        'capacity',
        'registered_count',
        'organizer',
        'image_url',
        'is_active',
    ];

    protected $casts = [
        'event_date' => 'datetime',
        'event_end_date' => 'datetime',
        'capacity' => 'integer',
        'registered_count' => 'integer',
        'is_active' => 'boolean',
    ];

    protected $appends = [
        'is_full',
        'is_upcoming',
        'spots_available',
    ];

    /**
     * Get event registrations.
     */
    public function registrations(): HasMany
    {
        return $this->hasMany(EventRegistration::class);
    }

    /**
     * Get registered students.
     */
    public function students(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'event_registrations')
            ->withPivot(['registered_at', 'status'])
            ->withTimestamps();
    }

    /**
     * Check if event is full.
     */
    public function getIsFullAttribute(): bool
    {
        return $this->capacity && $this->registered_count >= $this->capacity;
    }

    /**
     * Check if event is upcoming.
     */
    public function getIsUpcomingAttribute(): bool
    {
        return $this->event_date->isFuture();
    }

    /**
     * Get available spots.
     */
    public function getSpotsAvailableAttribute(): ?int
    {
        return $this->capacity ? max(0, $this->capacity - $this->registered_count) : null;
    }

    /**
     * Increment registered count.
     */
    public function incrementRegistrationCount(): bool
    {
        $this->increment('registered_count');
        return true;
    }

    /**
     * Decrement registered count.
     */
    public function decrementRegistrationCount(): bool
    {
        if ($this->registered_count > 0) {
            $this->decrement('registered_count');
        }
        return true;
    }
}
