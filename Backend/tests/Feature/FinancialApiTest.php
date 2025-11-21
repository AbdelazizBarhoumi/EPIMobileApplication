<?php

namespace Tests\Feature;

use App\Models\Bill;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinancialApiTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Student $student;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');

        $this->user = User::factory()->create();
        $this->student = Student::factory()->create(['user_id' => $this->user->id]);
    }

    public function test_can_get_bills_list(): void
    {
        Sanctum::actingAs($this->user);

        Bill::factory()->count(3)->create(['student_id' => $this->student->id]);

        $response = $this->getJson('/api/financial/bills');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'bills',
                    'total_pending',
                    'total_paid',
                    'total_overdue',
                ],
            ]);
    }

    public function test_can_get_specific_bill(): void
    {
        Sanctum::actingAs($this->user);

        $bill = Bill::factory()->create(['student_id' => $this->student->id]);

        $response = $this->getJson("/api/financial/bills/{$bill->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'bill' => [
                        'id' => $bill->id,
                    ],
                ],
            ]);
    }

    public function test_can_create_payment(): void
    {
        Sanctum::actingAs($this->user);

        $bill = Bill::factory()->create([
            'student_id' => $this->student->id,
            'amount' => 1000.000,
            'status' => 'pending',
        ]);

        $paymentData = [
            'bill_id' => $bill->id,
            'amount' => 500.000,
            'payment_date' => now()->format('Y-m-d'),
            'method' => 'card',
            'transaction_reference' => 'TXN123456',
        ];

        $response = $this->postJson('/api/financial/payments', $paymentData);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Payment created successfully',
            ]);

        $this->assertDatabaseHas('payments', [
            'student_id' => $this->student->id,
            'bill_id' => $bill->id,
            'amount' => 500.000,
        ]);
    }

    public function test_can_get_financial_summary(): void
    {
        Sanctum::actingAs($this->user);

        Bill::factory()->create([
            'student_id' => $this->student->id,
            'amount' => 1000.000,
            'status' => 'pending',
        ]);

        Bill::factory()->create([
            'student_id' => $this->student->id,
            'amount' => 500.000,
            'status' => 'paid',
        ]);

        $response = $this->getJson('/api/financial/summary');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'tuition_fees',
                    'total_bills',
                    'total_paid',
                    'pending_bills',
                    'overdue_bills',
                    'outstanding_balance',
                ],
            ]);
    }

    public function test_payment_validation_fails_with_invalid_data(): void
    {
        Sanctum::actingAs($this->user);

        $paymentData = [
            'bill_id' => 999999, // non-existent bill
            'amount' => -100, // negative amount
            'payment_date' => 'invalid-date',
            'method' => 'invalid-method',
        ];

        $response = $this->postJson('/api/financial/payments', $paymentData);

        $response->assertStatus(422)
            ->assertJson(['success' => false])
            ->assertJsonStructure(['success', 'errors']);
    }
}
