<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PushTestController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['nullable', 'string', 'max:120'],
            'body' => ['nullable', 'string', 'max:500'],
            'route' => ['nullable', 'string', 'max:120'],
        ]);

        $user = $request->user();
        $title = $validated['title'] ?? 'Mudabbir test push';
        $body = $validated['body'] ?? 'Push notifications are working.';
        $route = $validated['route'] ?? '/notifications';

        $notification = $this->fcmService->storeAndPush(
            $user->id,
            'test_push',
            $title,
            $body,
            ['route' => $route],
        );

        return $this->success([
            'notification_id' => $notification->id,
        ], 'Test notification queued');
    }
}
