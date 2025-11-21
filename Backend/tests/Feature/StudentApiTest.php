<?php

namespace Tests\Feature;

use App\Models\Student;
use App\Models\User;
use App\Models\Course;
use App\Models\AcademicCalendar;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StudentApiTest extends TestCase
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

    public function test_can_get_student_profile(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->getJson('/api/student/profile');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'student',
                    'attendance_percentage',
                    'outstanding_balance',
                ],
            ]);
    }

    public function test_can_get_student_dashboard(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->getJson('/api/student/dashboard');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'profile',
                    'financial',
                    'academic',
                    'upcoming_events',
                    'pending_bills',
                ],
            ]);
    }

    public function test_can_get_student_courses(): void
    {
        Sanctum::actingAs($this->user);

        $semester = AcademicCalendar::factory()->create();
        $course = Course::factory()->create(['academic_calendar_id' => $semester->id]);

        $this->student->courses()->attach($course->id, [
            'year_taken' => 1,
            'semester_taken' => 1,
            'cc_score' => 85.50,
            'ds_score' => 90.00,
            'exam_score' => 88.00,
            'cc_weight' => 40,
            'ds_weight' => 20,
            'exam_weight' => 40,
            'final_grade' => 87.83,
            'letter_grade' => 'A',
            'status' => 'enrolled',
        ]);

        $response = $this->getJson('/api/student/courses');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'course_code',
                        'name',
                        'instructor',
                        'credits',
                        'schedule',
                        'room',
                        'semester',
                        'grades',
                        'status',
                    ],
                ],
            ]);
    }

    public function test_cannot_access_without_authentication(): void
    {
        $response = $this->getJson('/api/student/profile');

        $response->assertStatus(401);
    }
}
