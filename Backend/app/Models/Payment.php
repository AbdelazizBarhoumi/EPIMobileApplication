<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Payment extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'student_id',
        'bill_id',
        'amount',
        'payment_date',
        'method',
        'transaction_reference',
        'notes',
    ];

    protected $casts = [
        'amount' => 'decimal:3',
        'payment_date' => 'date',
    ];

    /**
     * Get the student this payment belongs to.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the bill this payment is for.
     */
    public function bill(): BelongsTo
    {
        return $this->belongsTo(Bill::class);
    }

    /**
     * Boot method to handle payment processing.
     */
    protected static function booted(): void
    {
        static::created(function (Payment $payment) {
            if ($payment->bill) {
                $payment->bill->markAsPaid();
            }
        });
    }
}
