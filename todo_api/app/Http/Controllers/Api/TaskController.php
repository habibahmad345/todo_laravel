<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index()
    {
        return Task::with('category:id,name')
            ->where('user_id', 1)
            ->orderBy('is_completed')
            ->orderBy('due_date')
            ->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:200',
            'category_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'reminder_time' => 'nullable',
        ]);

        $data['user_id'] = 1;
        return response()->json(Task::create($data), 201);
    }

    public function complete(Task $task)
    {
        $task->update(['is_completed' => true, 'completed_at' => now()]);
        return $task;
    }
}