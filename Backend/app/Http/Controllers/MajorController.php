<?php

namespace App\Http\Controllers;

use App\Models\Major;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MajorController extends Controller
{
    /**
     * Display a listing of all majors.
     */
    public function index(): JsonResponse
    {
        $majors = Major::with(['students' => function ($query) {
            $query->select('id', 'student_id', 'major_id', 'name', 'year_level');
        }])->get();

        return response()->json([
            'success' => true,
            'data' => $majors,
        ]);
    }

    /**
     * Store a newly created major.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|unique:majors,code',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'department' => 'required|string|max:255',
            'duration_years' => 'required|integer|min:1|max:10',
            'total_credits_required' => 'required|integer|min:1',
            'degree_type' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $major = Major::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Major created successfully',
            'data' => $major,
        ], 201);
    }

    /**
     * Display the specified major.
     */
    public function show(Major $major): JsonResponse
    {
        $major->load(['students', 'courses']);

        return response()->json([
            'success' => true,
            'data' => $major,
        ]);
    }

    /**
     * Update the specified major.
     */
    public function update(Request $request, Major $major): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'code' => 'sometimes|string|unique:majors,code,' . $major->id,
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'department' => 'sometimes|string|max:255',
            'duration_years' => 'sometimes|integer|min:1|max:10',
            'total_credits_required' => 'sometimes|integer|min:1',
            'degree_type' => 'sometimes|string|max:100',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $major->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Major updated successfully',
            'data' => $major,
        ]);
    }

    /**
     * Remove the specified major.
     */
    public function destroy(Major $major): JsonResponse
    {
        $major->delete();

        return response()->json([
            'success' => true,
            'message' => 'Major deleted successfully',
        ]);
    }

    /**
     * Get the full curriculum for a major.
     */
    public function curriculum(Major $major): JsonResponse
    {
        $curriculum = $major->getCurriculum();

        return response()->json([
            'success' => true,
            'data' => [
                'major' => [
                    'id' => $major->id,
                    'code' => $major->code,
                    'name' => $major->name,
                    'duration_years' => $major->duration_years,
                    'total_credits_required' => $major->total_credits_required,
                ],
                'curriculum' => $curriculum,
            ],
        ]);
    }

    /**
     * Get courses for a specific year in the major.
     */
    public function coursesByYear(Major $major, int $year): JsonResponse
    {
        if ($year < 1 || $year > $major->duration_years) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid year level for this major',
            ], 400);
        }

        $courses = $major->getCoursesByYear($year)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'major' => $major->name,
                'year' => $year,
                'courses' => $courses,
                'total_credits' => $courses->sum('credits'),
            ],
        ]);
    }

    /**
     * Get courses for a specific year and semester.
     */
    public function coursesByYearAndSemester(Major $major, int $year, int $semester): JsonResponse
    {
        if ($year < 1 || $year > $major->duration_years) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid year level for this major',
            ], 400);
        }

        if ($semester < 1 || $semester > 2) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid semester (must be 1 or 2)',
            ], 400);
        }

        $courses = $major->getCoursesByYearAndSemester($year, $semester)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'major' => $major->name,
                'year' => $year,
                'semester' => $semester,
                'courses' => $courses,
                'total_credits' => $courses->sum('credits'),
            ],
        ]);
    }
}
