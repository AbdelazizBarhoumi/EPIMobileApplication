<?php

namespace Tests\Unit;

use App\Models\Event;
use App\Models\Student;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EventTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
    }

    public function test_event_is_full_when_capacity_reached(): void
    {
        $event = Event::factory()->create([
            'capacity' => 50,
            'registered_count' => 50,
        ]);

        $this->assertTrue($event->is_full);
    }

    public function test_event_is_not_full_when_capacity_not_reached(): void
    {
        $event = Event::factory()->create([
            'capacity' => 50,
            'registered_count' => 30,
        ]);

        $this->assertFalse($event->is_full);
    }

    public function test_event_spots_available_calculation(): void
    {
        $event = Event::factory()->create([
            'capacity' => 100,
            'registered_count' => 65,
        ]);

        $this->assertEquals(35, $event->spots_available);
    }

    public function test_event_is_upcoming(): void
    {
        $event = Event::factory()->create([
            'event_date' => now()->addDays(5),
        ]);

        $this->assertTrue($event->is_upcoming);
    }

    public function test_event_is_not_upcoming_when_past(): void
    {
        $event = Event::factory()->create([
            'event_date' => now()->subDays(5),
        ]);

        $this->assertFalse($event->is_upcoming);
    }

    public function test_event_registration_count_increments(): void
    {
        $event = Event::factory()->create([
            'registered_count' => 10,
        ]);

        $event->incrementRegistrationCount();

        $this->assertEquals(11, $event->fresh()->registered_count);
    }

    public function test_event_registration_count_decrements(): void
    {
        $event = Event::factory()->create([
            'registered_count' => 10,
        ]);

        $event->decrementRegistrationCount();

        $this->assertEquals(9, $event->fresh()->registered_count);
    }
}
