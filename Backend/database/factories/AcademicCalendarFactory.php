<?php

namespace Database\Factories;

use App\Models\AcademicCalendar;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\AcademicCalendar>
 */
class AcademicCalendarFactory extends Factory
{
    protected $model = AcademicCalendar::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $startDate = now()->addDays(rand(1, 30));
        $endDate = (clone $startDate)->addMonths(4);

        return [
            'name' => fake()->randomElement(['Fall 2024', 'Spring 2025', 'Summer 2025']),
            'start_date' => $startDate,
            'end_date' => $endDate,
            'status' => fake()->randomElement(['upcoming', 'active', 'past']),
            'planned_credits' => fake()->numberBetween(12, 18),
            'important_dates' => [
                'classes_begin' => $startDate->copy()->addDays(7)->format('Y-m-d'),
                'add_drop_deadline' => $startDate->copy()->addDays(14)->format('Y-m-d'),
                'midterms' => $startDate->copy()->addDays(60)->format('Y-m-d'),
                'finals' => $startDate->copy()->addDays(120)->format('Y-m-d'),
            ],
        ];
    }
}
