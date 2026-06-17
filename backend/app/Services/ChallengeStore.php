<?php

namespace App\Services;

use App\Services\Concerns\UsesJsonStorePath;
use Carbon\Carbon;
use Illuminate\Support\Facades\File;

class ChallengeStore
{
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('challenges.json');
    }

    public function all(int $userId): array
    {
        $data = $this->read();

        $visible = array_values(array_filter(
            $data['challenges'],
            function (array $challenge) use ($userId): bool {
                return $this->userCanAccess($challenge, $userId);
            }
        ));

        return array_values(array_map(function (array $challenge): array {
            return $this->normalizeChallenge($challenge);
        }, $visible));
    }

    public function find(int $id, int $userId): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $challenge) {
            if ((int) $challenge['id'] === $id && $this->userCanAccess($challenge, $userId)) {
                return $this->normalizeChallenge($challenge);
            }
        }

        return null;
    }

    /**
     * @param  array{id: int, name: string, email: string}  $creator
     */
    public function create(array $payload, array $creator): array
    {
        $data = $this->read();
        $now = Carbon::now()->toISOString();
        $id = (int) $data['next_challenge_id'];
        $data['next_challenge_id'] = $id + 1;

        $creatorId = (int) $creator['id'];

        $challenge = [
            'id' => $id,
            'user_id' => $creatorId,
            'name' => (string) $payload['name'],
            'amount' => (float) $payload['amount'],
            'start_date' => (string) $payload['start_date'],
            'end_date' => (string) $payload['end_date'],
            'achieved' => false,
            'creator_id' => $creatorId,
            'creator' => [
                'id' => $creatorId,
                'name' => (string) $creator['name'],
                'email' => (string) $creator['email'],
            ],
            'participants' => [[
                'id' => $creatorId,
                'name' => (string) $creator['name'],
                'email' => (string) $creator['email'],
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

    public function update(int $id, array $updates, int $userId): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id || ! $this->isCreator($challenge, $userId)) {
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

    public function delete(int $id, int $userId): bool
    {
        $data = $this->read();
        $before = count($data['challenges']);
        $data['challenges'] = array_values(array_filter(
            $data['challenges'],
            function (array $challenge) use ($id, $userId): bool {
                return ! ((int) $challenge['id'] === $id && $this->isCreator($challenge, $userId));
            }
        ));
        $after = count($data['challenges']);

        if ($after === $before) {
            return false;
        }

        $this->write($data);

        return true;
    }

    public function invite(int $id, string $email, int $actingUserId): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id || ! $this->isCreator($challenge, $actingUserId)) {
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

    public function removeParticipant(int $id, int $participantId, int $actingUserId): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id || ! $this->userCanAccess($challenge, $actingUserId)) {
                continue;
            }

            if (! $this->isCreator($challenge, $actingUserId) && $participantId !== $actingUserId) {
                return null;
            }

            $challenge['participants'] = array_values(array_filter(
                $challenge['participants'],
                function (array $participant) use ($challenge, $participantId): bool {
                    return (int) $participant['id'] !== $participantId
                        || (int) $participant['id'] === (int) $challenge['creator_id'];
                }
            ));
            $challenge['updated_at'] = Carbon::now()->toISOString();
            $data['challenges'][$idx] = $challenge;
            $this->write($data);

            return $challenge;
        }

        return null;
    }

    public function toggleStatus(int $id, int $userId): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id || ! $this->isCreator($challenge, $userId)) {
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

    public function respond(int $id, string $status, int $userId, string $userEmail): ?array
    {
        $data = $this->read();
        foreach ($data['challenges'] as $idx => $challenge) {
            if ((int) $challenge['id'] !== $id) {
                continue;
            }

            foreach ($challenge['participants'] as $pIdx => $participant) {
                $matchesUser = (int) $participant['id'] === $userId
                    || strtolower((string) $participant['email']) === strtolower($userEmail);

                if (! $matchesUser || (string) ($participant['status'] ?? '') !== 'pending') {
                    continue;
                }

                $participant['id'] = $userId;
                $participant['status'] = $status;
                $challenge['participants'][$pIdx] = $participant;
                $challenge['updated_at'] = Carbon::now()->toISOString();
                $data['challenges'][$idx] = $challenge;
                $this->write($data);

                return $challenge;
            }

            return null;
        }

        return null;
    }

    public function pendingInvitations(int $userId, string $userEmail): array
    {
        $email = strtolower($userEmail);
        $data = $this->read();
        $results = [];

        foreach ($data['challenges'] as $challenge) {
            foreach ($challenge['participants'] ?? [] as $participant) {
                $matchesUser = (int) ($participant['id'] ?? 0) === $userId
                    || strtolower((string) ($participant['email'] ?? '')) === $email;

                if ($matchesUser && (string) ($participant['status'] ?? '') === 'pending') {
                    $results[] = $this->normalizeChallenge($challenge);
                    break;
                }
            }
        }

        return array_values($results);
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

    /**
     * @param  array{id: int, name: string, email: string}  $creator
     */
    public function createFromTemplate(string $templateId, array $creator): ?array
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
        ], $creator);
    }

    /**
     * @return array{challenge: array, meta: array}|null
     */
    public function checkIn(int $id, int $userId): ?array
    {
        if (! $this->find($id, $userId)) {
            return null;
        }

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
        if (! $this->find($id, $userId)) {
            return null;
        }

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

    public function leaderboard(int $id, int $userId): ?array
    {
        $challenge = $this->find($id, $userId);
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

    private function userCanAccess(array $challenge, int $userId): bool
    {
        if ($this->isCreator($challenge, $userId)) {
            return true;
        }

        foreach ($challenge['participants'] ?? [] as $participant) {
            if ((int) ($participant['id'] ?? 0) === $userId) {
                return true;
            }
        }

        return false;
    }

    private function isCreator(array $challenge, int $userId): bool
    {
        $ownerId = (int) ($challenge['user_id'] ?? $challenge['creator_id'] ?? 0);

        return $ownerId === $userId;
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
        $challenge['user_id'] = (int) ($challenge['user_id'] ?? $challenge['creator_id'] ?? 0);
        $challenge['participants'] = array_values(array_map(function (array $participant): array {
            return $this->normalizeParticipant($participant);
        }, $challenge['participants'] ?? []));

        return $challenge;
    }

    private function read(): array
    {
        if (! File::exists($this->path)) {
            $seed = [
                'next_challenge_id' => 1,
                'next_user_id' => 1000,
                'challenges' => [],
            ];
            $this->write($seed);

            return $seed;
        }

        $decoded = json_decode((string) File::get($this->path), true);
        if (! is_array($decoded) || ! isset($decoded['challenges'])) {
            return [
                'next_challenge_id' => 1,
                'next_user_id' => 1000,
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
