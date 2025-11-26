# Backend Notification Integration Guide

## Overview
Currently, the notification system is **completely client-side** using Firebase Firestore. The Laravel backend has no API to send notifications to students. This guide explains how to integrate the backend with the Firebase notification system.

---

## Current Architecture

### Frontend (Flutter):
- **Repository**: `lib/features/notifications/data/repositories/notification_repository.dart`
- **Service**: `lib/core/services/firebase/firebase_notification_service.dart`
- **Firestore Path**: `notifications/{userId}/items/{notificationId}`
- **Notification Types**: payment, grade, event, schedule, club, general

### Backend (Laravel):
- ❌ **No notification endpoints exist**
- ✅ Laravel Notification system available but not configured for Firebase

---

## Integration Steps

### Step 1: Install Firebase Admin SDK for PHP

```bash
cd Backend
composer require kreait/firebase-php
```

### Step 2: Configure Firebase in Laravel

Create `config/firebase.php`:

```php
<?php

return [
    'credentials' => [
        'file' => env('FIREBASE_CREDENTIALS_PATH', storage_path('app/firebase-credentials.json')),
    ],
    'database' => [
        'url' => env('FIREBASE_DATABASE_URL'),
    ],
];
```

Add to `.env`:
```env
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

### Step 3: Create Firebase Service Provider

`app/Services/FirebaseService.php`:

```php
<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Firestore;

class FirebaseService
{
    protected $firestore;

    public function __construct()
    {
        $factory = (new Factory)
            ->withServiceAccount(config('firebase.credentials.file'));

        $this->firestore = $factory->createFirestore();
    }

    public function sendNotification(string $userId, array $notificationData)
    {
        $database = $this->firestore->database();
        
        $notificationRef = $database
            ->collection('notifications')
            ->document($userId)
            ->collection('items')
            ->newDocument();

        $notificationRef->set([
            'title' => $notificationData['title'],
            'message' => $notificationData['message'],
            'timestamp' => new \DateTime(),
            'type' => $notificationData['type'], // payment, grade, event, schedule, club, general
            'read' => false,
            'actionUrl' => $notificationData['actionUrl'] ?? null,
        ]);

        return $notificationRef->id();
    }

    public function sendBulkNotifications(array $userIds, array $notificationData)
    {
        $database = $this->firestore->database();
        $batch = $database->batch();

        foreach ($userIds as $userId) {
            $notificationRef = $database
                ->collection('notifications')
                ->document($userId)
                ->collection('items')
                ->newDocument();

            $batch->set($notificationRef, [
                'title' => $notificationData['title'],
                'message' => $notificationData['message'],
                'timestamp' => new \DateTime(),
                'type' => $notificationData['type'],
                'read' => false,
                'actionUrl' => $notificationData['actionUrl'] ?? null,
            ]);
        }

        $batch->commit();
    }
}
```

### Step 4: Create Notification Controller

`app/Http/Controllers/NotificationController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Services\FirebaseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class NotificationController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function send(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|string',
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'type' => 'required|in:payment,grade,event,schedule,club,general',
            'action_url' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'messages' => $validator->errors()
            ], 422);
        }

        try {
            $notificationId = $this->firebaseService->sendNotification(
                $request->user_id,
                [
                    'title' => $request->title,
                    'message' => $request->message,
                    'type' => $request->type,
                    'actionUrl' => $request->action_url,
                ]
            );

            return response()->json([
                'success' => true,
                'notification_id' => $notificationId,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Failed to send notification',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function sendBulk(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_ids' => 'required|array',
            'user_ids.*' => 'string',
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'type' => 'required|in:payment,grade,event,schedule,club,general',
            'action_url' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'messages' => $validator->errors()
            ], 422);
        }

        try {
            $this->firebaseService->sendBulkNotifications(
                $request->user_ids,
                [
                    'title' => $request->title,
                    'message' => $request->message,
                    'type' => $request->type,
                    'actionUrl' => $request->action_url,
                ]
            );

            return response()->json([
                'success' => true,
                'sent_to' => count($request->user_ids),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Failed to send notifications',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
```

### Step 5: Add API Routes

Add to `routes/api.php`:

```php
use App\Http\Controllers\NotificationController;

Route::middleware('auth:sanctum')->group(function () {
    // Send single notification
    Route::post('/notifications/send', [NotificationController::class, 'send']);
    
    // Send bulk notifications
    Route::post('/notifications/send-bulk', [NotificationController::class, 'sendBulk']);
});
```

---

## Usage Examples

### Example 1: Send Grade Notification

When a grade is posted:

```php
use App\Services\FirebaseService;

class GradeController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function store(Request $request)
    {
        // Store grade in database
        $grade = Grade::create([
            'student_id' => $request->student_id,
            'course_id' => $request->course_id,
            'grade' => $request->grade,
        ]);

        // Send notification to student
        $this->firebaseService->sendNotification(
            $request->student_id,
            [
                'title' => 'New Grade Posted',
                'message' => "Your grade for {$grade->course->name} has been posted: {$grade->grade}",
                'type' => 'grade',
                'actionUrl' => '/grades',
            ]
        );

        return response()->json($grade);
    }
}
```

### Example 2: Send Payment Reminder

```php
// Send to all students with unpaid bills
$studentsWithUnpaidBills = Student::whereHas('bills', function($query) {
    $query->where('status', 'unpaid');
})->pluck('firebase_uid')->toArray();

$this->firebaseService->sendBulkNotifications(
    $studentsWithUnpaidBills,
    [
        'title' => 'Payment Reminder',
        'message' => 'You have unpaid bills. Please pay by the due date.',
        'type' => 'payment',
        'actionUrl' => '/bills',
    ]
);
```

### Example 3: Send Event Notification

```php
// Notify all students about a new event
$allStudentIds = Student::pluck('firebase_uid')->toArray();

$this->firebaseService->sendBulkNotifications(
    $allStudentIds,
    [
        'title' => 'New Event: Career Fair',
        'message' => 'Join us for the annual career fair on Friday!',
        'type' => 'event',
        'actionUrl' => '/events',
    ]
);
```

---

## Important Considerations

### 1. User ID Mapping

The backend needs to know the Firebase UID for each student. Add a column to the students table:

```php
Schema::table('students', function (Blueprint $table) {
    $table->string('firebase_uid')->nullable()->unique();
});
```

Update this when students log in or register.

### 2. Push Notifications (Optional Enhancement)

To send push notifications along with in-app notifications, integrate FCM:

```php
use Kreait\Firebase\Messaging\CloudMessage;

public function sendWithPushNotification(string $userId, array $notificationData)
{
    // Send in-app notification
    $this->sendNotification($userId, $notificationData);
    
    // Get user's FCM token from Firestore
    $userDoc = $this->firestore->database()
        ->collection('users')
        ->document($userId)
        ->snapshot();
    
    $fcmToken = $userDoc->get('fcmToken');
    
    if ($fcmToken) {
        $messaging = $this->factory->createMessaging();
        $message = CloudMessage::withTarget('token', $fcmToken)
            ->withNotification([
                'title' => $notificationData['title'],
                'body' => $notificationData['message'],
            ])
            ->withData([
                'type' => $notificationData['type'],
                'action_url' => $notificationData['actionUrl'] ?? '',
            ]);
        
        $messaging->send($message);
    }
}
```

### 3. Testing

Test the notification system:

```bash
curl -X POST http://your-api.com/api/notifications/send \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "firebase_user_id_here",
    "title": "Test Notification",
    "message": "This is a test message",
    "type": "general",
    "action_url": null
  }'
```

---

## Security Considerations

1. **Authentication**: All notification endpoints MUST require authentication
2. **Authorization**: Verify the authenticated user has permission to send notifications
3. **Rate Limiting**: Implement rate limiting to prevent notification spam
4. **Validation**: Always validate and sanitize notification content
5. **Firebase Credentials**: Keep `firebase-credentials.json` secure and out of version control

---

## Next Steps

1. ✅ Install Firebase Admin SDK
2. ✅ Configure Firebase credentials
3. ✅ Create FirebaseService
4. ✅ Create NotificationController
5. ✅ Add API routes
6. ✅ Update student records with Firebase UIDs
7. ✅ Integrate notification sending into existing controllers
8. ✅ Test thoroughly
9. ⚠️ Deploy to production

---

## Current Status

- ❌ Backend integration not implemented
- ✅ Frontend notification system working
- ✅ Firebase Firestore structure defined
- ✅ FCM token storage implemented
- ⚠️ Waiting for backend implementation

---

## Contact

For questions or issues with this integration, refer to:
- Firebase Admin SDK Docs: https://firebase-php.readthedocs.io/
- Laravel Documentation: https://laravel.com/docs
- Project Architecture: `ARCHITECTURE.md`
