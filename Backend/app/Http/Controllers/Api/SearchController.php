<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    /**
     * Perform a global search across multiple entities.
     */
    public function search(Request $request): JsonResponse
    {
        $query = $request->query('q');

        if (!$query || strlen($query) < 2) {
            return response()->json([
                'success' => false,
                'message' => 'Search query must be at least 2 characters',
            ], 400);
        }

        $results = [
            'courses' => $this->searchCourses($query),
            'events' => $this->searchEvents($query),
            'clubs' => $this->searchClubs($query),
            'news' => $this->searchNews($query),
        ];

        return response()->json([
            'success' => true,
            'data' => $results,
            'query' => $query,
        ]);
    }

    private function searchCourses(string $query): array
    {
        return \App\Models\Course::where('course_code', 'LIKE', "%{$query}%")
            ->orWhere('name', 'LIKE', "%{$query}%")
            ->orWhere('instructor', 'LIKE', "%{$query}%")
            ->limit(10)
            ->get()
            ->map(function ($course) {
                return [
                    'id' => $course->id,
                    'type' => 'course',
                    'title' => $course->name,
                    'subtitle' => $course->course_code . ' - ' . $course->instructor,
                ];
            })
            ->toArray();
    }

    private function searchEvents(string $query): array
    {
        return \App\Models\Event::where('is_active', true)
            ->where(function ($q) use ($query) {
                $q->where('title', 'LIKE', "%{$query}%")
                    ->orWhere('description', 'LIKE', "%{$query}%")
                    ->orWhere('location', 'LIKE', "%{$query}%");
            })
            ->limit(10)
            ->get()
            ->map(function ($event) {
                return [
                    'id' => $event->id,
                    'type' => 'event',
                    'title' => $event->title,
                    'subtitle' => $event->event_date->format('M d, Y') . ' - ' . $event->location,
                ];
            })
            ->toArray();
    }

    private function searchClubs(string $query): array
    {
        return \App\Models\Club::where('is_active', true)
            ->where(function ($q) use ($query) {
                $q->where('name', 'LIKE', "%{$query}%")
                    ->orWhere('description', 'LIKE', "%{$query}%");
            })
            ->limit(10)
            ->get()
            ->map(function ($club) {
                return [
                    'id' => $club->id,
                    'type' => 'club',
                    'title' => $club->name,
                    'subtitle' => $club->category . ' - ' . $club->member_count . ' members',
                ];
            })
            ->toArray();
    }

    private function searchNews(string $query): array
    {
        return \App\Models\News::published()
            ->where(function ($q) use ($query) {
                $q->where('title', 'LIKE', "%{$query}%")
                    ->orWhere('description', 'LIKE', "%{$query}%");
            })
            ->limit(10)
            ->get()
            ->map(function ($news) {
                return [
                    'id' => $news->id,
                    'type' => 'news',
                    'title' => $news->title,
                    'subtitle' => $news->publish_date->format('M d, Y') . ' - ' . $news->category,
                ];
            })
            ->toArray();
    }
}
