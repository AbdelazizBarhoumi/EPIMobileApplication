<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NewsController extends Controller
{
    /**
     * Display a listing of news.
     */
    public function index(Request $request): JsonResponse
    {
        $query = News::published();

        // Filter by category
        if ($request->has('category')) {
            $query->byCategory($request->category);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'LIKE', "%{$search}%")
                    ->orWhere('description', 'LIKE', "%{$search}%");
            });
        }

        // Get featured news separately
        if ($request->has('featured') && $request->featured) {
            $news = News::featured()->recent(10)->get();
        } else {
            $news = $query->orderBy('publish_date', 'desc')->paginate(20);
        }

        return response()->json([
            'success' => true,
            'data' => $news,
        ]);
    }

    /**
     * Display the specified news article.
     */
    public function show(int $id): JsonResponse
    {
        $news = News::published()->find($id);

        if (!$news) {
            return response()->json([
                'success' => false,
                'message' => 'News article not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $news,
        ]);
    }

    /**
     * Get featured news for carousel.
     */
    public function featured(): JsonResponse
    {
        $news = News::featured()->recent(5)->get();

        return response()->json([
            'success' => true,
            'data' => $news,
        ]);
    }

    /**
     * Get recent news.
     */
    public function recent(Request $request): JsonResponse
    {
        $limit = $request->query('limit', 10);
        $news = News::published()->recent($limit)->get();

        return response()->json([
            'success' => true,
            'data' => $news,
        ]);
    }
}
