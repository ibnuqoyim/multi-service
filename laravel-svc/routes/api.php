<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Health check endpoint for Docker
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'service' => 'laravel-api'
    ]);
});

// User management routes
Route::prefix('users')->group(function () {
    Route::get('/', [UserController::class, 'index']);        // GET /api/users
    Route::post('/', [UserController::class, 'store']);       // POST /api/users
    Route::get('/{id}', [UserController::class, 'show']);     // GET /api/users/{id}
});
