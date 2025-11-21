<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Student;
use App\Models\StudentCourse;

$student = Student::find(1);

echo "John Doe's year_level: {$student->year_level}\n\n";

echo "All enrolled courses:\n";
$allEnrollments = $student->studentCourses()->with('course')->get();
foreach ($allEnrollments as $e) {
    echo "- {$e->course->course_code}: year_taken={$e->year_taken}\n";
}

echo "\n\nUpdating all courses to year_taken = {$student->year_level}...\n";

StudentCourse::where('student_id', 1)->update(['year_taken' => $student->year_level]);

echo "✓ Updated all courses\n\n";

echo "Verifying:\n";
$updated = $student->studentCourses()->with('course')->get();
foreach ($updated as $e) {
    echo "- {$e->course->course_code}: year_taken={$e->year_taken}\n";
}
