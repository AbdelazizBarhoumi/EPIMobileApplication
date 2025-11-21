<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Student;
use App\Models\Schedule;

echo "=== Checking John Doe's Attendance Data ===\n\n";

$student = Student::find(1);
if (!$student) {
    echo "Student not found!\n";
    exit(1);
}

echo "Student: {$student->name} ({$student->student_id})\n\n";

// Check total attendance
$totalAttendance = $student->attendances()->count();
echo "Total attendance records: $totalAttendance\n\n";

// Check enrolled courses
echo "Enrolled courses:\n";
$enrollments = $student->studentCourses()
    ->where('year_taken', $student->year_level)
    ->with(['course', 'programCourse'])
    ->get();

foreach ($enrollments as $enrollment) {
    echo "- {$enrollment->course->course_code} - {$enrollment->course->name}\n";
    echo "  Course ID: {$enrollment->course_id}\n";
    echo "  Has ProgramCourse: " . ($enrollment->programCourse ? 'Yes' : 'No') . "\n";
    
    if ($enrollment->programCourse) {
        // Try to find schedules for this course
        $scheduleIds = Schedule::whereHas('programCourse', function ($query) use ($enrollment) {
            $query->where('course_id', $enrollment->course_id);
        })->pluck('id');
        
        echo "  Schedule IDs found: " . $scheduleIds->count() . " (" . $scheduleIds->implode(', ') . ")\n";
        
        // Check attendance for these schedules
        $attendanceCount = $student->attendances()
            ->whereIn('schedule_id', $scheduleIds)
            ->count();
        echo "  Attendance records: $attendanceCount\n";
    }
    
    echo "\n";
}

// Check sample attendance records
echo "\nSample attendance records (first 5):\n";
$sampleRecords = $student->attendances()->with('schedule')->limit(5)->get();
foreach ($sampleRecords as $record) {
    echo "- Date: {$record->date}, Status: {$record->status}, Schedule ID: {$record->schedule_id}\n";
    if ($record->schedule) {
        echo "  Schedule info: " . json_encode($record->schedule->toArray()) . "\n";
    }
}
