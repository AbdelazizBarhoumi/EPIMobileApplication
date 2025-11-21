<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use App\Models\Course;
use App\Models\ProgramCourse;
use App\Models\StudentCourse;
use App\Models\Schedule;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScheduleApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(); // Run seeders to populate data
    }

    public function test_can_get_student_schedule(): void
    {
        // Create a user and student
        $user = User::factory()->create();
        $student = Student::factory()->create([
            'user_id' => $user->id,
            'year_level' => 1,
        ]);

        // Authenticate
        $this->actingAs($user);

        // Make request
        $response = $this->getJson('/api/schedule/my-schedule');

        // Debug output
        if ($response->status() !== 200) {
            dump('Response Status:', $response->status());
            dump('Response Body:', $response->json());
        }

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data' => [
                'student',
                'schedule',
                'time_slots',
            ],
        ]);
    }

    public function test_can_get_major_schedule(): void
    {
        $user = User::factory()->create();
        $student = Student::factory()->create(['user_id' => $user->id]);
        
        $this->actingAs($user);

        $major = $student->major;
        $year = 1;
        $semester = 1;

        $response = $this->getJson("/api/schedule/major/{$major->id}/year/{$year}/semester/{$semester}");

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data' => [
                'major',
                'year',
                'semester',
                'schedule',
                'time_slots',
            ],
        ]);
    }

    public function test_student_schedule_requires_authentication(): void
    {
        $response = $this->getJson('/api/schedule/my-schedule');

        $response->assertStatus(401);
    }
}
