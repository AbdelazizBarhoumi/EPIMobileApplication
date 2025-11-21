<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Schedule;
use App\Models\ProgramCourse;

echo "=== Schedule and ProgramCourse Mapping ===\n\n";

// Get schedule 1 and 2 (used in attendance)
$schedules = Schedule::with('programCourse.course')->whereIn('id', [1, 2])->get();

echo "Schedules used in attendance records:\n";
foreach ($schedules as $schedule) {
    echo "- Schedule ID: {$schedule->id}\n";
    echo "  Program Course ID: {$schedule->program_course_id}\n";
    if ($schedule->programCourse && $schedule->programCourse->course) {
        echo "  Course: {$schedule->programCourse->course->course_code} - {$schedule->programCourse->course->name}\n";
        echo "  Course ID: {$schedule->programCourse->course_id}\n";
    }
    echo "\n";
}

// Get schedules 17-20 (expected for John Doe's courses)
$expectedSchedules = Schedule::with('programCourse.course')->whereIn('id', [17, 18, 19, 20])->get();

echo "Schedules expected for CS301 and CS302:\n";
foreach ($expectedSchedules as $schedule) {
    echo "- Schedule ID: {$schedule->id}\n";
    echo "  Program Course ID: {$schedule->program_course_id}\n";
    if ($schedule->programCourse && $schedule->programCourse->course) {
        echo "  Course: {$schedule->programCourse->course->course_code} - {$schedule->programCourse->course->name}\n";
        echo "  Course ID: {$schedule->programCourse->course_id}\n";
    }
    echo "\n";
}

// Find which program_course IDs link to course 6 and 7
echo "ProgramCourses for CS301 (course_id=6) and CS302 (course_id=7):\n";
$programCourses = ProgramCourse::whereIn('course_id', [6, 7])->with('course')->get();
foreach ($programCourses as $pc) {
    echo "- ProgramCourse ID: {$pc->id}, Course: {$pc->course->course_code} - {$pc->course->name}\n";
    
    $schedules = Schedule::where('program_course_id', $pc->id)->get();
    echo "  Schedules: " . $schedules->pluck('id')->implode(', ') . "\n";
}
