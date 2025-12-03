<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Notification;
use App\Models\NotificationDelivery;
use Illuminate\Foundation\Testing\RefreshDatabase;

class NotificationModelTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_casts_attributes_correctly()
    {
        $notification = Notification::create([
            'notification_id' => 'test_123',
            'title' => 'Test',
            'message' => 'Test message',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'target_users' => ['user1', 'user2'],
            'metadata' => ['key' => 'value'],
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'pinned' => true,
            'is_sent' => true,
            'sent_at' => now(),
        ]);

        $this->assertIsArray($notification->target_users);
        $this->assertIsArray($notification->metadata);
        $this->assertIsBool($notification->pinned);
        $this->assertIsBool($notification->is_sent);
        $this->assertInstanceOf(\DateTime::class, $notification->sent_at);
    }

    /** @test */
    public function it_can_scope_scheduled_notifications()
    {
        // Create scheduled notification that's due
        Notification::create([
            'notification_id' => 'scheduled_1',
            'title' => 'Scheduled',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'is_scheduled' => true,
            'scheduled_for' => now()->subMinute(),
            'is_sent' => false,
        ]);

        // Create scheduled notification that's not due yet
        Notification::create([
            'notification_id' => 'scheduled_2',
            'title' => 'Not Due',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'is_scheduled' => true,
            'scheduled_for' => now()->addDay(),
            'is_sent' => false,
        ]);

        $scheduled = Notification::scheduled()->get();

        $this->assertEquals(1, $scheduled->count());
        $this->assertEquals('scheduled_1', $scheduled->first()->notification_id);
    }

    /** @test */
    public function it_can_scope_sent_notifications()
    {
        Notification::create([
            'notification_id' => 'sent_1',
            'title' => 'Sent',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'is_sent' => true,
        ]);

        Notification::create([
            'notification_id' => 'not_sent',
            'title' => 'Not Sent',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'is_sent' => false,
        ]);

        $sent = Notification::sent()->get();

        $this->assertEquals(1, $sent->count());
        $this->assertEquals('sent_1', $sent->first()->notification_id);
    }

    /** @test */
    public function it_can_scope_active_notifications()
    {
        // Active (no expiry)
        Notification::create([
            'notification_id' => 'active_1',
            'title' => 'Active',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
        ]);

        // Active (future expiry)
        Notification::create([
            'notification_id' => 'active_2',
            'title' => 'Active',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'expiry_date' => now()->addDay(),
        ]);

        // Expired
        Notification::create([
            'notification_id' => 'expired',
            'title' => 'Expired',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'expiry_date' => now()->subDay(),
        ]);

        $active = Notification::active()->get();

        $this->assertEquals(2, $active->count());
    }

    /** @test */
    public function it_can_filter_by_priority()
    {
        Notification::create([
            'notification_id' => 'critical_1',
            'title' => 'Critical',
            'message' => 'Test',
            'type' => 'exam',
            'priority' => 'critical',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
        ]);

        Notification::create([
            'notification_id' => 'low_1',
            'title' => 'Low',
            'message' => 'Test',
            'type' => 'club',
            'priority' => 'low',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
        ]);

        $critical = Notification::byPriority('critical')->get();

        $this->assertEquals(1, $critical->count());
        $this->assertEquals('critical_1', $critical->first()->notification_id);
    }

    /** @test */
    public function it_has_deliveries_relationship()
    {
        $notification = Notification::create([
            'notification_id' => 'test_rel',
            'title' => 'Test',
            'message' => 'Test',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
        ]);

        NotificationDelivery::create([
            'notification_id' => $notification->id,
            'user_id' => 'user_1',
            'status' => 'sent',
        ]);

        $this->assertEquals(1, $notification->deliveries()->count());
    }
}
