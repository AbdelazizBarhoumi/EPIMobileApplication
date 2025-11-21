<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    /**
     * Display a listing of courses.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Course::with('academicCalendar');

        // Filter by semester
        if ($request->has('semester_id')) {
            $query->where('academic_calendar_id', $request->semester_id);
        }

        // Search by course code or name
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('course_code', 'LIKE', "%{$search}%")
                    ->orWhere('name', 'LIKE', "%{$search}%")
                    ->orWhere('instructor', 'LIKE', "%{$search}%");
            });
        }

        $courses = $query->orderBy('course_code')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $courses,
        ]);
    }

    /**
     * Display the specified course.
     */
    public function show(int $id): JsonResponse
    {
        $course = Course::with('academicCalendar')->find($id);

        if (!$course) {
            return response()->json([
                'success' => false,
                'message' => 'Course not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'course' => $course,
                'enrolled_count' => $course->enrolled_count,
                'average_grade' => $course->getAverageGrade(),
            ],
        ]);
    }

    /**
     * Get schedule for a specific semester.
     */
    public function schedule(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $courses = $student->enrolledCourses()
            ->with('academicCalendar')
            ->whereHas('academicCalendar', function ($query) {
                $query->where('status', 'active');
            })
            ->get();

        $schedule = $this->organizeSchedule($courses);

        return response()->json([
            'success' => true,
            'data' => $schedule,
        ]);
    }

    /**
     * Organize courses by day and time.
     */
    private function organizeSchedule($courses): array
    {
        $schedule = [
            'Monday' => [],
            'Tuesday' => [],
            'Wednesday' => [],
            'Thursday' => [],
            'Friday' => [],
            'Saturday' => [],
            'Sunday' => [],
        ];

        foreach ($courses as $course) {
            $scheduleDetails = $course->getScheduleDetails();
            $days = explode(',', $scheduleDetails['days']);

            foreach ($days as $day) {
                $day = trim($day);
                $dayMapping = [
                    'Mon' => 'Monday',
                    'Tue' => 'Tuesday',
                    'Wed' => 'Wednesday',
                    'Thu' => 'Thursday',
                    'Fri' => 'Friday',
                    'Sat' => 'Saturday',
                    'Sun' => 'Sunday',
                ];

                $fullDay = $dayMapping[$day] ?? null;

                if ($fullDay && isset($schedule[$fullDay])) {
                    $schedule[$fullDay][] = [
                        'course_code' => $course->course_code,
                        'name' => $course->name,
                        'time' => $scheduleDetails['time'],
                        'room' => $course->room,
                        'instructor' => $course->instructor,
                    ];
                }
            }
        }

        return $schedule;
    }
}
