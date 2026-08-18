<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $notifications = UserNotification::query()
            ->where('user_id', $userId)
            ->latest('id')
            ->limit(50)
            ->get()
            ->map(fn (UserNotification $n): array => [
                'id' => $n->id,
                'type' => $n->type,
                'title' => $n->title,
                'body' => $n->body,
                'data' => $n->data,
                'read_at' => optional($n->read_at)->toISOString(),
                'created_at' => optional($n->created_at)->toISOString(),
            ]);

        return $this->success($notifications);
    }

    public function markRead(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $notification = UserNotification::query()
            ->where('user_id', $userId)
            ->whereKey($id)
            ->first();

        if (! $notification) {
            return $this->notFound('Notification not found');
        }

        $notification->markAsRead();

        return $this->success([
            'id' => $notification->id,
            'read_at' => optional($notification->read_at)->toISOString(),
        ], 'Notification marked as read');
    }
}
