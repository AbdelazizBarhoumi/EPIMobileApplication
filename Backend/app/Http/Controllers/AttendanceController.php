<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use App\Models\StudentAttendance;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AttendanceController extends Controller
{
    /**
     * Get student's attendance records.
     */
    public function getMyAttendance(Request $request): JsonResponse
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
            ->where('year_taken', $student->year_level)
            ->with(['course', 'programCourse'])
            ->get();

        $attendanceData = [];

        foreach ($enrollments as $enrollment) {
            if ($enrollment->programCourse) {
                $courseAttendance = $student->getCourseAttendance($enrollment->course_id);
                
                $attendanceData[] = [
                    'course' => [
                        'id' => $enrollment->course->id,
                        'code' => $enrollment->course->course_code,
                        'name' => $enrollment->course->name,
                    ],
                    'attendance' => $courseAttendance,
                ];
            }
        }

        // Overall attendance
        $totalAttendance = $student->attendances()->count();
        $presentAttendance = $student->attendances()
            ->whereIn('status', ['present', 'late'])
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'student' => [
                    'name' => $student->name,
                    'student_id' => $student->student_id,
                ],
                'overall' => [
                    'total' => $totalAttendance,
                    'present' => $presentAttendance,
                    'percentage' => $totalAttendance > 0 
                        ? round(($presentAttendance / $totalAttendance) * 100, 2) 
                        : 0,
                ],
                'courses' => $attendanceData,
            ],
        ]);
    }

    /**
     * Get attendance records for a specific course.
     */
    public function getCourseAttendance(Request $request, int $courseId): JsonResponse
    {
        $student = $request->user()->student;

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found',
            ], 404);
        }

        // Get schedule IDs for this course
        $scheduleIds = Schedule::whereHas('programCourse', function ($query) use ($courseId) {
            $query->where('course_id', $courseId);
        })->pluck('id');

        $attendanceRecords = $student->attendances()
            ->whereIn('schedule_id', $scheduleIds)
            ->with(['schedule.programCourse.course', 'markedBy'])
            ->orderBy('date', 'desc')
            ->get();

        $summary = $student->getCourseAttendance($courseId);

        return response()->json([
            'success' => true,
            'data' => [
                'summary' => $summary,
                'records' => $attendanceRecords->map(function ($record) {
                    return [
                        'id' => $record->id,
                        'date' => $record->date->format('Y-m-d'),
                        'day' => $record->schedule->day_of_week,
                        'time_slot' => $record->schedule->time_slot,
                        'status' => $record->status,
                        'notes' => $record->notes,
                        'marked_by' => $record->markedBy ? $record->markedBy->name : null,
                    ];
                }),
            ],
        ]);
    }

    /**
     * Mark attendance (for teachers/admin).
     */
    public function markAttendance(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'student_id' => 'required|exists:students,id',
            'schedule_id' => 'required|exists:schedules,id',
            'date' => 'required|date',
            'status' => 'required|in:present,absent,late,excused',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $attendance = StudentAttendance::updateOrCreate(
            [
                'student_id' => $request->student_id,
                'schedule_id' => $request->schedule_id,
                'date' => $request->date,
            ],
            [
                'status' => $request->status,
                'notes' => $request->notes,
                'marked_by' => $request->user()->teacher->id ?? null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Attendance marked successfully',
            'data' => $attendance,
        ]);
    }

    /**
     * Bulk mark attendance for a class.
     */
    public function bulkMarkAttendance(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'schedule_id' => 'required|exists:schedules,id',
            'date' => 'required|date',
            'attendances' => 'required|array',
            'attendances.*.student_id' => 'required|exists:students,id',
            'attendances.*.status' => 'required|in:present,absent,late,excused',
            'attendances.*.notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $markedBy = $request->user()->teacher->id ?? null;
        $records = [];

        foreach ($request->attendances as $attendance) {
            $records[] = StudentAttendance::updateOrCreate(
                [
                    'student_id' => $attendance['student_id'],
                    'schedule_id' => $request->schedule_id,
                    'date' => $request->date,
                ],
                [
                    'status' => $attendance['status'],
                    'notes' => $attendance['notes'] ?? null,
                    'marked_by' => $markedBy,
                ]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Attendance marked successfully for ' . count($records) . ' students',
            'data' => $records,
        ]);
    }
}
