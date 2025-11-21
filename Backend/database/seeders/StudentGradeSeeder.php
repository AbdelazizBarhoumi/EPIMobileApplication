<?php

namespace Database\Seeders;

use App\Models\Student;
use App\Models\Course;
use App\Models\StudentCourse;
use App\Models\ProgramCourse;
use Illuminate\Database\Seeder;

class StudentGradeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $students = Student::all();
        $courses = Course::all();

        if ($students->isEmpty() || $courses->isEmpty()) {
            return;
        }

        foreach ($students as $student) {
            // Enroll student in courses for their year level
            $programCourses = ProgramCourse::where('major_id', $student->major_id)
                ->where('year_level', '<=', $student->year_level)
                ->with('course')
                ->get();

            foreach ($programCourses as $programCourse) {
                // Determine if course is completed or enrolled
                $isCompleted = $programCourse->year_level < $student->year_level;
                
                $enrollment = StudentCourse::create([
                    'student_id' => $student->id,
                    'course_id' => $programCourse->course_id,
                    'program_course_id' => $programCourse->id,
                    'year_taken' => $programCourse->year_level,
                    'semester_taken' => $programCourse->semester,
                    'cc_weight' => $programCourse->cc_weight,
                    'ds_weight' => $programCourse->ds_weight,
                    'exam_weight' => $programCourse->exam_weight,
                    'cc_score' => $isCompleted ? rand(60, 100) : (rand(0, 100) > 30 ? rand(60, 95) : null),
                    'ds_score' => $isCompleted ? rand(60, 100) : (rand(0, 100) > 30 ? rand(60, 95) : null),
                    'exam_score' => $isCompleted ? rand(60, 100) : (rand(0, 100) > 30 ? rand(60, 95) : null),
                    'status' => $isCompleted ? 'completed' : 'enrolled',
                ]);

                // Trigger calculation
                $enrollment->save();
            }
        }
    }
}
