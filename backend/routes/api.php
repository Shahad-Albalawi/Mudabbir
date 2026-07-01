<?php

use App\Http\Controllers\Api\AiChatController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\ChallengeController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ExpenseController;
use App\Http\Controllers\Api\GenerateContentController;
use App\Http\Controllers\Api\GoalController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\StatisticsController;
use Illuminate\Support\Facades\Route;

Route::middleware('throttle:api')->get('/health', HealthController::class);

Route::middleware('throttle:auth-register')->group(function (): void {
    Route::post('/register', [AuthController::class, 'register']);
});

Route::middleware('throttle:auth-login')->group(function (): void {
    Route::post('/login', [AuthController::class, 'login']);
});

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function (): void {
    Route::post('/generate-content', GenerateContentController::class)
        ->middleware('throttle:ai');
    Route::post('/ai/chat', AiChatController::class)
        ->middleware('throttle:ai');
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/statistics', [StatisticsController::class, 'index']);
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/reports/monthly', [ReportController::class, 'monthly']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markRead']);

    Route::get('/challenges/templates', [ChallengeController::class, 'templates']);
    Route::get('/challenges/invitations/pending', [ChallengeController::class, 'pendingInvitations']);
    Route::get('/challenges/{id}/leaderboard', [ChallengeController::class, 'leaderboard']);
    Route::get('/challenges', [ChallengeController::class, 'index']);
    Route::get('/challenges/{id}', [ChallengeController::class, 'show']);

    Route::middleware('throttle:challenges-write')->group(function (): void {
        Route::post('/challenges/from-template', [ChallengeController::class, 'createFromTemplate']);
        Route::post('/challenges/{id}/progress', [ChallengeController::class, 'recordProgress']);
        Route::post('/challenges/{id}/check-in', [ChallengeController::class, 'checkIn']);
        Route::post('/challenges/{id}/invite', [ChallengeController::class, 'invite']);
        Route::post('/challenges/{id}/invitations', [ChallengeController::class, 'invite']);
        Route::post('/challenges/{id}/respond', [ChallengeController::class, 'respond']);
        Route::patch('/challenges/{id}/status', [ChallengeController::class, 'toggleStatus']);
        Route::delete('/challenges/{id}/participants/{userId}', [ChallengeController::class, 'removeParticipant']);
        Route::post('/challenges', [ChallengeController::class, 'store']);
        Route::put('/challenges/{id}', [ChallengeController::class, 'update']);
        Route::delete('/challenges/{id}', [ChallengeController::class, 'destroy']);
    });

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
    Route::post('/goals/{id}/milestones', [GoalController::class, 'addMilestone']);
    Route::delete('/goals/{id}', [GoalController::class, 'destroy']);

    Route::get('/budgets', [BudgetController::class, 'index']);
    Route::post('/budgets', [BudgetController::class, 'store']);
    Route::get('/budgets/{id}', [BudgetController::class, 'show']);
    Route::put('/budgets/{id}', [BudgetController::class, 'update']);
    Route::delete('/budgets/{id}', [BudgetController::class, 'destroy']);
});
