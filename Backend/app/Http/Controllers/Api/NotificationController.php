<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * Simplified Notification Controller
 * 
 * Architecture:
 * - OneSignal: Handles push notification delivery (FCM/APNs internally)
 * - Firestore: Stores notification history for students to view in-app
 * - NO MySQL: Not needed for notifications
 * 
 * Security: API keys stay in backend, never exposed to frontend
 */
class NotificationController extends Controller
{
    /**
     * Send notification to students
     * 
     * Flow:
     * 1. Resolve target users from MySQL (students table)
     * 2. Send push via OneSignal REST API
     * 3. Store in Firestore for notification history page
     */
    public function send(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'type' => 'required|in:exam,payment,grade,event,schedule,announcement,club,general',
            'priority' => 'nullable|in:critical,high,medium,low',
            'target_type' => 'required|in:individual,class,all',
            'target_users' => 'nullable|array',
            'target_classes' => 'nullable|array',
            'sender_id' => 'required|string',
            'sender_name' => 'required|string',
            'metadata' => 'nullable|array',
            'expiry_date' => 'nullable|date',
        ]);

        try {
            $targetUserIds = $this->resolveTargetUsers($validated);
            
            if (empty($targetUserIds)) {
                return response()->json([
                    'success' => false,
                    'message' => 'No target users found',
                ], 400);
            }

            $notificationId = 'notif_' . Str::uuid();
            $priority = $validated['priority'] ?? $this->getDefaultPriority($validated['type']);

            // 1. Send push notification via OneSignal
            $pushResult = $this->sendViaOneSignal($validated, $targetUserIds, $priority);

            // 2. Store in Firestore for notification history
            $firestoreResult = $this->storeInFirestore($notificationId, $validated, $targetUserIds, $priority);

            return response()->json([
                'success' => true,
                'message' => 'Notification sent successfully',
                'notification_id' => $notificationId,
                'recipients' => count($targetUserIds),
                'push_sent' => $pushResult['success'] ?? false,
                'stored_in_firestore' => $firestoreResult,
            ], 201);

        } catch (\Exception $e) {
            Log::error('Failed to send notification', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send notification',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Resolve target user IDs from MySQL students table
     * 
     * Returns MySQL students.id values for use with OneSignal and Firestore.
     * Refactor: Simplified architecture - use MySQL student.id directly as Firestore document key
     * This eliminates the need for firebase_uid column and ensures immediate functionality.
     */
    private function resolveTargetUsers(array $data): array
    {
        return match ($data['target_type']) {
            // For individual targeting, accept either students.id or students.student_id
            'individual' => Student::where(function ($query) use ($data) {
                    $query->whereIn('id', $data['target_users'] ?? [])
                        ->orWhereIn('student_id', $data['target_users'] ?? []);
                })
                ->pluck('id')
                ->unique()
                ->map(fn($id) => (string) $id)
                ->values()
                ->toArray(),
            'class' => Student::join('majors', 'students.major_id', '=', 'majors.id')
                ->whereIn('majors.name', $data['target_classes'] ?? [])
                ->pluck('students.id')
                ->unique()
                ->map(fn($id) => (string) $id)
                ->values()
                ->toArray(),
            'all' => Student::pluck('id')
                ->unique()
                ->map(fn($id) => (string) $id)
                ->values()
                ->toArray(),
            default => [],
        };
    }

    /**
     * Send push notification via OneSignal REST API
     */
    private function sendViaOneSignal(array $data, array $userIds, string $priority): array
    {
        $appId = env('ONESIGNAL_APP_ID');
        $restApiKey = env('ONESIGNAL_REST_API_KEY');

        if (!$appId || !$restApiKey) {
            Log::warning('OneSignal credentials not configured');
            return ['success' => false, 'error' => 'OneSignal not configured'];
        }

        $payload = [
            'app_id' => $appId,
            'include_external_user_ids' => $userIds,
            'headings' => ['en' => $data['title']],
            'contents' => ['en' => $data['message']],
            'data' => [
                'type' => $data['type'],
                'priority' => $priority,
                'sender_id' => $data['sender_id'],
                'sender_name' => $data['sender_name'],
                'metadata' => $data['metadata'] ?? [],
            ],
            'priority' => in_array($priority, ['critical', 'high']) ? 10 : 5,
            // Removed android_channel_id - not configured in OneSignal dashboard
        ];

        if (!empty($data['expiry_date'])) {
            $payload['ttl'] = max(0, strtotime($data['expiry_date']) - time());
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $restApiKey,
                'Content-Type' => 'application/json',
            ])->post('https://onesignal.com/api/v1/notifications', $payload);

            $result = $response->json();

            if ($response->successful()) {
                Log::info('OneSignal notification sent', [
                    'recipients' => $result['recipients'] ?? 0,
                ]);
                return ['success' => true, 'recipients' => $result['recipients'] ?? 0];
            }

            Log::error('OneSignal API error', ['response' => $result]);
            return ['success' => false, 'error' => $result['errors'] ?? 'Unknown error'];

        } catch (\Exception $e) {
            Log::error('OneSignal request failed', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Store notification in Firestore for each target user
     * Path: notifications/{userId}/items/{notificationId}
     */
    private function storeInFirestore(string $notificationId, array $data, array $userIds, string $priority): bool
    {
        $projectId = env('FIREBASE_PROJECT_ID');

        if (!$projectId) {
            Log::warning('Firebase project ID not configured');
            return false;
        }

        $notificationData = [
            'fields' => [
                'id' => ['stringValue' => $notificationId],
                'title' => ['stringValue' => $data['title']],
                'message' => ['stringValue' => $data['message']],
                'type' => ['stringValue' => $data['type']],
                'priority' => ['stringValue' => $priority],
                'read' => ['booleanValue' => false],
                'senderId' => ['stringValue' => $data['sender_id']],
                'senderName' => ['stringValue' => $data['sender_name']],
                'timestamp' => ['timestampValue' => now()->toIso8601String()],
            ],
        ];

        if (!empty($data['metadata'])) {
            $notificationData['fields']['metadata'] = [
                'mapValue' => ['fields' => $this->toFirestoreMap($data['metadata'])]
            ];
        }

        if (!empty($data['expiry_date'])) {
            $notificationData['fields']['expiryDate'] = ['timestampValue' => $data['expiry_date']];
        }

        $baseUrl = "https://firestore.googleapis.com/v1/projects/{$projectId}/databases/(default)/documents";
        $successCount = 0;

        foreach ($userIds as $userId) {
            try {
                $documentPath = "notifications/{$userId}/items";
                $response = Http::post("{$baseUrl}/{$documentPath}", $notificationData);
                
                if ($response->successful()) {
                    $successCount++;
                    Log::info("Firestore write success for user {$userId}");
                } else {
                    Log::error("Firestore write failed for user {$userId}", [
                        'status' => $response->status(),
                        'body' => $response->body(),
                    ]);
                }
            } catch (\Exception $e) {
                Log::warning("Firestore write exception for user {$userId}", ['error' => $e->getMessage()]);
            }
        }

        Log::info('Firestore notifications stored', ['success' => $successCount, 'total' => count($userIds)]);
        return $successCount > 0;
    }

    /**
     * Convert PHP array to Firestore map format
     */
    private function toFirestoreMap(array $data): array
    {
        $fields = [];
        foreach ($data as $key => $value) {
            $fields[$key] = match (true) {
                is_string($value) => ['stringValue' => $value],
                is_int($value) => ['integerValue' => (string) $value],
                is_bool($value) => ['booleanValue' => $value],
                is_array($value) => ['mapValue' => ['fields' => $this->toFirestoreMap($value)]],
                default => ['stringValue' => (string) $value],
            };
        }
        return $fields;
    }

    /**
     * Get default priority based on notification type
     */
    private function getDefaultPriority(string $type): string
    {
        return match ($type) {
            'exam', 'payment' => 'critical',
            'grade', 'schedule' => 'high',
            'event', 'announcement' => 'medium',
            default => 'low',
        };
    }

    /**
     * Get Android notification channel ID
     */
    private function getAndroidChannel(string $priority): string
    {
        return match ($priority) {
            'critical' => 'critical_notifications',
            'high' => 'high_priority_notifications',
            default => 'default_notifications',
        };
    }

    /**
     * Get notification templates (admin helper)
     */
    public function templates()
    {
        return response()->json([
            'exam_announcement' => [
                'title' => '📝 Exam: {exam_name}',
                'message' => 'Exam on {exam_date} at {exam_time} in {location}',
                'type' => 'exam',
                'priority' => 'critical',
            ],
            'payment_due' => [
                'title' => '💳 Payment Due: {amount}',
                'message' => 'Payment of {amount} due on {due_date}',
                'type' => 'payment',
                'priority' => 'high',
            ],
            'grade_posted' => [
                'title' => '📊 Grade Posted: {course_name}',
                'message' => 'Your grade for {course_name} is now available',
                'type' => 'grade',
                'priority' => 'medium',
            ],
            'schedule_change' => [
                'title' => '📅 Schedule Change: {course_name}',
                'message' => 'New time: {new_time}, Location: {new_location}',
                'type' => 'schedule',
                'priority' => 'high',
            ],
        ]);
    }
}
