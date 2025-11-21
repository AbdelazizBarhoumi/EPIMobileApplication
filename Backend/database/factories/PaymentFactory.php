<?php

namespace Database\Factories;

use App\Models\Bill;
use App\Models\Payment;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Payment>
 */
class PaymentFactory extends Factory
{
    protected $model = Payment::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'student_id' => Student::factory(),
            'bill_id' => Bill::factory(),
            'amount' => fake()->randomFloat(3, 100, 2000),
            'payment_date' => fake()->dateTimeBetween('-3 months', 'now'),
            'method' => fake()->randomElement(['card', 'transfer', 'cash', 'check', 'online']),
            'transaction_reference' => 'TXN' . fake()->unique()->numerify('##########'),
            'notes' => fake()->optional()->sentence(),
        ];
    }
}
