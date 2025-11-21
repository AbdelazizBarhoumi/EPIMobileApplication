<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "John Doe Student Data:\n";
$student = \App\Models\Student::where('name', 'John Doe')->first();

if ($student) {
    echo json_encode($student->toArray(), JSON_PRETTY_PRINT);
} else {
    echo "Student not found\n";
}