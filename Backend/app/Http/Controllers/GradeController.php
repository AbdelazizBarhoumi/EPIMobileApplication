<?php

namespace App\Http\Controllers;

use App\Models\Student;
use App\Models\StudentCourse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class GradeController extends Controller
{
    /**
     * Get full transcript for a student (all years).
     */
    public function transcript(Student $student): JsonResponse
    {
        $transcript = $student->getFullTranscript();
        
        // Group by year and semester
        $groupedTranscript = $transcript->groupBy(['year_taken', 'semester_taken']);
        
        $formattedTranscript = [];
        foreach ($groupedTranscript as $year => $semesters) {
            $yearData = [
                'year' => $year,
                'semesters' => [],
                'year_gpa' => $student->calculateYearGPA($year),
            ];
            
            foreach ($semesters as $semester => $courses) {
                $yearData['semesters'][] = [
                    'semester' => $semester,
                    'courses' => $courses->map(function ($enrollment) {
                        return [
                            'course_code' => $enrollment->course->course_code,
                            'course_name' => $enrollment->course->name,
                            'credits' => $enrollment->course->credits,
                            'cc_score' => $enrollment->cc_score,
                            'ds_score' => $enrollment->ds_score,
                            'exam_score' => $enrollment->exam_score,
                            'cc_weight' => $enrollment->cc_weight,
                            'ds_weight' => $enrollment->ds_weight,
                            'exam_weight' => $enrollment->exam_weight,
                            'final_grade' => $enrollment->final_grade,
                            'letter_grade' => $enrollment->letter_grade,
                            'status' => $enrollment->status,
                        ];
                    }),
                    'semester_credits' => $courses->sum(fn($c) => $c->course->credits),
                ];
            }
            
            $formattedTranscript[] = $yearData;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'student' => [
                    'id' => $student->id,
                    'student_id' => $student->student_id,
                    'name' => $student->name,
                    'major' => $student->major->name ?? null,
                    'current_year' => $student->year_level,
                ],
                'transcript' => $formattedTranscript,
                'overall_gpa' => $student->calculateOverallGPA(),
                'credits_taken' => $student->credits_taken,
                'credits_remaining' => $student->total_credits - $student->credits_taken,
            ],
        ]);
    }

    /**
     * Get transcript for a specific year.
     */
    public function transcriptByYear(Student $student, int $year): JsonResponse
    {
        $transcript = $student->getTranscriptByYear($year);
        
        // Group by semester
        $groupedTranscript = $transcript->groupBy('semester_taken');
        
        $formattedSemesters = [];
        foreach ($groupedTranscript as $semester => $courses) {
            $formattedSemesters[] = [
                'semester' => $semester,
                'courses' => $courses->map(function ($enrollment) {
                    return [
                        'course_code' => $enrollment->course->course_code,
                        'course_name' => $enrollment->course->name,
                        'credits' => $enrollment->course->credits,
                        'cc_score' => $enrollment->cc_score,
                        'ds_score' => $enrollment->ds_score,
                        'exam_score' => $enrollment->exam_score,
                        'final_grade' => $enrollment->final_grade,
                        'letter_grade' => $enrollment->letter_grade,
                        'status' => $enrollment->status,
                    ];
                }),
                'semester_credits' => $courses->sum(fn($c) => $c->course->credits),
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'student' => $student->name,
                'year' => $year,
                'semesters' => $formattedSemesters,
                'year_gpa' => $student->calculateYearGPA($year),
            ],
        ]);
    }

    /**
     * Get grades for current semester.
     */
    public function currentSemester(Student $student): JsonResponse
    {
        $currentYear = $student->year_level;
        
        // Get current academic calendar to determine semester
        $currentCalendar = \App\Models\AcademicCalendar::where('status', 'active')->first();
        $currentSemester = $currentCalendar ? (str_contains($currentCalendar->semester, 'Fall') ? 1 : 2) : 1;
        
        $grades = $student->getTranscriptByYearAndSemester($currentYear, $currentSemester);

        return response()->json([
            'success' => true,
            'data' => [
                'student' => $student->name,
                'current_year' => $currentYear,
                'current_semester' => $currentSemester,
                'courses' => $grades->map(function ($enrollment) {
                    return [
                        'course_code' => $enrollment->course->course_code,
                        'course_name' => $enrollment->course->name,
                        'credits' => $enrollment->course->credits,
                        'cc_score' => $enrollment->cc_score,
                        'ds_score' => $enrollment->ds_score,
                        'exam_score' => $enrollment->exam_score,
                        'cc_weight' => $enrollment->cc_weight,
                        'ds_weight' => $enrollment->ds_weight,
                        'exam_weight' => $enrollment->exam_weight,
                        'final_grade' => $enrollment->final_grade,
                        'letter_grade' => $enrollment->letter_grade,
                        'status' => $enrollment->status,
                    ];
                }),
            ],
        ]);
    }

    /**
     * Update grades for a student's course enrollment.
     */
    public function updateGrades(Request $request, Student $student, int $courseId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'cc_score' => 'nullable|numeric|min:0|max:100',
            'ds_score' => 'nullable|numeric|min:0|max:100',
            'exam_score' => 'nullable|numeric|min:0|max:100',
            'status' => 'sometimes|in:enrolled,completed,dropped',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $enrollment = StudentCourse::where('student_id', $student->id)
            ->where('course_id', $courseId)
            ->first();

        if (!$enrollment) {
            return response()->json([
                'success' => false,
                'message' => 'Enrollment not found',
            ], 404);
        }

        $enrollment->update($request->only(['cc_score', 'ds_score', 'exam_score', 'status']));
        
        // Reload to get calculated final grade
        $enrollment->refresh();

        return response()->json([
            'success' => true,
            'message' => 'Grades updated successfully',
            'data' => [
                'cc_score' => $enrollment->cc_score,
                'ds_score' => $enrollment->ds_score,
                'exam_score' => $enrollment->exam_score,
                'final_grade' => $enrollment->final_grade,
                'letter_grade' => $enrollment->letter_grade,
                'status' => $enrollment->status,
            ],
        ]);
    }

    /**
     * Get GPA statistics for a student.
     */
    public function gpaStats(Student $student): JsonResponse
    {
        $overallGpa = $student->calculateOverallGPA();
        
        $gpaByYear = [];
        for ($year = 1; $year <= $student->year_level; $year++) {
            $gpaByYear[$year] = $student->calculateYearGPA($year);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'student' => [
                    'id' => $student->id,
                    'student_id' => $student->student_id,
                    'name' => $student->name,
                ],
                'overall_gpa' => $overallGpa,
                'gpa_by_year' => $gpaByYear,
                'credits_taken' => $student->credits_taken,
                'total_credits' => $student->total_credits,
                'progress_percentage' => $student->credits_progress_percentage,
            ],
        ]);
    }
}
