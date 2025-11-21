<?php

namespace Database\Factories;

use App\Models\Club;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Club>
 */
class ClubFactory extends Factory
{
    protected $model = Club::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->words(2, true) . ' Club',
            'description' => fake()->paragraph(3),
            'category' => fake()->randomElement(['academic', 'sports', 'cultural', 'social', 'arts', 'technology', 'other']),
            'member_count' => fake()->numberBetween(10, 100),
            'president_name' => fake()->name(),
            'meeting_schedule' => fake()->randomElement(['Every Monday 4:00 PM', 'Every Friday 3:00 PM', 'Every Wednesday 5:00 PM']),
            'image_url' => fake()->imageUrl(400, 400, 'clubs'),
            'is_active' => true,
        ];
    }
}
