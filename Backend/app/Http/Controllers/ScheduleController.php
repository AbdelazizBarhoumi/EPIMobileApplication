<?php

namespace App\Http\Controllers;

use App\Models\Major;
use App\Models\Schedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    /**
     * Get weekly schedule for a major, year, and semester.
     */
    public function getWeeklySchedule(Major $major, int $year, int $semester): JsonResponse
    {
        if ($year < 1 || $year > $major->duration_years) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid year level for this major',
            ], 400);
        }

        if ($semester < 1 || $semester > 2) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid semester (must be 1 or 2)',
            ], 400);
        }

        // Get all program courses for this major/year/semester
        $programCourses = $major->courses()
            ->wherePivot('year_level', $year)
            ->wherePivot('semester', $semester)
            ->with(['schedules' => function ($query) {
                $query->orderBy('day_of_week')->orderBy('time_slot');
            }])
            ->get();

        // Build weekly schedule grid
        $weeklySchedule = [];
        $days = Schedule::getDaysOfWeek();
        $timeSlots = Schedule::getTimeSlots();

        foreach ($days as $day) {
            $weeklySchedule[$day] = [];
            
            foreach ($timeSlots as $slot => $times) {
                $weeklySchedule[$day][$slot] = [
                    'time_slot' => $slot,
                    'start_time' => $times['start'],
                    'end_time' => $times['end'],
                    'course' => null,
                ];
            }
        }

        // Fill in scheduled courses
        foreach ($programCourses as $course) {
            $pivot = $course->pivot;
            
            foreach ($course->schedules as $schedule) {
                $day = $schedule->day_of_week;
                $slot = $schedule->time_slot;
                
                if (isset($weeklySchedule[$day][$slot])) {
                    $weeklySchedule[$day][$slot]['course'] = [
                        'id' => $course->id,
                        'code' => $course->course_code,
                        'name' => $course->name,
                        'instructor' => $course->instructor,
                        'room' => $schedule->room ?? $course->room,
                        'credits' => $course->credits,
                        'is_required' => $pivot->is_required,
                        'cc_weight' => $pivot->cc_weight,
                        'ds_weight' => $pivot->ds_weight,
                        'exam_weight' => $pivot->exam_weight,
                    ];
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'major' => [
                    'id' => $major->id,
                    'code' => $major->code,
                    'name' => $major->name,
                ],
                'year' => $year,
                'semester' => $semester,
                'schedule' => $weeklySchedule,
                'time_slots' => $timeSlots,
            ],
        ]);
    }

    /**
     * Get schedule for a specific student based on their enrollments.
     */
    public function getStudentSchedule(Request $request): JsonResponse
    {
        $student = $request->user()->student;
        
        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found',
            ], 404);
        }

        // Get current semester enrollments
        $enrollments = $student->studentCourses()
            ->where('status', 'enrolled')
            ->where('year_taken', $student->year_level)
            ->with(['course', 'programCourse.schedules.room'])
            ->get();

        // Build weekly schedule
        $weeklySchedule = [];
        $days = Schedule::getDaysOfWeek();
        $timeSlots = Schedule::getTimeSlots();

        foreach ($days as $day) {
            $weeklySchedule[$day] = [];
            
            foreach ($timeSlots as $slot => $times) {
                $weeklySchedule[$day][$slot] = [
                    'time_slot' => $slot,
                    'start_time' => $times['start'],
                    'end_time' => $times['end'],
                    'course' => null,
                ];
            }
        }

        // Fill in student's courses
        foreach ($enrollments as $enrollment) {
            if ($enrollment->programCourse) {
                foreach ($enrollment->programCourse->schedules as $schedule) {
                    $day = $schedule->day_of_week;
                    $slot = $schedule->time_slot;
                    
                    if (isset($weeklySchedule[$day][$slot])) {
                        $weeklySchedule[$day][$slot]['course'] = [
                            'id' => $enrollment->course->id,
                            'code' => $enrollment->course->course_code,
                            'name' => $enrollment->course->name,
                            'instructor' => $enrollment->course->instructor,
                            'room' => $schedule->room?->name ?? $enrollment->course->room ?? 'TBA',
                            'credits' => $enrollment->course->credits,
                            'cc_score' => $enrollment->cc_score,
                            'ds_score' => $enrollment->ds_score,
                            'exam_score' => $enrollment->exam_score,
                            'final_grade' => $enrollment->final_grade,
                        ];
                    }
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'student' => [
                    'id' => $student->id,
                    'student_id' => $student->student_id,
                    'name' => $student->name,
                    'major' => $student->major->name,
                    'year_level' => $student->year_level,
                ],
                'schedule' => $weeklySchedule,
                'time_slots' => $timeSlots,
            ],
        ]);
    }
}
