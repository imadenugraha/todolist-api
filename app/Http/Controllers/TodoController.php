<?php

namespace App\Http\Controllers;

use App\Models\Todo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TodoController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $todos = Todo::where('user_id', user()->id());

        return response()->json([
            'todos' => $todos,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $request->user()->todo()->create($validated);

        return response()->json([
            'message' => 'Task added!'
        ]);
    }

    /**
     * Display the specified resource.
     */
    public function show(Todo $todo)
    {
        return response()->json([
            'todo' => $todo,
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Todo $todo)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Todo $todo)
    {
        $request->validate([
            'name' => ['sometimes','string','max:255'],
            'is_completed' => ['sometimes', 'boolean'],
        ]);

        $todo->update(array_filter($request->only(['name', 'is_completed'])));

        return response()->json([
            'message' => 'Task updated!'
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Todo $todo)
    {
        Todo::destroy($todo);

        return response()->json([
            'message' => 'Task deleted!'
        ]);
    }
}
