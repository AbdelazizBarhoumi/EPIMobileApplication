<?php

namespace Database\Factories;

use App\Models\ProgramCourse;
use App\Models\Schedule;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Schedule>
 */
class ScheduleFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $timeSlots = Schedule::getTimeSlots();
        $timeSlot = fake()->numberBetween(1, 5);
        $times = $timeSlots[$timeSlot];
        
        return [
            'program_course_id' => ProgramCourse::factory(),
            'day_of_week' => fake()->randomElement(Schedule::getDaysOfWeek()),
            'time_slot' => $timeSlot,
            'start_time' => $times['start'],
            'end_time' => $times['end'],
            'room' => fake()->randomElement(['CS-', 'EE-', 'ME-', 'BA-', 'GEN-']) . fake()->numberBetween(101, 599),
        ];
    }
}
