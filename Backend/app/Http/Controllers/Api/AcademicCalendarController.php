<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicCalendar;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademicCalendarController extends Controller
{
    /**
     * Get all academic calendars.
     */
    public function index(Request $request): JsonResponse
    {
        $calendars = AcademicCalendar::with('courses')
            ->orderBy('start_date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $calendars->map(function ($calendar) {
                return $this->formatCalendar($calendar);
            }),
        ]);
    }

    /**
     * Get active academic calendar.
     */
    public function active(Request $request): JsonResponse
    {
        $calendar = AcademicCalendar::getActive();

        return response()->json([
            'success' => true,
            'data' => $calendar ? $this->formatCalendar($calendar) : null,
        ]);
    }

    /**
     * Get academic calendars by year.
     */
    public function byYear(Request $request, int $year): JsonResponse
    {
        $calendars = AcademicCalendar::whereYear('start_date', $year)
            ->orWhereYear('end_date', $year)
            ->with('courses')
            ->orderBy('start_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $calendars->map(function ($calendar) {
                return $this->formatCalendar($calendar);
            }),
        ]);
    }

    /**
     * Get upcoming academic calendars.
     */
    public function upcoming(Request $request): JsonResponse
    {
        $calendars = AcademicCalendar::where('status', 'upcoming')
            ->orWhere('start_date', '>', now())
            ->with('courses')
            ->orderBy('start_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $calendars->map(function ($calendar) {
                return $this->formatCalendar($calendar);
            }),
        ]);
    }

    /**
     * Format calendar for API response.
     */
    private function formatCalendar(AcademicCalendar $calendar): array
    {
        return [
            'id' => $calendar->id,
            'name' => $calendar->name,
            'start_date' => $calendar->start_date instanceof \Carbon\Carbon
                ? $calendar->start_date->format('Y-m-d')
                : (string) $calendar->start_date,
            'end_date' => $calendar->end_date instanceof \Carbon\Carbon
                ? $calendar->end_date->format('Y-m-d')
                : (string) $calendar->end_date,
            'status' => $calendar->status,
            'planned_credits' => $calendar->planned_credits,
            'important_dates' => $calendar->important_dates ?? [],
            'courses_count' => $calendar->courses_count,
            'created_at' => $calendar->created_at?->toISOString(),
            'updated_at' => $calendar->updated_at?->toISOString(),
        ];
    }
}