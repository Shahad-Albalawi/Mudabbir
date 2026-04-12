<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\File;

class ChallengeStore
{
    private string $path;

    public function __construct()
    {
        $this->path = storage_path('app/challenges.json');
    }

    public function all(): array
    {
        $data = $this->read();

        return array_values($data['challenges']);
    }

    public function find(int $id): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $challenge) {
            if ((int) $challenge['id'] === $id) {
                return $challenge;
            }
        }

        return null;
    }

    public function create(array $payload): array
    {
        $data = $this->read();
        $now = Carbon::now()->toISOString();
        $id = (int) $data['next_challenge_id'];
        $data['next_challenge_id'] = $id + 1;

        $creator = [
            'id' => 1,
            'name' => 'Mudabbir User',
            'email' => 'owner@mudabbir.local',
        ];

        $challenge = [
            'id' => $id,
            'name' => (string) $payload['name'],
            'amount' => (float) $payload['amount'],
            'start_date' => (string) $payload['start_date'],
            'end_date' => (string) $payload['end_date'],
            'achieved' => false,
            'creator_id' => $creator['id'],
            'creator' => $creator,
            'participants' => [[
                'id' => $creator['id'],
                'name' => $creator['name'],
                'email' => $creator['email'],
                'status' => 'accepted',
                'target_amount' => (float) $payload['amount'],
                'achieved' => false,
            ]],
            'created_at' => $now,
            'updated_at' => $now,
        ];

        $data['challenges'][] = $challenge;
        $this->write($data);

        return $challenge;
    }

    public function update(int $id, array $updates): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            foreach (['name', 'amount', 'start_date', 'end_date'] as $field) {
                if (array_key_exists($field, $updates)) {
                    $challenge[$field] = $field === 'amount' ? (float) $updates[$field] : $updates[$field];
                }
            }

            $challenge['updated_at'] = Carbon::now()->toISOString();
            $data['challenges'][$idx] = $challenge;
            $this->write($data);

            return $challenge;
        }

        return null;
    }

    public function delete(int $id): bool
    {
        $data = $this->read();
        $before = count($data['challenges']);
        $data['challenges'] = array_values(array_filter(
            $data['challenges'],
            fn (array $challenge): bool => (int) $challenge['id'] !== $id
        ));
        $after = count($data['challenges']);

        if ($after === $before) {
            return false;
        }

        $this->write($data);

        return true;
    }

    public function invite(int $id, string $email): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            foreach ($challenge['participants'] as $participant) {
                if (strtolower((string) $participant['email']) === strtolower($email)) {
                    return $challenge;
                }
            }

            $userId = (int) $data['next_user_id'];
            $data['next_user_id'] = $userId + 1;

            $challenge['participants'][] = [
                'id' => $userId,
                'name' => strstr($email, '@', true) ?: 'Participant',
                'email' => $email,
                'status' => 'pending',
                'target_amount' => null,
                'achieved' => false,
            ];
            $challenge['updated_at'] = Carbon::now()->toISOString();
            $data['challenges'][$idx] = $challenge;
            $this->write($data);

            return $challenge;
        }

        return null;
    }

    public function removeParticipant(int $id, int $userId): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            $challenge['participants'] = array_values(array_filter(
                $challenge['participants'],
                fn (array $participant): bool => (int) $participant['id'] !== $userId || (int) $participant['id'] === (int) $challenge['creator_id']
            ));
            $challenge['updated_at'] = Carbon::now()->toISOString();
            $data['challenges'][$idx] = $challenge;
            $this->write($data);

            return $challenge;
        }

        return null;
    }

    public function toggleStatus(int $id): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            $challenge['achieved'] = ! (bool) $challenge['achieved'];
            $challenge['updated_at'] = Carbon::now()->toISOString();
            $data['challenges'][$idx] = $challenge;
            $this->write($data);

            return $challenge;
        }

        return null;
    }

    public function respond(int $id, string $status): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            foreach ($challenge['participants'] as $pIdx => $participant) {
                if ((int) $participant['id'] === (int) $challenge['creator_id']) {
                    continue;
                }
                if ((string) $participant['status'] === 'pending') {
                    $participant['status'] = $status;
                    $challenge['participants'][$pIdx] = $participant;
                    $challenge['updated_at'] = Carbon::now()->toISOString();
                    $data['challenges'][$idx] = $challenge;
                    $this->write($data);

                    return $challenge;
                }
            }

            return $challenge;
        }

        return null;
    }

    public function pendingInvitations(): array
    {
        return array_values(array_filter($this->all(), function (array $challenge): bool {
            foreach ($challenge['participants'] as $participant) {
                if ((int) $participant['id'] !== (int) $challenge['creator_id'] && (string) $participant['status'] === 'pending') {
                    return true;
                }
            }

            return false;
        }));
    }

    private function read(): array
    {
        if (! File::exists($this->path)) {
            $seed = [
                'next_challenge_id' => 2,
                'next_user_id' => 2,
                'challenges' => [[
                    'id' => 1,
                    'name' => '30-Day Savings Challenge',
                    'amount' => 1000.0,
                    'start_date' => Carbon::now()->startOfMonth()->toDateString(),
                    'end_date' => Carbon::now()->endOfMonth()->toDateString(),
                    'achieved' => false,
                    'creator_id' => 1,
                    'creator' => [
                        'id' => 1,
                        'name' => 'Mudabbir User',
                        'email' => 'owner@mudabbir.local',
                    ],
                    'participants' => [[
                        'id' => 1,
                        'name' => 'Mudabbir User',
                        'email' => 'owner@mudabbir.local',
                        'status' => 'accepted',
                        'target_amount' => 1000.0,
                        'achieved' => false,
                    ]],
                    'created_at' => Carbon::now()->toISOString(),
                    'updated_at' => Carbon::now()->toISOString(),
                ]],
            ];
            $this->write($seed);

            return $seed;
        }

        $decoded = json_decode((string) File::get($this->path), true);
        if (! is_array($decoded) || ! isset($decoded['challenges'])) {
            return [
                'next_challenge_id' => 1,
                'next_user_id' => 1,
                'challenges' => [],
            ];
        }

        return $decoded;
    }

    private function write(array $payload): void
    {
        File::ensureDirectoryExists(dirname($this->path));
        File::put($this->path, json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }
}
