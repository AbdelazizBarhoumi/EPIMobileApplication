<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Controller for handling push notifications via OneSignal
 * 
 * This controller provides a secure backend endpoint for sending notifications
 * since the OneSignal REST API key should NEVER be exposed in frontend code.
 */
class NotificationController extends Controller
{
    /**
     * Send a push notification to specific users via OneSignal
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function send(Request $request)
    {
        // Validate the request
        $validated = $request->validate([
            'player_ids' => 'required|array',
            'player_ids.*' => 'required|string',
            'title' => 'required|string|max:255',
            'message' => 'required|string|max:1000',
            'data' => 'nullable|array',
        ]);

        try {
            // Get OneSignal REST API key from environment
            $restApiKey = env('ONESIGNAL_REST_API_KEY');
            $appId = env('ONESIGNAL_APP_ID', 'e66b5607-740b-4f85-9096-4b59eeb3b970');

            if (!$restApiKey) {
                Log::error('OneSignal REST API key not configured in .env');
                return response()->json([
                    'success' => false,
                    'message' => 'Notification service not configured'
                ], 500);
            }

            // Prepare notification payload
            $payload = [
                'app_id' => $appId,
                'include_player_ids' => $validated['player_ids'],
                'headings' => ['en' => $validated['title']],
                'contents' => ['en' => $validated['message']],
            ];

            // Add additional data if provided
            if (isset($validated['data'])) {
                $payload['data'] = $validated['data'];
            }

            // Send notification via OneSignal API
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Authorization' => 'Basic ' . $restApiKey,
            ])->post('https://onesignal.com/api/v1/notifications', $payload);

            // Check response
            if ($response->successful()) {
                $result = $response->json();
                Log::info('OneSignal notification sent successfully', [
                    'recipients' => $result['recipients'] ?? 0,
                    'player_ids' => $validated['player_ids'],
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Notification sent successfully',
                    'recipients' => $result['recipients'] ?? 0,
                ], 200);
            } else {
                Log::error('Failed to send OneSignal notification', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Failed to send notification',
                    'error' => $response->json()['errors'] ?? 'Unknown error',
                ], $response->status());
            }
        } catch (\Exception $e) {
            Log::error('Exception while sending notification', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An error occurred while sending notification',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Send a notification to users by their external user IDs (Firebase UIDs)
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendByUserId(Request $request)
    {
        // Validate the request
        $validated = $request->validate([
            'user_ids' => 'required|array',
            'user_ids.*' => 'required|string',
            'title' => 'required|string|max:255',
            'message' => 'required|string|max:1000',
            'data' => 'nullable|array',
        ]);

        try {
            // Get OneSignal REST API key from environment
            $restApiKey = env('ONESIGNAL_REST_API_KEY');
            $appId = env('ONESIGNAL_APP_ID', 'e66b5607-740b-4f85-9096-4b59eeb3b970');

            if (!$restApiKey) {
                Log::error('OneSignal REST API key not configured in .env');
                return response()->json([
                    'success' => false,
                    'message' => 'Notification service not configured'
                ], 500);
            }

            // Prepare notification payload using external user IDs
            $payload = [
                'app_id' => $appId,
                'include_external_user_ids' => $validated['user_ids'],
                'headings' => ['en' => $validated['title']],
                'contents' => ['en' => $validated['message']],
            ];

            // Add additional data if provided
            if (isset($validated['data'])) {
                $payload['data'] = $validated['data'];
            }

            // Send notification via OneSignal API
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Authorization' => 'Basic ' . $restApiKey,
            ])->post('https://onesignal.com/api/v1/notifications', $payload);

            // Check response
            if ($response->successful()) {
                $result = $response->json();
                Log::info('OneSignal notification sent successfully by user IDs', [
                    'recipients' => $result['recipients'] ?? 0,
                    'user_ids' => $validated['user_ids'],
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Notification sent successfully',
                    'recipients' => $result['recipients'] ?? 0,
                ], 200);
            } else {
                Log::error('Failed to send OneSignal notification by user IDs', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Failed to send notification',
                    'error' => $response->json()['errors'] ?? 'Unknown error',
                ], $response->status());
            }
        } catch (\Exception $e) {
            Log::error('Exception while sending notification by user IDs', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An error occurred while sending notification',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
