<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Bill extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'student_id',
        'description',
        'amount',
        'due_date',
        'status',
        'bill_type',
    ];

    protected $casts = [
        'amount' => 'decimal:3',
        'due_date' => 'date',
    ];

    protected $appends = [
        'is_overdue',
    ];

    /**
     * Get the student this bill belongs to.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get payments for this bill.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Check if bill is overdue.
     */
    public function getIsOverdueAttribute(): bool
    {
        return now()->greaterThan($this->due_date) && !in_array($this->status, ['paid', 'cancelled']);
    }

    /**
     * Get total paid amount.
     */
    public function getTotalPaidAttribute(): float
    {
        return $this->payments()->sum('amount');
    }

    /**
     * Get remaining amount.
     */
    public function getRemainingAmountAttribute(): float
    {
        return max(0, $this->amount - $this->total_paid);
    }

    /**
     * Mark bill as paid.
     */
    public function markAsPaid(): bool
    {
        if ($this->total_paid >= $this->amount) {
            $this->status = 'paid';
            return $this->save();
        }
        return false;
    }

    /**
     * Check and update overdue status.
     */
    public function checkOverdue(): bool
    {
        if ($this->is_overdue && $this->status === 'pending') {
            $this->status = 'overdue';
            return $this->save();
        }
        return false;
    }
}
