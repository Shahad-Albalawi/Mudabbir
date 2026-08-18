<?php

namespace App\Services;

use App\Models\DeviceToken;
use App\Models\UserNotification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    public function sendToUser(int $userId, string $title, string $body, array $data = []): void
    {
        $serverKey = (string) config('services.fcm.server_key');
        if ($serverKey === '') {
            Log::info('FCM skipped (missing FCM_SERVER_KEY)', [
                'user_id' => $userId,
                'title' => $title,
            ]);

            return;
        }

        $tokens = DeviceToken::query()
            ->where('user_id', $userId)
            ->pluck('fcm_token')
            ->all();

        if ($tokens === []) {
            return;
        }

        foreach ($tokens as $token) {
            Http::withHeaders([
                'Authorization' => 'key='.$serverKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', [
                'to' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
            ]);
        }
    }

    public function storeAndPush(
        int $userId,
        string $type,
        string $title,
        string $body,
        array $data = [],
    ): UserNotification {
        $notification = UserNotification::query()->create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);

        $this->sendToUser($userId, $title, $body, array_merge($data, [
            'notification_id' => $notification->id,
            'type' => $type,
        ]));

        return $notification;
    }
}
