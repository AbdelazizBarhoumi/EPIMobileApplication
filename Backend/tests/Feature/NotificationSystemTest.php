<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Student;
use App\Models\Major;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;

/**
 * Notification System Integration Tests
 * 
 * Tests the simplified notification architecture:
 * - OneSignal: Push delivery
 * - Firestore: Notification history storage
 * - NO MySQL: Not needed for notifications
 */
class NotificationSystemTest extends TestCase
{
    use RefreshDatabase;

    private User $adminUser;

    protected function setUp(): void
    {
        parent::setUp();

        // Set up test environment variables
        putenv('ONESIGNAL_APP_ID=test_onesignal_app_id');
        putenv('ONESIGNAL_REST_API_KEY=test_onesignal_api_key');
        putenv('FIREBASE_PROJECT_ID=test_firebase_project');

        // Mock external APIs to avoid real calls during tests
        Http::fake([
            'onesignal.com/*' => Http::response([
                'id' => 'test-notification-id',
                'recipients' => 5,
            ], 200),
            'firestore.googleapis.com/*' => Http::response([
                'name' => 'projects/test/documents/notifications/user1/items/notif1',
            ], 200),
        ]);

        // Create test data
        $this->createTestData();

        // Authenticate as admin for all tests
        Sanctum::actingAs($this->adminUser);
    }

    protected function createTestData(): void
    {
        // Create admin user
        $this->adminUser = User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
            'firebase_uid' => 'admin_firebase_uid',
        ]);

        // Create users with Firebase UIDs
        $user1 = User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => bcrypt('password'),
            'firebase_uid' => 'firebase_user_1',
        ]);

        $user2 = User::create([
            'name' => 'Jane Smith',
            'email' => 'jane@example.com',
            'password' => bcrypt('password'),
            'firebase_uid' => 'firebase_user_2',
        ]);

        // Create a major
        $major = Major::create([
            'name' => 'Computer Science',
            'code' => 'CS',
            'department' => 'Engineering',
        ]);

        // Create students linked to users
        Student::create([
            'user_id' => $user1->id,
            'student_id' => 'STU001',
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'major_id' => $major->id,
            'academic_year' => '2024-2025',
            'class' => 'Third Year',
        ]);

        Student::create([
            'user_id' => $user2->id,
            'student_id' => 'STU002',
            'name' => 'Jane Smith',
            'email' => 'jane@example.com',
            'major_id' => $major->id,
            'academic_year' => '2024-2025',
            'class' => 'Third Year',
        ]);
    }

    /** @test */
    public function can_send_notification_to_all_students()
    {
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'Test Announcement',
            'message' => 'This is a test notification to all students',
            'type' => 'announcement',
            'priority' => 'medium',
            'target_type' => 'all',
            'sender_id' => 'admin_1',
            'sender_name' => 'Admin User',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Notification sent successfully',
            ])
            ->assertJsonStructure([
                'success',
                'message',
                'notification_id',
                'recipients',
                'push_sent',
                'stored_in_firestore',
            ]);

        // Verify recipients count matches our test students
        $this->assertEquals(2, $response->json('recipients'));

        // Verify OneSignal was called
        Http::assertSent(function ($request) {
            return str_contains($request->url(), 'onesignal.com');
        });

        // Verify Firestore was called for each user
        Http::assertSent(function ($request) {
            return str_contains($request->url(), 'firestore.googleapis.com');
        });
    }

    /** @test */
    public function can_send_notification_to_specific_class()
    {
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'CS Exam Reminder',
            'message' => 'Exam tomorrow at 9 AM',
            'type' => 'exam',
            'priority' => 'critical',
            'target_type' => 'class',
            'target_classes' => ['Computer Science'],
            'sender_id' => 'teacher_1',
            'sender_name' => 'Professor Smith',
        ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true]);
    }

    /** @test */
    public function can_send_notification_to_individual_users()
    {
        // Refactor: Use student_id instead of firebase_uid - controller now resolves firebase_uid
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'Personal Message',
            'message' => 'Please come to office hours',
            'type' => 'general',
            'priority' => 'low',
            'target_type' => 'individual',
            'target_users' => ['STU001'], // Use student_id from test data
            'sender_id' => 'teacher_2',
            'sender_name' => 'Dr. Johnson',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'recipients' => 1,
            ]);
    }

    /** @test */
    public function returns_error_when_no_target_users_found()
    {
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'Test',
            'message' => 'Test message',
            'type' => 'general',
            'target_type' => 'individual',
            'target_users' => [], // Empty array
            'sender_id' => 'admin_1',
            'sender_name' => 'Admin',
        ]);

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'No target users found',
            ]);
    }

    /** @test */
    public function validates_required_fields()
    {
        $response = $this->postJson('/api/notifications/send', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title', 'message', 'type', 'target_type', 'sender_id', 'sender_name']);
    }

    /** @test */
    public function validates_notification_type()
    {
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'Test',
            'message' => 'Test message',
            'type' => 'invalid_type', // Invalid
            'target_type' => 'all',
            'sender_id' => 'admin_1',
            'sender_name' => 'Admin',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type']);
    }

    /** @test */
    public function can_get_notification_templates()
    {
        $response = $this->getJson('/api/notifications/templates');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'exam_announcement' => ['title', 'message', 'type', 'priority'],
                'payment_due' => ['title', 'message', 'type', 'priority'],
                'grade_posted' => ['title', 'message', 'type', 'priority'],
                'schedule_change' => ['title', 'message', 'type', 'priority'],
            ]);
    }

    /** @test */
    public function sets_default_priority_based_on_type()
    {
        // Exam type should default to critical priority
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'Exam Notice',
            'message' => 'Important exam info',
            'type' => 'exam',
            // priority not specified - should default to 'critical'
            'target_type' => 'individual',
            'target_users' => ['STU001'], // Refactor: Use student_id from test data
            'sender_id' => 'admin_1',
            'sender_name' => 'Admin',
        ]);

        $response->assertStatus(201);

        // Verify OneSignal was called with high priority (10 for critical)
        Http::assertSent(function ($request) {
            if (!str_contains($request->url(), 'onesignal.com')) {
                return false;
            }
            $body = json_decode($request->body(), true);
            return ($body['priority'] ?? 0) === 10;
        });
    }

    /** @test */
    public function includes_metadata_in_notification()
    {
        $response = $this->postJson('/api/notifications/send', [
            'title' => 'Grade Posted',
            'message' => 'Your grade is available',
            'type' => 'grade',
            'target_type' => 'individual',
            'target_users' => ['STU001'], // Refactor: Use student_id from test data
            'sender_id' => 'system',
            'sender_name' => 'EPI System',
            'metadata' => [
                'course_id' => 'CS101',
                'grade' => 'A',
            ],
        ]);

        $response->assertStatus(201);

        // Verify metadata was included in OneSignal payload
        Http::assertSent(function ($request) {
            if (!str_contains($request->url(), 'onesignal.com')) {
                return false;
            }
            $body = json_decode($request->body(), true);
            return isset($body['data']['metadata']['course_id']);
        });
    }
}
