<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class ClubMembership extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'student_id',
        'club_id',
        'join_date',
        'role',
        'status',
    ];

    protected $casts = [
        'join_date' => 'date',
    ];

    /**
     * Get the student.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the club.
     */
    public function club(): BelongsTo
    {
        return $this->belongsTo(Club::class);
    }

    /**
     * Boot method to handle member count.
     */
    protected static function booted(): void
    {
        static::created(function (ClubMembership $membership) {
            if ($membership->status === 'active') {
                $membership->club->incrementMemberCount();
            }
        });

        static::updated(function (ClubMembership $membership) {
            if ($membership->isDirty('status')) {
                if ($membership->status === 'active' && $membership->getOriginal('status') === 'inactive') {
                    $membership->club->incrementMemberCount();
                } elseif ($membership->status === 'inactive' && $membership->getOriginal('status') === 'active') {
                    $membership->club->decrementMemberCount();
                }
            }
        });

        static::deleted(function (ClubMembership $membership) {
            if ($membership->status === 'active') {
                $membership->club->decrementMemberCount();
            }
        });
    }
}
