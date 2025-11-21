<?php

namespace Database\Factories;

use App\Models\News;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\News>
 */
class NewsFactory extends Factory
{
    protected $model = News::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => fake()->sentence(6),
            'description' => fake()->paragraphs(3, true),
            'image_url' => fake()->imageUrl(1200, 600, 'news'),
            'publish_date' => fake()->dateTimeBetween('-1 month', 'now'),
            'category' => fake()->randomElement(['academic', 'events', 'financial', 'sports', 'general', 'announcement']),
            'external_link' => fake()->optional()->url(),
            'author' => fake()->name(),
            'is_featured' => fake()->boolean(20),
            'is_published' => true,
        ];
    }
}
