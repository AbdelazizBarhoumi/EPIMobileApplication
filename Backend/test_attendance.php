<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\StudentAttendance;

echo "Testing StudentAttendance model...\n";

try {
    $attendance = StudentAttendance::where('student_id', 1)->first();
    if ($attendance) {
        echo "✅ Found attendance record: ID {$attendance->id} for student {$attendance->student_id}\n";
        echo "   Date: {$attendance->date}, Status: {$attendance->status}\n";
    } else {
        echo "❌ No attendance records found for student 1\n";
    }

    // Also test count
    $count = StudentAttendance::where('student_id', 1)->count();
    echo "Total attendance records for student 1: {$count}\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}