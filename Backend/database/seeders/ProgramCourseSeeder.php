<?php

namespace Database\Seeders;

use App\Models\Major;
use App\Models\Course;
use App\Models\ProgramCourse;
use App\Models\Teacher;
use Illuminate\Database\Seeder;

class ProgramCourseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $csMajor = Major::where('code', 'CS')->first();
        $courses = Course::all();
        $teachers = Teacher::all();

        if (!$csMajor || $courses->isEmpty() || $teachers->isEmpty()) {
            return;
        }

        // Assign teachers to specific specializations
        $sarahJohnson = $teachers->where('name', 'Dr. Sarah Johnson')->first(); // Programming, Software Eng
        $emilyRodriguez = $teachers->where('name', 'Dr. Emily Rodriguez')->first(); // Math
        $michaelChen = $teachers->where('name', 'Dr. Michael Chen')->first(); // Data Structures, OOP
        $davidWilliams = $teachers->where('name', 'Prof. David Williams')->first(); // Networks
        $jenniferLee = $teachers->where('name', 'Dr. Jennifer Lee')->first(); // Databases

        // CS Year 1, Semester 1
        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS101')->first()?->id ?? $courses->random()->id,
            'year_level' => 1,
            'semester' => 1,
            'is_required' => true,
            'cc_weight' => 40,
            'ds_weight' => 20,
            'exam_weight' => 40,
            'teacher_id' => $sarahJohnson?->id,
        ]);

        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'MATH101')->first()?->id ?? $courses->random()->id,
            'year_level' => 1,
            'semester' => 1,
            'is_required' => true,
            'cc_weight' => 35,
            'ds_weight' => 25,
            'exam_weight' => 40,
            'teacher_id' => $emilyRodriguez?->id,
        ]);

        // CS Year 1, Semester 2
        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS102')->first()?->id ?? $courses->random()->id,
            'year_level' => 1,
            'semester' => 2,
            'is_required' => true,
            'cc_weight' => 40,
            'ds_weight' => 20,
            'exam_weight' => 40,
            'teacher_id' => $michaelChen?->id,
        ]);

        // CS Year 2, Semester 1
        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS201')->first()?->id ?? $courses->random()->id,
            'year_level' => 2,
            'semester' => 1,
            'is_required' => true,
            'cc_weight' => 30,
            'ds_weight' => 30,
            'exam_weight' => 40,
            'teacher_id' => $michaelChen?->id,
        ]);

        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS202')->first()?->id ?? $courses->random()->id,
            'year_level' => 2,
            'semester' => 1,
            'is_required' => true,
            'cc_weight' => 40,
            'ds_weight' => 20,
            'exam_weight' => 40,
            'teacher_id' => $sarahJohnson?->id,
        ]);

        // CS Year 2, Semester 2
        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS203')->first()?->id ?? $courses->random()->id,
            'year_level' => 2,
            'semester' => 2,
            'is_required' => true,
            'cc_weight' => 35,
            'ds_weight' => 25,
            'exam_weight' => 40,
            'teacher_id' => $davidWilliams?->id,
        ]);

        // CS Year 3, Semester 1
        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS301')->first()?->id ?? $courses->random()->id,
            'year_level' => 3,
            'semester' => 1,
            'is_required' => true,
            'cc_weight' => 30,
            'ds_weight' => 30,
            'exam_weight' => 40,
            'teacher_id' => $sarahJohnson?->id,
        ]);

        ProgramCourse::create([
            'major_id' => $csMajor->id,
            'course_id' => $courses->where('course_code', 'CS302')->first()?->id ?? $courses->random()->id,
            'year_level' => 3,
            'semester' => 1,
            'is_required' => true,
            'cc_weight' => 40,
            'ds_weight' => 20,
            'exam_weight' => 40,
            'teacher_id' => $jenniferLee?->id,
        ]);
    }
}
