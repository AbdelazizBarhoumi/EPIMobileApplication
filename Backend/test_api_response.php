<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Simulate the API call
$user = \App\Models\User::find(7); // John Doe's user
if ($user) {
    $request = new \Illuminate\Http\Request();
    $request->setUserResolver(function () use ($user) {
        return $user;
    });

    $controller = new \App\Http\Controllers\Api\StudentController();
    $response = $controller->profile($request);

    echo "API Response:\n";
    echo $response->getContent();
} else {
    echo "User not found\n";
}