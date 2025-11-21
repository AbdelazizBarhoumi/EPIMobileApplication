<?php

namespace Tests\Unit;

use App\Models\Bill;
use App\Models\Payment;
use App\Models\Student;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BillTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
    }

    public function test_bill_is_overdue_when_past_due_date(): void
    {
        $bill = Bill::factory()->create([
            'due_date' => now()->subDays(5),
            'status' => 'pending',
        ]);

        $this->assertTrue($bill->is_overdue);
    }

    public function test_bill_is_not_overdue_when_future_due_date(): void
    {
        $bill = Bill::factory()->create([
            'due_date' => now()->addDays(5),
            'status' => 'pending',
        ]);

        $this->assertFalse($bill->is_overdue);
    }

    public function test_bill_total_paid_calculation(): void
    {
        $bill = Bill::factory()->create([
            'amount' => 1000.000,
        ]);

        Payment::factory()->create([
            'bill_id' => $bill->id,
            'amount' => 300.000,
        ]);

        Payment::factory()->create([
            'bill_id' => $bill->id,
            'amount' => 200.000,
        ]);

        $this->assertEquals(500.000, $bill->total_paid);
    }

    public function test_bill_remaining_amount_calculation(): void
    {
        $bill = Bill::factory()->create([
            'amount' => 1000.000,
        ]);

        Payment::factory()->create([
            'bill_id' => $bill->id,
            'amount' => 600.000,
        ]);

        $this->assertEquals(400.000, $bill->remaining_amount);
    }

    public function test_bill_marks_as_paid_when_fully_paid(): void
    {
        $bill = Bill::factory()->create([
            'amount' => 1000.000,
            'status' => 'pending',
        ]);

        Payment::factory()->create([
            'bill_id' => $bill->id,
            'amount' => 1000.000,
        ]);

        $bill->refresh();
        $this->assertTrue($bill->markAsPaid());
        $this->assertEquals('paid', $bill->status);
    }
}
