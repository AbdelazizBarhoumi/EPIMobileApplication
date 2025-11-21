<?php

namespace Database\Factories;

use App\Models\Event;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Event>
 */
class EventFactory extends Factory
{
    protected $model = Event::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $eventDate = now()->addDays(rand(1, 90));
        $eventEndDate = (clone $eventDate)->addHours(rand(2, 8));

        return [
            'title' => fake()->sentence(4),
            'description' => fake()->paragraph(3),
            'event_date' => $eventDate,
            'event_end_date' => $eventEndDate,
            'location' => 'Building ' . fake()->randomElement(['A', 'B', 'C']) . ', Room ' . fake()->numberBetween(100, 400),
            'category' => fake()->randomElement(['academic', 'sports', 'cultural', 'social', 'career', 'other']),
            'capacity' => fake()->optional()->numberBetween(50, 500),
            'registered_count' => fake()->numberBetween(0, 50),
            'organizer' => fake()->company(),
            'image_url' => fake()->imageUrl(800, 400, 'events'),
            'is_active' => true,
        ];
    }
}
