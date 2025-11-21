<?php

namespace Tests\Unit;

use App\Models\Student;
use App\Models\User;
use App\Models\Course;
use App\Models\Bill;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StudentTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
    }

    public function test_student_belongs_to_user(): void
    {
        $user = User::factory()->create();
        $student = Student::factory()->create(['user_id' => $user->id]);

        $this->assertInstanceOf(User::class, $student->user);
        $this->assertEquals($user->id, $student->user->id);
    }

    public function test_student_credits_progress_percentage(): void
    {
        $student = Student::factory()->create([
            'credits_taken' => 155,
            'total_credits' => 169,
        ]);

        $expectedPercentage = round((155 / 169) * 100, 2);
        $this->assertEquals($expectedPercentage, $student->credits_progress_percentage);
    }

    public function test_student_outstanding_balance_calculation(): void
    {
        $student = Student::factory()->create();

        Bill::factory()->create([
            'student_id' => $student->id,
            'amount' => 1000.000,
            'status' => 'pending',
        ]);

        Bill::factory()->create([
            'student_id' => $student->id,
            'amount' => 1500.000,
            'status' => 'pending',
        ]);

        Bill::factory()->create([
            'student_id' => $student->id,
            'amount' => 500.000,
            'status' => 'paid',
        ]);

        $this->assertEquals(2500.000, $student->outstanding_balance);
    }

    public function test_student_can_enroll_in_courses(): void
    {
        $student = Student::factory()->create();
        $course = Course::factory()->create();

        $student->courses()->attach($course->id, [
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

        $this->assertTrue($student->courses->contains($course->id));
        $this->assertEquals('A', $student->courses->first()->pivot->letter_grade);
    }

    public function test_student_attendance_percentage_calculation(): void
    {
        $student = Student::factory()->create();
        $course = Course::factory()->create();

        // Create 10 attendance records: 8 present, 2 absent
        for ($i = 0; $i < 8; $i++) {
            $student->attendanceRecords()->create([
                'course_id' => $course->id,
                'attendance_date' => now()->subDays($i),
                'status' => 'present',
                'session_type' => 'lecture',
            ]);
        }

        for ($i = 0; $i < 2; $i++) {
            $student->attendanceRecords()->create([
                'course_id' => $course->id,
                'attendance_date' => now()->subDays($i + 10),
                'status' => 'absent',
                'session_type' => 'lecture',
            ]);
        }

        $this->assertEquals(80.00, $student->getAttendancePercentage());
    }
}
