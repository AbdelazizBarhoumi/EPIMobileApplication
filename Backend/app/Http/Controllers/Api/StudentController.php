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

    /**
     * Get all students (for admin notifications)
     */
    public function index(Request $request): JsonResponse
    {
        $query = Student::with(['major', 'user']);

        // Filter by class_id if provided (using class field)
        if ($request->has('class_id') && $request->class_id) {
            $query->where('class', $request->class_id);
        }

        // Filter by major_id if provided
        if ($request->has('major_id') && $request->major_id) {
            $query->where('major_id', $request->major_id);
        }

        // Filter by year if provided (using year_level)
        if ($request->has('year') && $request->year) {
            $query->where('year_level', $request->year);
        }

        $students = $query->get()->map(function ($student) {
            return [
                'id' => $student->id,
                'student_id' => $student->student_id,
                'name' => $student->name,
                'full_name' => $student->name,
                'email' => $student->email,
                'phone' => $student->phone ?? null,
                'major' => [
                    'id' => $student->major?->id,
                    'name' => $student->major?->name,
                    'code' => $student->major?->code,
                    'department' => $student->major?->department,
                ],
                'major_id' => $student->major_id,
                'major_name' => $student->major?->name,
                'class_id' => $student->class ?? $student->year_level,
                'year' => $student->year_level,
                'semester' => $student->semester ?? null,
                'status' => $student->status ?? 'active',
                'enrollment_date' => $student->enrollment_date ?? $student->created_at,
                'user_id' => $student->user_id,
                'gpa' => $student->gpa,
                'year_level' => $student->year_level,
                'academic_year' => $student->academic_year,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $students,
            'count' => $students->count(),
            'filters_applied' => [
                'class_id' => $request->class_id,
                'major_id' => $request->major_id,
                'year' => $request->year,
            ],
        ]);
    }

    /**
     * Get a specific student (for admin notifications)
     */
    public function show(Request $request, $id): JsonResponse
    {
        $student = Student::with(['major', 'user', 'enrolledCourses', 'clubs', 'events'])
            ->find($id);

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $student->id,
                'student_id' => $student->student_id,
                'name' => $student->name,
                'full_name' => $student->name,
                'email' => $student->email,
                'phone' => $student->phone ?? null,
                'major' => [
                    'id' => $student->major?->id,
                    'name' => $student->major?->name,
                    'code' => $student->major?->code,
                    'department' => $student->major?->department,
                    'description' => $student->major?->description,
                ],
                'class_id' => $student->class ?? $student->year_level,
                'year' => $student->year_level,
                'semester' => $student->semester ?? null,
                'status' => $student->status ?? 'active',
                'enrollment_date' => $student->enrollment_date ?? $student->created_at,
                'gpa' => $student->gpa,
                'attendance_percentage' => method_exists($student, 'getAttendancePercentage') ? $student->getAttendancePercentage() : null,
                'outstanding_balance' => $student->outstanding_balance,
                'courses_count' => $student->enrolledCourses?->count() ?? 0,
                'clubs_count' => $student->clubs?->count() ?? 0,
                'events_count' => $student->events?->count() ?? 0,
                'academic_year' => $student->academic_year,
                'year_level' => $student->year_level,
                'credits_taken' => $student->credits_taken,
                'total_credits' => $student->total_credits,
                'user' => [
                    'id' => $student->user?->id,
                    'name' => $student->user?->name,
                    'email' => $student->user?->email,
                    'created_at' => $student->user?->created_at,
                ],
            ],
        ]);
    }
}
