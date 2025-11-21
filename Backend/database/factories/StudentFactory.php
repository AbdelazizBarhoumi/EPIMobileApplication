<?php

namespace Database\Factories;

use App\Models\Student;
use App\Models\User;
use App\Models\Major;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Student>
 */
class StudentFactory extends Factory
{
    protected $model = Student::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'student_id' => fake()->unique()->numerify('1########'),
            'user_id' => User::factory(),
            'major_id' => Major::factory(),
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'avatar_url' => fake()->imageUrl(200, 200, 'people'),
            'year_level' => fake()->numberBetween(1, 5),
            'gpa' => fake()->randomFloat(2, 2.0, 4.0),
            'credits_taken' => fake()->numberBetween(0, 169),
            'total_credits' => 169,
            'tuition_fees' => fake()->randomFloat(3, 0, 5000),
            'academic_year' => '2024-2025',
            'class' => fake()->randomElement(['First Year', 'Second Year', 'Third Year', 'Fourth Year', 'Fifth Year']),
        ];
    }
}
