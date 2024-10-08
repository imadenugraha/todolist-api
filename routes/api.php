<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TodoController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::controller(AuthController::class)->group(function () {
    Route::post('/register', 'register')->name('register');
    Route::post('/login', 'login')->name('login');
    Route::post('/logout', 'logout')->middleware('auth:sanctum')->name('logout');
});

Route::resource('todo', TodoController::class)
    ->only(['store', 'show', 'update', 'destroy'])
    ->middleware('auth:sanctum');
