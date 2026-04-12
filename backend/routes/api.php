<?php

use App\Http\Controllers\Api\ChallengeController;
use App\Http\Controllers\Api\GenerateContentController;
use Illuminate\Support\Facades\Route;

Route::post('/generate-content', GenerateContentController::class);
Route::get('/challenges/invitations/pending', [ChallengeController::class, 'pendingInvitations']);
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
