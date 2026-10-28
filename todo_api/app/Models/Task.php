<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    protected $fillable = [
    'user_id', 'category_id', 'title', 'description',
    'due_date', 'reminder_time', 'is_pinned',
    'is_completed', 'completed_at',
];

protected $casts = [
    'is_pinned' => 'boolean',
    'is_completed' => 'boolean',
];

public function category()
{
    return $this->belongsTo(Category::class);
}
}
