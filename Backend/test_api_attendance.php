<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Student;

$student = Student::find(1);

// Simulate the API response
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

$response = [
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
];

echo json_encode($response, JSON_PRETTY_PRINT);
