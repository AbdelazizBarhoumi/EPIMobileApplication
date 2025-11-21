<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$student = \App\Models\Student::find(1);
echo "Raw student data:\n";
print_r($student->toArray());

echo "\n\nJSON response:\n";
echo json_encode($student->toArray(), JSON_PRETTY_PRINT);