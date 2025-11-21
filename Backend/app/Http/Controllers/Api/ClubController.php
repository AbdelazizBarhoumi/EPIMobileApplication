<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Club;
use App\Models\ClubMembership;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ClubController extends Controller
{
    /**
     * Display a listing of clubs.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Club::where('is_active', true);

        // Filter by category
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                    ->orWhere('description', 'LIKE', "%{$search}%");
            });
        }

        $clubs = $query->orderBy('name')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $clubs,
        ]);
    }

    /**
     * Display the specified club.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $club = Club::find($id);

        if (!$club) {
            return response()->json([
                'success' => false,
                'message' => 'Club not found',
            ], 404);
        }

        $student = $request->user()->student;
        $membership = ClubMembership::where('club_id', $id)
            ->where('student_id', $student->id)
            ->where('status', 'active')
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'club' => $club,
                'is_member' => $membership !== null,
                'membership' => $membership,
            ],
        ]);
    }

    /**
     * Join a club.
     */
    public function join(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;
        $club = Club::find($id);

        if (!$club) {
            return response()->json([
                'success' => false,
                'message' => 'Club not found',
            ], 404);
        }

        // Check if already a member
        $existingMembership = ClubMembership::where('club_id', $id)
            ->where('student_id', $student->id)
            ->where('status', 'active')
            ->first();

        if ($existingMembership) {
            return response()->json([
                'success' => false,
                'message' => 'Already a member of this club',
            ], 400);
        }

        $membership = ClubMembership::create([
            'student_id' => $student->id,
            'club_id' => $id,
            'join_date' => now(),
            'role' => 'member',
            'status' => 'active',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Successfully joined club',
            'data' => $membership->load('club'),
        ], 201);
    }

    /**
     * Leave a club.
     */
    public function leave(Request $request, int $id): JsonResponse
    {
        $student = $request->user()->student;

        $membership = ClubMembership::where('club_id', $id)
            ->where('student_id', $student->id)
            ->where('status', 'active')
            ->first();

        if (!$membership) {
            return response()->json([
                'success' => false,
                'message' => 'Membership not found',
            ], 404);
        }

        $membership->status = 'inactive';
        $membership->save();
        $membership->delete();

        return response()->json([
            'success' => true,
            'message' => 'Successfully left club',
        ]);
    }

    /**
     * Get student's club memberships.
     */
    public function myClubs(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        $clubs = $student->clubs()
            ->wherePivot('status', 'active')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $clubs,
        ]);
    }
}
