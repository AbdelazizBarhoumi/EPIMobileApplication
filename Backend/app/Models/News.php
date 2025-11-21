<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class News extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'image_url',
        'publish_date',
        'category',
        'external_link',
        'author',
        'is_featured',
        'is_published',
    ];

    protected $casts = [
        'publish_date' => 'datetime',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
    ];

    /**
     * Scope to get published news.
     */
    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    /**
     * Scope to get featured news.
     */
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true)->where('is_published', true);
    }

    /**
     * Scope to get recent news.
     */
    public function scopeRecent($query, int $limit = 10)
    {
        return $query->orderBy('publish_date', 'desc')->limit($limit);
    }

    /**
     * Scope to filter by category.
     */
    public function scopeByCategory($query, string $category)
    {
        return $query->where('category', $category);
    }
}
