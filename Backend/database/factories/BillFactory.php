<?php

namespace Database\Factories;

use App\Models\Bill;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Bill>
 */
class BillFactory extends Factory
{
    protected $model = Bill::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'student_id' => Student::factory(),
            'description' => fake()->randomElement([
                'Tuition Fee - Fall 2024',
                'Tuition Fee - Spring 2025',
                'Library Fee',
                'Lab Fee',
                'Accommodation Fee',
            ]),
            'amount' => fake()->randomFloat(3, 500, 3000),
            'due_date' => fake()->dateTimeBetween('now', '+3 months'),
            'status' => fake()->randomElement(['pending', 'paid', 'overdue']),
            'bill_type' => fake()->randomElement(['tuition', 'library', 'accommodation', 'lab', 'other']),
        ];
    }
}
