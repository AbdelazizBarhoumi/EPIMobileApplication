<?php

namespace Tests\Feature;

use App\Models\Event;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class EventApiTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Student $student;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');

        $this->user = User::factory()->create();
        $this->student = Student::factory()->create(['user_id' => $this->user->id]);
    }

    public function test_can_list_events(): void
    {
        Sanctum::actingAs($this->user);

        Event::factory()->count(3)->create();

        $response = $this->getJson('/api/events');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'data' => [
                        '*' => [
                            'id',
                            'title',
                            'description',
                            'event_date',
                            'location',
                            'category',
                        ],
                    ],
                ],
            ]);
    }

    public function test_can_register_for_event(): void
    {
        Sanctum::actingAs($this->user);

        $event = Event::factory()->create([
            'capacity' => 50,
            'registered_count' => 10,
        ]);

        $response = $this->postJson("/api/events/{$event->id}/register");

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Successfully registered for event',
            ]);

        $this->assertDatabaseHas('event_registrations', [
            'student_id' => $this->student->id,
            'event_id' => $event->id,
            'status' => 'registered',
        ]);
    }

    public function test_cannot_register_for_full_event(): void
    {
        Sanctum::actingAs($this->user);

        $event = Event::factory()->create([
            'capacity' => 50,
            'registered_count' => 50,
        ]);

        $response = $this->postJson("/api/events/{$event->id}/register");

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'Event is full',
            ]);
    }

    public function test_can_cancel_event_registration(): void
    {
        Sanctum::actingAs($this->user);

        $event = Event::factory()->create();

        $this->student->events()->attach($event->id, [
            'registered_at' => now(),
            'status' => 'registered',
        ]);

        $response = $this->deleteJson("/api/events/{$event->id}/register");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Registration cancelled successfully',
            ]);
    }

    public function test_can_filter_events_by_category(): void
    {
        Sanctum::actingAs($this->user);

        Event::factory()->create(['category' => 'academic']);
        Event::factory()->create(['category' => 'sports']);
        Event::factory()->create(['category' => 'academic']);

        $response = $this->getJson('/api/events?category=academic');

        $response->assertStatus(200);
        $this->assertEquals(2, count($response->json('data.data')));
    }
}
