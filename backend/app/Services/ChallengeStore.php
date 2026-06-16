<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\File;

class ChallengeStore
{
    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = storage_path('app/challenges.json');
    }

    public function all(): array
    {
        $data = $this->read();

        return array_values(array_map(function (array $challenge): array {
            return $this->normalizeChallenge($challenge);
        }, $data['challenges']));
    }

    public function find(int $id): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $challenge) {
            if ((int) $challenge['id'] === $id) {
                return $this->normalizeChallenge($challenge);
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
                'current_progress' => 0.0,
                'streak_days' => 0,
                'longest_streak' => 0,
                'last_check_in' => null,
                'badges' => [],
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
            function (array $challenge) use ($id): bool {
                return (int) $challenge['id'] !== $id;
            }
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
                'current_progress' => 0.0,
                'streak_days' => 0,
                'longest_streak' => 0,
                'last_check_in' => null,
                'badges' => [],
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
                function (array $participant) use ($challenge, $userId): bool {
                    return (int) $participant['id'] !== $userId || (int) $participant['id'] === (int) $challenge['creator_id'];
                }
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

    public function templates(): array
    {
        return [
            [
                'id' => 'no_extra_week',
                'name_ar' => 'أسبوع بدون مصروفات زائدة',
                'name_en' => 'No Extra Spending Week',
                'description_ar' => 'التزم بعدم الإنفاق على غير الضروريات لمدة 7 أيام',
                'description_en' => 'Skip non-essential purchases for 7 days',
                'amount' => 0.0,
                'duration_days' => 7,
                'icon' => 'week',
            ],
            [
                'id' => 'save_500_month',
                'name_ar' => 'تحدي ادخار 500 ريال',
                'name_en' => 'Save 500 SAR Challenge',
                'description_ar' => 'ادخر 500 ريال خلال 30 يوماً مع فريقك',
                'description_en' => 'Save 500 SAR in 30 days with your group',
                'amount' => 500.0,
                'duration_days' => 30,
                'icon' => 'savings',
            ],
            [
                'id' => 'coffee_free_14',
                'name_ar' => '14 يوم بدون قهوة خارجية',
                'name_en' => '14 Days No Takeout Coffee',
                'description_ar' => 'وفر المال بتجنب القهوة والمشروبات الجاهزة لمدة أسبوعين',
                'description_en' => 'Cut takeout drinks for two weeks and save',
                'amount' => 200.0,
                'duration_days' => 14,
                'icon' => 'coffee',
            ],
            [
                'id' => 'ramadan_budget',
                'name_ar' => 'ميزانية رمضان الذكية',
                'name_en' => 'Smart Ramadan Budget',
                'description_ar' => 'التزم بميزانية يومية ثابتة طوال الشهر',
                'description_en' => 'Stick to a fixed daily budget all month',
                'amount' => 1500.0,
                'duration_days' => 30,
                'icon' => 'moon',
            ],
        ];
    }

    public function createFromTemplate(string $templateId): ?array
    {
        $template = null;
        foreach ($this->templates() as $item) {
            if ((string) $item['id'] === $templateId) {
                $template = $item;
                break;
            }
        }

        if (! $template) {
            return null;
        }

        $start = Carbon::now()->toDateString();
        $end = Carbon::now()->addDays((int) $template['duration_days'])->toDateString();

        return $this->create([
            'name' => (string) $template['name_ar'],
            'amount' => (float) $template['amount'],
            'start_date' => $start,
            'end_date' => $end,
        ]);
    }

    /**
     * @return array{challenge: array, meta: array}|null
     */
    public function checkIn(int $id, int $userId = 1): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            foreach ($challenge['participants'] as $pIdx => $participant) {
                if ((int) $participant['id'] !== $userId) {
                    continue;
                }

                if ((string) ($participant['status'] ?? '') !== 'accepted') {
                    return null;
                }

                $participant = $this->normalizeParticipant($participant);
                $today = Carbon::now()->toDateString();
                $yesterday = Carbon::yesterday()->toDateString();
                $newBadges = [];

                if ((string) $participant['last_check_in'] === $today) {
                    $challenge['participants'][$pIdx] = $participant;

                    return [
                        'challenge' => $this->normalizeChallenge($challenge),
                        'meta' => [
                            'already_checked_in' => true,
                            'new_badges' => [],
                        ],
                    ];
                }

                if ((string) $participant['last_check_in'] === $yesterday) {
                    $participant['streak_days'] = (int) $participant['streak_days'] + 1;
                } else {
                    $participant['streak_days'] = 1;
                }

                $participant['last_check_in'] = $today;
                $participant['longest_streak'] = max(
                    (int) $participant['longest_streak'],
                    (int) $participant['streak_days']
                );

                $badges = $participant['badges'];
                if ($participant['streak_days'] >= 7 && ! in_array('streak_7', $badges, true)) {
                    $badges[] = 'streak_7';
                    $newBadges[] = 'streak_7';
                }
                if ($participant['streak_days'] >= 30 && ! in_array('streak_30', $badges, true)) {
                    $badges[] = 'streak_30';
                    $newBadges[] = 'streak_30';
                }
                $participant['badges'] = array_values($badges);

                $challenge['participants'][$pIdx] = $participant;
                $challenge['updated_at'] = Carbon::now()->toISOString();
                $data['challenges'][$idx] = $challenge;
                $this->write($data);

                return [
                    'challenge' => $this->normalizeChallenge($challenge),
                    'meta' => [
                        'already_checked_in' => false,
                        'new_badges' => $newBadges,
                    ],
                ];
            }

            return null;
        }

        return null;
    }

    public function recordProgress(int $id, int $userId, float $amount): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            foreach ($challenge['participants'] as $pIdx => $participant) {
                if ((int) $participant['id'] !== $userId) {
                    continue;
                }

                if ((string) ($participant['status'] ?? '') !== 'accepted') {
                    return null;
                }

                $participant = $this->normalizeParticipant($participant);
                $target = (float) ($participant['target_amount'] ?? $challenge['amount'] ?? 0);
                $newProgress = (float) $participant['current_progress'] + $amount;
                $participant['current_progress'] = $newProgress;

                if ($target > 0 && $newProgress >= $target) {
                    $participant['achieved'] = true;
                    $challenge['achieved'] = true;
                }

                $challenge['participants'][$pIdx] = $participant;
                $challenge['updated_at'] = Carbon::now()->toISOString();
                $data['challenges'][$idx] = $challenge;
                $this->write($data);

                return $this->normalizeChallenge($challenge);
            }

            return null;
        }

        return null;
    }

    public function leaderboard(int $id): ?array
    {
        $challenge = $this->find($id);
        if (! $challenge) {
            return null;
        }

        $entries = [];
        foreach ($challenge['participants'] as $participant) {
            if ((string) ($participant['status'] ?? '') !== 'accepted') {
                continue;
            }

            $streak = (int) ($participant['streak_days'] ?? 0);
            $progress = (float) ($participant['current_progress'] ?? 0);
            $entries[] = [
                'user_id' => (int) $participant['id'],
                'name' => (string) $participant['name'],
                'email' => (string) $participant['email'],
                'streak_days' => $streak,
                'longest_streak' => (int) ($participant['longest_streak'] ?? 0),
                'current_progress' => $progress,
                'badges' => array_values($participant['badges'] ?? []),
                'achieved' => (bool) ($participant['achieved'] ?? false),
                'score' => (int) round($progress) + ($streak * 10) + (($participant['achieved'] ?? false) ? 50 : 0),
            ];
        }

        usort($entries, function (array $a, array $b): int {
            if ($b['score'] !== $a['score']) {
                return $b['score'] <=> $a['score'];
            }

            return $b['streak_days'] <=> $a['streak_days'];
        });

        foreach ($entries as $index => $entry) {
            $entries[$index]['rank'] = $index + 1;
        }

        return [
            'challenge_id' => $id,
            'entries' => $entries,
        ];
    }

    private function normalizeParticipant(array $participant): array
    {
        $badges = $participant['badges'] ?? [];

        return array_merge($participant, [
            'current_progress' => (float) ($participant['current_progress'] ?? 0),
            'streak_days' => (int) ($participant['streak_days'] ?? 0),
            'longest_streak' => (int) ($participant['longest_streak'] ?? 0),
            'last_check_in' => $participant['last_check_in'] ?? null,
            'badges' => is_array($badges) ? array_values($badges) : [],
        ]);
    }

    private function normalizeChallenge(array $challenge): array
    {
        $challenge['participants'] = array_values(array_map(function (array $participant): array {
            return $this->normalizeParticipant($participant);
        }, $challenge['participants'] ?? []));

        return $challenge;
    }

    private function read(): array
    {
        if (! File::exists($this->path)) {
            $seed = [
                'next_challenge_id' => 2,
                'next_user_id' => 2,
                'challenges' => [[
                    'id' => 1,
                    'name' => 'تحدي ادخار 30 يوم',
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
                        'current_progress' => 0.0,
                        'streak_days' => 0,
                        'longest_streak' => 0,
                        'last_check_in' => null,
                        'badges' => [],
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
