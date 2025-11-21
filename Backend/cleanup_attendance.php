<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\StudentAttendance;
use App\Models\Schedule;
use App\Models\Student;

echo "=== Cleaning Up Old Attendance Records ===\n\n";

$student = Student::find(1);

// Get valid schedule IDs for John Doe's courses
$validScheduleIds = [];
$enrollments = $student->studentCourses()
    ->where('year_taken', $student->year_level)
    ->with(['programCourse'])
    ->get();

foreach ($enrollments as $enrollment) {
    if ($enrollment->programCourse) {
        $schedules = Schedule::where('program_course_id', $enrollment->program_course_id)->pluck('id')->toArray();
        $validScheduleIds = array_merge($validScheduleIds, $schedules);
    }
}

echo "Valid schedule IDs for John Doe's courses: " . implode(', ', $validScheduleIds) . "\n\n";

// Count records with invalid schedule IDs
$invalidCount = StudentAttendance::where('student_id', 1)
    ->whereNotIn('schedule_id', $validScheduleIds)
    ->count();

echo "Records with invalid schedule IDs: $invalidCount\n";

if ($invalidCount > 0) {
    echo "Deleting invalid records...\n";
    StudentAttendance::where('student_id', 1)
        ->whereNotIn('schedule_id', $validScheduleIds)
        ->delete();
    echo "✓ Deleted $invalidCount invalid attendance records\n";
}

// Show final count
$finalCount = StudentAttendance::where('student_id', 1)->count();
echo "\nFinal attendance record count: $finalCount\n";

// Show breakdown by course
echo "\nAttendance by course:\n";
$enrollments = $student->studentCourses()
    ->where('year_taken', $student->year_level)
    ->with(['programCourse', 'course'])
    ->get();
    
foreach ($enrollments as $enrollment) {
    if ($enrollment->programCourse && $enrollment->course) {
        $schedules = Schedule::where('program_course_id', $enrollment->program_course_id)->pluck('id');
        $count = StudentAttendance::where('student_id', 1)
            ->whereIn('schedule_id', $schedules)
            ->count();
        
        $present = StudentAttendance::where('student_id', 1)
            ->whereIn('schedule_id', $schedules)
            ->whereIn('status', ['present', 'late'])
            ->count();
            
        $percentage = $count > 0 ? round(($present / $count) * 100, 2) : 0;
        
        echo "- {$enrollment->course->course_code} - {$enrollment->course->name}: ";
        echo "$count total, $present present ({$percentage}%)\n";
    }
}
