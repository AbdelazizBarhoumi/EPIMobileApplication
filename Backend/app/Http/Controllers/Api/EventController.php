<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventRegistration;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * Display a listing of events.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Event::where('is_active', true);

        // Filter by category
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        // Filter by upcoming/past
        if ($request->has('filter')) {
            if ($request->filter === 'upcoming') {
                $query->where('event_date', '>', now());
            } elseif ($request->filter === 'past') {
                $query->where('event_date', '<', now());
            }
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'LIKE', "%{$search}%")
                    ->orWhere('description', 'LIKE', "%{$search}%")
                    ->orWhere('location', 'LIKE', "%{$search}%");
            });
        }

        $events = $query->orderBy('event_date', 'asc')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $events,
        ]);
    }

    /**
     * Display the specified event.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found',
            ], 404);
        }

        $student = $request->user()->student;
        $isRegistered = EventRegistration::where('event_id', $id)
            ->where('student_id', $student->id)
            ->exists();

        return response()->json([
            'success' => true,
            'data' => [
                'event' => $event,
                'is_registered' => $isRegistered,
            ],
        ]);
    }

    /**
     * Register for an event.
     */
    public function register(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found',
            ], 404);
        }

        // Check if event is full
        if ($event->is_full) {
            return response()->json([
                'success' => false,
                'message' => 'Event is full',
            ], 400);
        }

        // Check if already registered
        $existingRegistration = EventRegistration::where('event_id', $id)
            ->where('student_id', $student->id)
            ->first();

        if ($existingRegistration) {
            return response()->json([
                'success' => false,
                'message' => 'Already registered for this event',
            ], 400);
        }

        $registration = EventRegistration::create([
            'student_id' => $student->id,
            'event_id' => $id,
            'registered_at' => now(),
            'status' => 'registered',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Successfully registered for event',
            'data' => $registration->load('event'),
        ], 201);
    }

    /**
     * Cancel event registration.
     */
    public function cancelRegistration(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;

        $registration = EventRegistration::where('event_id', $id)
            ->where('student_id', $student->id)
            ->first();

        if (!$registration) {
            return response()->json([
                'success' => false,
                'message' => 'Registration not found',
            ], 404);
        }

        $registration->status = 'cancelled';
        $registration->save();
        $registration->delete();

        return response()->json([
            'success' => true,
            'message' => 'Registration cancelled successfully',
        ]);
    }

    /**
     * Get student's registered events.
     */
    public function myEvents(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $events = $student->events()
            ->wherePivot('status', 'registered')
            ->orderBy('event_date', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $events,
        ]);
    }
}
