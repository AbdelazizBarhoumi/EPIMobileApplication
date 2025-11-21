<?php

namespace Database\Factories;

use App\Models\AcademicCalendar;
use App\Models\Course;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Course>
 */
class CourseFactory extends Factory
{
    protected $model = Course::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $courseCodes = ['CS', 'IT', 'BUS', 'MTH', 'ENG', 'PHY', 'CHM'];
        $courseCode = fake()->randomElement($courseCodes) . fake()->numberBetween(100, 499);

        return [
            'course_code' => $courseCode,
            'name' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'instructor' => 'Dr. ' . fake()->name(),
            'credits' => fake()->numberBetween(2, 4),
            'schedule' => fake()->randomElement(['Mon, Wed', 'Tue, Thu', 'Mon, Wed, Fri']) . ' ' .
                         fake()->randomElement(['08:00-09:30', '10:00-11:30', '13:00-14:30', '15:00-16:30']),
            'room' => 'Room ' . fake()->randomElement(['A', 'B', 'C']) . '-' . fake()->numberBetween(100, 400),
            'academic_calendar_id' => AcademicCalendar::factory(),
        ];
    }
}
