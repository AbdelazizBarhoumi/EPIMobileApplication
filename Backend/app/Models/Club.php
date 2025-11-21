<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Club extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'description',
        'category',
        'member_count',
        'president_name',
        'meeting_schedule',
        'image_url',
        'is_active',
    ];

    protected $casts = [
        'member_count' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Get club memberships.
     */
    public function memberships(): HasMany
    {
        return $this->hasMany(ClubMembership::class);
    }

    /**
     * Get club members.
     */
    public function members(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'club_memberships')
            ->withPivot(['join_date', 'role', 'status'])
            ->withTimestamps();
    }

    /**
     * Get active members.
     */
    public function activeMembers(): BelongsToMany
    {
        return $this->members()->wherePivot('status', 'active');
    }

    /**
     * Increment member count.
     */
    public function incrementMemberCount(): bool
    {
        $this->increment('member_count');
        return true;
    }

    /**
     * Decrement member count.
     */
    public function decrementMemberCount(): bool
    {
        if ($this->member_count > 0) {
            $this->decrement('member_count');
        }
        return true;
    }
}
