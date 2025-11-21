<?php

namespace Database\Factories;

use App\Models\Room;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Room>
 */
class RoomFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $type = fake()->randomElement(['classroom', 'lab', 'auditorium', 'seminar_room']);
        $prefix = fake()->randomElement(['CS', 'EE', 'ME', 'BA', 'GEN']);
        
        return [
            'room_code' => $prefix . '-' . fake()->unique()->numberBetween(101, 999),
            'name' => fake()->words(2, true) . ' ' . ucfirst($type),
            'type' => $type,
            'building' => fake()->randomElement(['Engineering Building', 'Business Building', 'Main Building']),
            'floor' => (string) fake()->numberBetween(1, 5),
            'capacity' => fake()->numberBetween(20, 100),
            'facilities' => fake()->randomElements(['projector', 'whiteboard', 'computers', 'air_conditioning', 'smart_board'], fake()->numberBetween(2, 4)),
            'is_available' => true,
        ];
    }
}
