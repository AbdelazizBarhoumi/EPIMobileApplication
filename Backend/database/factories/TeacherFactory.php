<?php

namespace Database\Factories;

use App\Models\Teacher;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Teacher>
 */
class TeacherFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'teacher_id' => 'T' . fake()->unique()->numberBetween(10000, 99999),
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'phone' => fake()->phoneNumber(),
            'department' => fake()->randomElement(['Computer Science', 'Mathematics', 'Engineering', 'Business']),
            'title' => fake()->randomElement(['Professor', 'Associate Professor', 'Assistant Professor', 'Instructor']),
            'specialization' => fake()->words(3, true),
            'bio' => fake()->paragraph(),
            'office_location' => fake()->randomElement(['CS Building', 'Math Building', 'Engineering Building']) . ', Room ' . fake()->numberBetween(101, 399),
            'office_hours' => [
                ['day' => 'Monday', 'start' => '14:00', 'end' => '16:00'],
                ['day' => 'Wednesday', 'start' => '14:00', 'end' => '16:00'],
            ],
            'is_active' => true,
        ];
    }
}
