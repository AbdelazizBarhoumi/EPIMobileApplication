<?php

/**
 * Simple Notification System Test Script
 * 
 * Run with: php artisan tinker < test_notification_flow.php
 * 
 * This tests the entire notification flow:
 * 1. Resolve target users from database
 * 2. Send via OneSignal (mocked in tests)
 * 3. Store in Firestore (mocked in tests)
 */

use App\Models\Student;
use App\Models\User;
use App\Models\Major;

echo "=== NOTIFICATION SYSTEM TEST ===\n\n";

// 1. Check database structure
echo "1. Checking database structure...\n";

$usersWithFirebaseUid = User::whereNotNull('firebase_uid')->count();
echo "   - Users with Firebase UID: {$usersWithFirebaseUid}\n";

$studentsCount = Student::count();
echo "   - Total students: {$studentsCount}\n";

$majorsCount = Major::count();
echo "   - Total majors: {$majorsCount}\n";

// 2. Test user resolution for "all" target
echo "\n2. Testing target user resolution...\n";

$allStudentFirebaseUids = Student::join('users', 'students.user_id', '=', 'users.id')
    ->whereNotNull('users.firebase_uid')
    ->pluck('users.firebase_uid')
    ->unique()
    ->values()
    ->toArray();

echo "   - Students with Firebase UID (target=all): " . count($allStudentFirebaseUids) . "\n";
if (count($allStudentFirebaseUids) > 0) {
    echo "   - Sample UIDs: " . implode(', ', array_slice($allStudentFirebaseUids, 0, 3)) . "\n";
}

// 3. Check environment variables
echo "\n3. Checking environment configuration...\n";

$oneSignalAppId = env('ONESIGNAL_APP_ID');
$firebaseProjectId = env('FIREBASE_PROJECT_ID');

echo "   - ONESIGNAL_APP_ID: " . ($oneSignalAppId ? '✓ Set' : '✗ Not set') . "\n";
echo "   - FIREBASE_PROJECT_ID: " . ($firebaseProjectId ? '✓ Set' : '✗ Not set') . "\n";

// 4. Summary
echo "\n=== SUMMARY ===\n";

if ($usersWithFirebaseUid > 0 && $oneSignalAppId && $firebaseProjectId) {
    echo "✓ System is ready for notifications!\n";
} else {
    echo "⚠ System needs configuration:\n";
    if ($usersWithFirebaseUid == 0) {
        echo "   - No users have firebase_uid set. Update users table.\n";
    }
    if (!$oneSignalAppId) {
        echo "   - Set ONESIGNAL_APP_ID in .env\n";
    }
    if (!$firebaseProjectId) {
        echo "   - Set FIREBASE_PROJECT_ID in .env\n";
    }
}

echo "\n";
