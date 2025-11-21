<?php

namespace Database\Factories;

use App\Models\Major;
use Illuminate\Database\Eloquent\Factories\Factory;

class MajorFactory extends Factory
{
    protected $model = Major::class;

    public function definition(): array
    {
        $codes = ['CS', 'EE', 'ME', 'CE', 'BA', 'IT', 'DS', 'AI'];
        $departments = ['Engineering', 'Business', 'Science', 'Technology'];
        
        return [
            'code' => fake()->unique()->randomElement($codes),
            'name' => fake()->words(2, true) . ' ' . fake()->randomElement(['Engineering', 'Science', 'Administration']),
            'description' => fake()->sentence(),
            'department' => fake()->randomElement($departments),
            'duration_years' => fake()->randomElement([4, 5]),
            'total_credits_required' => fake()->randomElement([132, 169]),
            'degree_type' => 'Bachelor of Science',
            'is_active' => true,
        ];
    }
}
