<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChallengeController;
use App\Http\Controllers\Api\ExpenseController;
use App\Http\Controllers\Api\GenerateContentController;
use App\Http\Controllers\Api\GoalController;
use App\Http\Controllers\Api\HealthController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::post('/generate-content', GenerateContentController::class);

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/challenges/templates', [ChallengeController::class, 'templates']);
    Route::post('/challenges/from-template', [ChallengeController::class, 'createFromTemplate']);
    Route::get('/challenges/invitations/pending', [ChallengeController::class, 'pendingInvitations']);
    Route::post('/challenges/{id}/progress', [ChallengeController::class, 'recordProgress']);
    Route::post('/challenges/{id}/check-in', [ChallengeController::class, 'checkIn']);
    Route::get('/challenges/{id}/leaderboard', [ChallengeController::class, 'leaderboard']);
    Route::post('/challenges/{id}/invite', [ChallengeController::class, 'invite']);
    Route::post('/challenges/{id}/invitations', [ChallengeController::class, 'invite']);
    Route::post('/challenges/{id}/respond', [ChallengeController::class, 'respond']);
    Route::patch('/challenges/{id}/status', [ChallengeController::class, 'toggleStatus']);
    Route::delete('/challenges/{id}/participants/{userId}', [ChallengeController::class, 'removeParticipant']);
    Route::get('/challenges', [ChallengeController::class, 'index']);
    Route::post('/challenges', [ChallengeController::class, 'store']);
    Route::get('/challenges/{id}', [ChallengeController::class, 'show']);
    Route::put('/challenges/{id}', [ChallengeController::class, 'update']);
    Route::delete('/challenges/{id}', [ChallengeController::class, 'destroy']);

    Route::get('/expenses', [ExpenseController::class, 'index']);
    Route::post('/expenses', [ExpenseController::class, 'store']);
    Route::get('/expenses/{id}', [ExpenseController::class, 'show']);
    Route::put('/expenses/{id}', [ExpenseController::class, 'update']);
    Route::delete('/expenses/{id}', [ExpenseController::class, 'destroy']);

    Route::get('/goals', [GoalController::class, 'index']);
    Route::post('/goals', [GoalController::class, 'store']);
    Route::get('/goals/{id}', [GoalController::class, 'show']);
    Route::put('/goals/{id}', [GoalController::class, 'update']);
    Route::post('/goals/{id}/contributions', [GoalController::class, 'addContribution']);
    Route::delete('/goals/{id}', [GoalController::class, 'destroy']);
});
