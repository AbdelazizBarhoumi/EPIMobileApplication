<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Student;

$student = Student::where('student_id', '109800001')->first();
echo 'Student: ' . $student->name . PHP_EOL;
echo 'Year level: ' . $student->year_level . PHP_EOL;

$courses = $student->studentCourses()->where('year_taken', $student->year_level)->with('course')->get();
echo 'Courses: ' . $courses->count() . PHP_EOL;

foreach($courses as $enrollment) {
    echo 'Course: ' . $enrollment->course->course_code . ' - ' . $enrollment->course->name . PHP_EOL;
    $attendance = $student->getCourseAttendance($enrollment->course_id);
    echo '  Attendance: total=' . $attendance['total'] . ', present=' . $attendance['present'] . ', percentage=' . $attendance['percentage'] . PHP_EOL;
}

// Also check total attendance
$totalAttendance = $student->attendances()->count();
$presentAttendance = $student->attendances()->whereIn('status', ['present', 'late'])->count();
echo PHP_EOL . 'Overall attendance: total=' . $totalAttendance . ', present=' . $presentAttendance . PHP_EOL;