<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Student;
use App\Models\ProgramCourse;
use App\Models\Schedule;

$student = Student::find(1);

echo "=== John Doe's All Enrolled Courses ===\n\n";

$enrollments = $student->studentCourses()->with(['course', 'programCourse'])->get();

echo "Total enrolled courses: {$enrollments->count()}\n\n";

foreach ($enrollments as $enrollment) {
    echo "Course: {$enrollment->course->course_code} - {$enrollment->course->name}\n";
    echo "  Course ID: {$enrollment->course_id}\n";
    echo "  Program Course ID: {$enrollment->program_course_id}\n";
    echo "  Has ProgramCourse: " . ($enrollment->programCourse ? 'Yes' : 'No') . "\n";
    
    if ($enrollment->programCourse) {
        $schedules = Schedule::where('program_course_id', $enrollment->program_course_id)->get();
        echo "  Schedules: " . $schedules->count() . " (" . $schedules->pluck('id')->implode(', ') . ")\n";
    }
    
    echo "\n";
}

echo "\n=== Creating Missing Schedules ===\n\n";

foreach ($enrollments as $enrollment) {
    if ($enrollment->programCourse) {
        $existingSchedules = Schedule::where('program_course_id', $enrollment->program_course_id)->count();
        
        if ($existingSchedules === 0) {
            echo "Creating schedules for {$enrollment->course->course_code}...\n";
            
            // Create 2 schedules per course (like the existing courses)
            Schedule::create([
                'program_course_id' => $enrollment->program_course_id,
                'day_of_week' => 'Monday',
                'time_slot' => 1,
                'room_id' => 1,
                'start_time' => '08:00',
                'end_time' => '09:30',
            ]);
            
            Schedule::create([
                'program_course_id' => $enrollment->program_course_id,
                'day_of_week' => 'Wednesday',
                'time_slot' => 2,
                'room_id' => 1,
                'start_time' => '10:00',
                'end_time' => '11:30',
            ]);
            
            echo "  ✓ Created 2 schedules\n";
        }
    }
}

echo "\n✅ Done! All courses now have schedules.\n";
