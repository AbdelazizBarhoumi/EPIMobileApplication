<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Notification;
use App\Models\FcmToken;
use App\Models\NotificationDelivery;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $student;
    protected $major;

    protected function setUp(): void
    {
        parent::setUp();

        // Create test user
        $this->user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        // Create test major
        $this->major = Major::create([
            'code' => 'CS',
            'name' => 'Computer Science',
            'department' => 'Engineering',
            'duration_years' => 5,
            'total_credits_required' => 169,
        ]);

        // Create test student
        $this->student = Student::create([
            'student_id' => 'TEST001',
            'user_id' => 1,
            'name' => 'Test Student',
            'email' => 'student@example.com',
            'major_id' => $this->major->id,
            'year_level' => 2,
            'academic_year' => '2024-2025',
            'class' => 'Second Year',
        ]);
    }

    /** @test */
    public function it_can_register_fcm_token()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/register-token', [
                'user_id' => 'firebase_test_uid',
                'fcm_token' => 'test_fcm_token_123',
                'student_id' => (string) $this->student->id,
                'device_type' => 'android',
                'device_name' => 'Test Device',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'FCM token registered successfully',
            ]);

        $this->assertDatabaseHas('fcm_tokens', [
            'user_id' => 'firebase_test_uid',
            'fcm_token' => 'test_fcm_token_123',
            'device_type' => 'android',
        ]);
    }

    /** @test */
    public function it_can_create_notification_for_individual()
    {
        // Register FCM token first
        FcmToken::create([
            'user_id' => 'firebase_test_uid',
            'fcm_token' => 'test_token',
            'device_type' => 'android',
            'is_active' => true,
        ]);

        // Mock FCM HTTP request
        Http::fake([
            'fcm.googleapis.com/*' => Http::response([
                'success' => 1,
                'failure' => 0,
            ], 200),
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/send', [
                'title' => 'Test Notification',
                'message' => 'This is a test message',
                'type' => 'general',
                'priority' => 'medium',
                'target_type' => 'individual',
                'target_users' => ['firebase_test_uid'],
                'sender_id' => 'admin_001',
                'sender_name' => 'Admin',
                'sender_role' => 'admin',
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Notification sent successfully',
            ]);

        $this->assertDatabaseHas('notifications', [
            'title' => 'Test Notification',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'is_sent' => true,
        ]);
    }

    /** @test */
    public function it_can_create_notification_for_class()
    {
        // Create additional users for foreign keys
        $user2 = User::factory()->create();
        $user3 = User::factory()->create();

        // Create multiple students in the same major
        Student::create([
            'student_id' => 'TEST002',
            'user_id' => $user2->id,
            'name' => 'Student 1',
            'email' => 'student1@example.com',
            'major_id' => $this->major->id,
            'year_level' => 2,
            'academic_year' => '2024-2025',
            'class' => 'Second Year',
        ]);

        Student::create([
            'student_id' => 'TEST003',
            'user_id' => $user3->id,
            'name' => 'Student 2',
            'email' => 'student2@example.com',
            'major_id' => $this->major->id,
            'year_level' => 2,
            'academic_year' => '2024-2025',
            'class' => 'Second Year',
        ]);

        // Register tokens
        FcmToken::create(['user_id' => $user2->id, 'fcm_token' => 'token_1', 'is_active' => true]);
        FcmToken::create(['user_id' => $user3->id, 'fcm_token' => 'token_2', 'is_active' => true]);

        Http::fake();

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/send', [
                'title' => 'Class Exam Announcement',
                'message' => 'Midterm exam on Dec 20',
                'type' => 'exam',
                'priority' => 'critical',
                'target_type' => 'class',
                'target_classes' => ['Computer Science'],
                'sender_id' => 'teacher_001',
                'sender_name' => 'Prof. Smith',
                'sender_role' => 'teacher',
            ]);

        $response->assertStatus(201);

        $notification = Notification::where('title', 'Class Exam Announcement')->first();
        $this->assertEquals(3, $notification->total_recipients); // 3 CS students
    }

    /** @test */
    public function it_can_create_scheduled_notification()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/send', [
                'title' => 'Scheduled Test',
                'message' => 'This will be sent later',
                'type' => 'general',
                'priority' => 'low',
                'target_type' => 'individual',
                'target_users' => ['firebase_test_uid'],
                'sender_id' => 'admin_001',
                'sender_name' => 'Admin',
                'sender_role' => 'admin',
                'is_scheduled' => true,
                'scheduled_for' => now()->addDay()->toDateTimeString(),
            ]);

        $response->assertStatus(201)
            ->assertJsonFragment(['message' => 'Notification scheduled successfully']);

        $this->assertDatabaseHas('notifications', [
            'title' => 'Scheduled Test',
            'is_scheduled' => true,
            'is_sent' => false,
        ]);
    }

    /** @test */
    public function it_can_get_notification_history()
    {
        Notification::factory()->count(5)->create([
            'type' => 'exam',
            'is_sent' => true,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/notifications?type=exam&per_page=10');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'current_page',
                'data' => [
                    '*' => [
                        'id',
                        'notification_id',
                        'title',
                        'message',
                        'type',
                        'priority',
                        'total_recipients',
                    ],
                ],
                'total',
            ]);
    }

    /** @test */
    public function it_can_get_notification_statistics()
    {
        Notification::factory()->count(10)->create(['is_sent' => true]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/notifications/statistics');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'total_sent',
                'pending_scheduled',
                'by_type',
                'by_priority',
                'total_recipients',
                'total_delivered',
                'delivery_rate',
            ]);
    }

    /** @test */
    public function it_can_get_notification_templates()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/notifications/templates');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'exam_announcement' => [
                    'title',
                    'message',
                    'type',
                    'priority',
                    'variables',
                ],
                'payment_due',
                'grade_posted',
            ]);
    }

    /** @test */
    public function it_validates_required_fields_when_creating_notification()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/send', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors([
                'title',
                'message',
                'type',
                'priority',
                'target_type',
                'sender_id',
                'sender_name',
                'sender_role',
            ]);
    }

    /** @test */
    public function it_tracks_notification_deliveries()
    {
        // Set FCM server key for testing
        config(['services.fcm.server_key' => 'test_fcm_key']);
        putenv('FCM_SERVER_KEY=test_fcm_key');

        FcmToken::create([
            'user_id' => $this->student->user_id,
            'fcm_token' => 'test_token',
            'is_active' => true,
        ]);

        Http::fake([
            'fcm.googleapis.com/*' => Http::response(['success' => 1], 200),
        ]);

        $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/send', [
                'title' => 'Delivery Test',
                'message' => 'Testing delivery tracking',
                'type' => 'general',
                'priority' => 'medium',
                'target_type' => 'individual',
                'target_users' => [$this->student->user_id],
                'sender_id' => 'admin_001',
                'sender_name' => 'Admin',
                'sender_role' => 'admin',
            ]);

        $this->assertDatabaseHas('notification_deliveries', [
            'user_id' => $this->student->user_id,
            'status' => 'sent',
        ]);
    }

    /** @test */
    public function it_can_process_scheduled_notifications()
    {
        // Create scheduled notification that's due
        $notification = Notification::create([
            'notification_id' => 'test_scheduled',
            'title' => 'Scheduled Notification',
            'message' => 'This should be sent now',
            'type' => 'general',
            'priority' => 'medium',
            'target_type' => 'individual',
            'target_users' => ['firebase_test_uid'],
            'sender_id' => 'admin',
            'sender_name' => 'Admin',
            'sender_role' => 'admin',
            'is_scheduled' => true,
            'scheduled_for' => now()->subMinute(), // Past time
            'is_sent' => false,
        ]);

        FcmToken::create([
            'user_id' => 'firebase_test_uid',
            'fcm_token' => 'test_token',
            'is_active' => true,
        ]);

        Http::fake();

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/notifications/process-scheduled');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'processed' => 1,
            ]);

        $this->assertDatabaseHas('notifications', [
            'notification_id' => 'test_scheduled',
            'is_sent' => true,
        ]);
    }
}
