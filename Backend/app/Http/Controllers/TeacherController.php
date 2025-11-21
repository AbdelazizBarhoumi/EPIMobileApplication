<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use App\Models\Teacher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    /**
     * Get all teachers for student's current year.
     */
    public function getMyTeachers(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found',
            ], 404);
        }

        $teachers = $student->getCurrentYearTeachers();

        return response()->json([
            'success' => true,
            'data' => [
                'student' => [
                    'name' => $student->name,
                    'major' => $student->major->name,
                    'year_level' => $student->year_level,
                ],
                'teachers' => $teachers->map(function ($teacher) {
                    return [
                        'id' => $teacher->id,
                        'teacher_id' => $teacher->teacher_id,
                        'name' => $teacher->name,
                        'email' => $teacher->email,
                        'phone' => $teacher->phone,
                        'department' => $teacher->department,
                        'title' => $teacher->title,
                        'specialization' => $teacher->specialization,
                        'office_location' => $teacher->office_location,
                        'office_hours' => $teacher->office_hours,
                        'courses' => $teacher->programCourses->map(function ($pc) {
                            return [
                                'code' => $pc->course->course_code,
                                'name' => $pc->course->name,
                                'credits' => $pc->course->credits,
                                'semester' => $pc->semester,
                            ];
                        }),
                    ];
                }),
            ],
        ]);
    }

    /**
     * Get teacher details.
     */
    public function show(Teacher $teacher): JsonResponse
    {
        $teacher->load(['programCourses.course', 'programCourses.major']);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $teacher->id,
                'teacher_id' => $teacher->teacher_id,
                'name' => $teacher->name,
                'email' => $teacher->email,
                'phone' => $teacher->phone,
                'department' => $teacher->department,
                'title' => $teacher->title,
                'specialization' => $teacher->specialization,
                'bio' => $teacher->bio,
                'office_location' => $teacher->office_location,
                'office_hours' => $teacher->office_hours,
                'courses' => $teacher->programCourses->map(function ($pc) {
                    return [
                        'code' => $pc->course->course_code,
                        'name' => $pc->course->name,
                        'credits' => $pc->course->credits,
                        'major' => $pc->major->name,
                        'year_level' => $pc->year_level,
                        'semester' => $pc->semester,
                    ];
                }),
            ],
        ]);
    }

    /**
     * Get teacher's schedule.
     */
    public function getSchedule(Teacher $teacher): JsonResponse
    {
        $schedule = $teacher->getSchedule();

        $weeklySchedule = [];
        foreach (Schedule::getDaysOfWeek() as $day) {
            $weeklySchedule[$day] = $schedule->where('day_of_week', $day)->values()->map(function ($s) {
                return [
                    'time_slot' => $s->time_slot,
                    'start_time' => $s->start_time->format('H:i'),
                    'end_time' => $s->end_time->format('H:i'),
                    'course' => [
                        'code' => $s->programCourse->course->course_code,
                        'name' => $s->programCourse->course->name,
                        'major' => $s->programCourse->major->name,
                        'year' => $s->programCourse->year_level,
                        'semester' => $s->programCourse->semester,
                    ],
                    'room' => [
                        'code' => $s->room->room_code,
                        'name' => $s->room->name,
                        'type' => $s->room->type,
                    ],
                ];
            });
        }

        return response()->json([
            'success' => true,
            'data' => [
                'teacher' => [
                    'id' => $teacher->id,
                    'name' => $teacher->name,
                    'department' => $teacher->department,
                ],
                'schedule' => $weeklySchedule,
            ],
        ]);
    }
}
