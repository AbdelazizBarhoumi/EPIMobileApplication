<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentController extends Controller
{
    /**
     * Display the authenticated student's profile.
     */
    public function profile(Request $request): JsonResponse
    {
        $student = $request->user()->student()->with([
            'major',
            'enrolledCourses',
            'clubs',
            'events'
        ])->first();

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'student' => $student,
                'attendance_percentage' => $student->getAttendancePercentage(),
                'outstanding_balance' => $student->outstanding_balance,
            ],
        ]);
    }

    /**
     * Get student dashboard data.
     */
    public function dashboard(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student not found',
            ], 404);
        }

        $currentCourses = $student->getCurrentSemesterCourses();
        $upcomingEvents = $student->events()
            ->where('event_date', '>', now())
            ->orderBy('event_date')
            ->limit(5)
            ->get();

        $pendingBills = $student->bills()
            ->where('status', 'pending')
            ->orderBy('due_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'profile' => [
                    'name' => $student->name,
                    'student_id' => $student->student_id,
                    'major' => $student->major,
                    'gpa' => $student->gpa,
                    'credits_taken' => $student->credits_taken,
                    'total_credits' => $student->total_credits,
                    'credits_progress' => $student->credits_progress_percentage,
                ],
                'financial' => [
                    'tuition_fees' => $student->tuition_fees,
                    'outstanding_balance' => $student->outstanding_balance,
                    'pending_bills_count' => $pendingBills->count(),
                ],
                'academic' => [
                    'current_courses_count' => $currentCourses->count(),
                    'attendance_percentage' => $student->getAttendancePercentage(),
                ],
                'upcoming_events' => $upcomingEvents,
                'pending_bills' => $pendingBills->take(3),
            ],
        ]);
    }

    /**
     * Get student's courses.
     */
    public function courses(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $courses = $student->courses()
            ->with('academicCalendar')
            ->get()
            ->map(function ($course) {
                return [
                    'id' => $course->id,
                    'course_code' => $course->course_code,
                    'name' => $course->name,
                    'instructor' => $course->instructor,
                    'credits' => $course->credits,
                    'schedule' => $course->schedule,
                    'room' => $course->room,
                    'semester' => $course->academicCalendar->name,
                    'grades' => [
                        'cc_score' => $course->pivot->cc_score,
                        'ds_score' => $course->pivot->ds_score,
                        'exam_score' => $course->pivot->exam_score,
                        'final_grade' => $course->pivot->final_grade,
                        'letter_grade' => $course->pivot->letter_grade,
                    ],
                    'status' => $course->pivot->status,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $courses,
        ]);
    }

    /**
     * Get student's attendance records.
     */
    public function attendance(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $courseId = $request->query('course_id');

        $query = $student->attendanceRecords()
            ->with('course');

        if ($courseId) {
            $query->where('course_id', $courseId);
        }

        $records = $query->orderBy('attendance_date', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $records,
            'overall_percentage' => $student->getAttendancePercentage(),
        ]);
    }
}
