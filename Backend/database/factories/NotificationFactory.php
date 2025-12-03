<?php

namespace Database\Factories;

use App\Models\Notification;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class NotificationFactory extends Factory
{
    protected $model = Notification::class;

    public function definition(): array
    {
        $types = ['exam', 'payment', 'grade', 'event', 'schedule', 'announcement', 'club', 'general'];
        $priorities = ['critical', 'high', 'medium', 'low'];
        $targetTypes = ['individual', 'class', 'all'];

        return [
            'notification_id' => 'notif_' . Str::uuid(),
            'title' => $this->faker->sentence(),
            'message' => $this->faker->paragraph(),
            'type' => $this->faker->randomElement($types),
            'priority' => $this->faker->randomElement($priorities),
            'target_type' => $this->faker->randomElement($targetTypes),
            'target_users' => ['user_1', 'user_2'],
            'target_classes' => ['Computer Science', 'Software Engineering'],
            'sender_id' => 'admin_' . $this->faker->randomNumber(3),
            'sender_name' => $this->faker->name(),
            'sender_role' => $this->faker->randomElement(['admin', 'teacher', 'system']),
            'metadata' => ['key' => 'value'],
            'expiry_date' => $this->faker->optional()->dateTimeBetween('now', '+1 month'),
            'pinned' => $this->faker->boolean(10),
            'total_recipients' => $this->faker->numberBetween(10, 500),
            'delivered_count' => $this->faker->numberBetween(5, 450),
            'read_count' => $this->faker->numberBetween(0, 400),
            'is_sent' => $this->faker->boolean(80),
            'sent_at' => $this->faker->optional(0.8)->dateTimeBetween('-1 week', 'now'),
            'is_scheduled' => $this->faker->boolean(10),
            'scheduled_for' => $this->faker->optional(0.1)->dateTimeBetween('now', '+1 week'),
        ];
    }

    public function critical(): self
    {
        return $this->state([
            'priority' => 'critical',
            'type' => 'exam',
        ]);
    }

    public function scheduled(): self
    {
        return $this->state([
            'is_scheduled' => true,
            'is_sent' => false,
            'scheduled_for' => $this->faker->dateTimeBetween('now', '+1 week'),
        ]);
    }

    public function sent(): self
    {
        return $this->state([
            'is_sent' => true,
            'sent_at' => $this->faker->dateTimeBetween('-1 week', 'now'),
        ]);
    }
}
