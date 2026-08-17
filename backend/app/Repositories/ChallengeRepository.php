<?php

namespace App\Repositories;

use App\Models\Challenge;
use App\Models\ChallengeParticipant;
use App\Support\ResolvesModelPrimaryKey;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ChallengeRepository
{
    /**
     * @return list<array<string, mixed>>
     */
    public function all(int $userId): array
    {
        return Challenge::query()
            ->with('participants')
            ->get()
            ->filter(fn (Challenge $c): bool => $this->userCanAccess($c, $userId))
            ->map(fn (Challenge $c): array => $c->toStoreArray())
            ->values()
            ->all();
    }

    /**
     * @return array<string, mixed>|null
     */
    public function find(int $id, int $userId): ?array
    {
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->userCanAccess($challenge, $userId)) {
            return null;
        }

        return $challenge->toStoreArray();
    }

    /**
     * @param  array{id: int, name: string, email: string}  $creator
     * @return array<string, mixed>
     */
    public function create(array $payload, array $creator): array
    {
        return DB::transaction(function () use ($payload, $creator): array {
            $creatorId = (int) $creator['id'];

            $challenge = Challenge::query()->create(
                ResolvesModelPrimaryKey::forCreate(Challenge::class, [
                    'user_id' => $creatorId,
                    'creator_id' => $creatorId,
                    'creator_name' => (string) $creator['name'],
                    'creator_email' => (string) $creator['email'],
                    'name' => (string) $payload['name'],
                    'amount' => (float) $payload['amount'],
                    'start_date' => (string) $payload['start_date'],
                    'end_date' => (string) $payload['end_date'],
                    'achieved' => false,
                ])
            );

            ChallengeParticipant::query()->create([
                'challenge_id' => $challenge->id,
                'participant_id' => $creatorId,
                'name' => (string) $creator['name'],
                'email' => (string) $creator['email'],
                'status' => 'accepted',
                'target_amount' => (float) $payload['amount'],
                'achieved' => false,
                'current_progress' => 0,
                'streak_days' => 0,
                'longest_streak' => 0,
                'badges' => [],
            ]);

            return $challenge->fresh('participants')->toStoreArray();
        });
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array<string, mixed>|null
     */
    public function update(int $id, array $updates, int $userId): ?array
    {
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->isCreator($challenge, $userId)) {
            return null;
        }

        foreach (['name', 'amount', 'start_date', 'end_date'] as $field) {
            if (array_key_exists($field, $updates)) {
                $challenge->{$field} = $field === 'amount' ? (float) $updates[$field] : $updates[$field];
            }
        }
        $challenge->save();

        return $challenge->fresh('participants')->toStoreArray();
    }

    public function delete(int $id, int $userId): bool
    {
        $challenge = Challenge::query()->whereKey($id)->first();
        if ($challenge === null || ! $this->isCreator($challenge, $userId)) {
            return false;
        }

        return (bool) $challenge->delete();
    }

    public function invite(int $id, string $email, int $actingUserId): ?array
    {
        return DB::transaction(function () use ($id, $email, $actingUserId): ?array {
            $challenge = Challenge::query()->with('participants')->whereKey($id)->lockForUpdate()->first();
            if ($challenge === null || ! $this->isCreator($challenge, $actingUserId)) {
                return null;
            }

            $emailLower = strtolower($email);
            foreach ($challenge->participants as $participant) {
                if (strtolower($participant->email) === $emailLower) {
                    return $challenge->toStoreArray();
                }
            }

            ChallengeParticipant::query()->create([
                'challenge_id' => $challenge->id,
                'participant_id' => $this->nextProvisionalParticipantId(),
                'name' => strstr($email, '@', true) ?: 'Participant',
                'email' => $email,
                'status' => 'pending',
                'target_amount' => null,
                'achieved' => false,
                'current_progress' => 0,
                'streak_days' => 0,
                'longest_streak' => 0,
                'badges' => [],
            ]);

            return $challenge->fresh('participants')->toStoreArray();
        });
    }

    public function removeParticipant(int $id, int $participantId, int $actingUserId): ?array
    {
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->userCanAccess($challenge, $actingUserId)) {
            return null;
        }

        if (! $this->isCreator($challenge, $actingUserId) && $participantId !== $actingUserId) {
            return null;
        }

        ChallengeParticipant::query()
            ->where('challenge_id', $challenge->id)
            ->where('participant_id', $participantId)
            ->where('participant_id', '!=', $challenge->creator_id)
            ->delete();

        return $challenge->fresh('participants')->toStoreArray();
    }

    public function toggleStatus(int $id, int $userId): ?array
    {
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->isCreator($challenge, $userId)) {
            return null;
        }

        $challenge->achieved = ! $challenge->achieved;
        $challenge->save();

        return $challenge->fresh('participants')->toStoreArray();
    }

    public function respond(int $id, string $status, int $userId, string $userEmail): ?array
    {
        return DB::transaction(function () use ($id, $status, $userId, $userEmail): ?array {
            $challenge = Challenge::query()->with('participants')->whereKey($id)->lockForUpdate()->first();
            if ($challenge === null) {
                return null;
            }

            $emailLower = strtolower($userEmail);
            foreach ($challenge->participants as $participant) {
                if ($participant->status !== 'pending') {
                    continue;
                }
                if (strtolower($participant->email) !== $emailLower) {
                    continue;
                }

                $participant->update([
                    'participant_id' => $userId,
                    'status' => $status,
                ]);

                return $challenge->fresh('participants')->toStoreArray();
            }

            return null;
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function pendingInvitations(int $userId, string $userEmail): array
    {
        $emailLower = strtolower($userEmail);
        $results = [];

        $challenges = Challenge::query()->with('participants')->get();
        foreach ($challenges as $challenge) {
            foreach ($challenge->participants as $participant) {
                $matchesUser = (int) $participant->participant_id === $userId
                    || strtolower($participant->email) === $emailLower;

                if ($matchesUser && $participant->status === 'pending') {
                    $results[] = $challenge->toStoreArray();
                    break;
                }
            }
        }

        return array_values($results);
    }

    /**
     * @return list<array<string, mixed>>
     */
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
     * @return array<string, mixed>|null
     */
    public function createFromTemplate(string $templateId, array $creator): ?array
    {
        $template = collect($this->templates())->firstWhere('id', $templateId);
        if ($template === null) {
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
        if ($this->find($id, $userId) === null) {
            return null;
        }

        return DB::transaction(function () use ($id, $userId): ?array {
            $challenge = Challenge::query()->with('participants')->whereKey($id)->lockForUpdate()->first();
            if ($challenge === null) {
                return null;
            }

            $participant = $challenge->participants->firstWhere('participant_id', $userId);
            if ($participant === null || $participant->status !== 'accepted') {
                return null;
            }

            $today = Carbon::now()->toDateString();
            $yesterday = Carbon::yesterday()->toDateString();
            $newBadges = [];

            if ($participant->last_check_in?->format('Y-m-d') === $today) {
                return [
                    'challenge' => $challenge->toStoreArray(),
                    'meta' => ['already_checked_in' => true, 'new_badges' => []],
                ];
            }

            $streak = ($participant->last_check_in?->format('Y-m-d') === $yesterday)
                ? $participant->streak_days + 1
                : 1;

            $badges = $participant->badges ?? [];
            if ($streak >= 7 && ! in_array('streak_7', $badges, true)) {
                $badges[] = 'streak_7';
                $newBadges[] = 'streak_7';
            }
            if ($streak >= 30 && ! in_array('streak_30', $badges, true)) {
                $badges[] = 'streak_30';
                $newBadges[] = 'streak_30';
            }

            $participant->update([
                'streak_days' => $streak,
                'longest_streak' => max($participant->longest_streak, $streak),
                'last_check_in' => $today,
                'badges' => array_values($badges),
            ]);

            return [
                'challenge' => $challenge->fresh('participants')->toStoreArray(),
                'meta' => ['already_checked_in' => false, 'new_badges' => $newBadges],
            ];
        });
    }

    public function recordProgress(int $id, int $userId, float $amount): ?array
    {
        if ($this->find($id, $userId) === null) {
            return null;
        }

        return DB::transaction(function () use ($id, $userId, $amount): ?array {
            $challenge = Challenge::query()->with('participants')->whereKey($id)->lockForUpdate()->first();
            if ($challenge === null) {
                return null;
            }

            $participant = $challenge->participants->firstWhere('participant_id', $userId);
            if ($participant === null || $participant->status !== 'accepted') {
                return null;
            }

            $target = (float) ($participant->target_amount ?? $challenge->amount);
            $newProgress = (float) $participant->current_progress + $amount;

            $participant->current_progress = $newProgress;
            if ($target > 0 && $newProgress >= $target) {
                $participant->achieved = true;
                $challenge->achieved = true;
            }
            $participant->save();
            $challenge->save();

            return $challenge->fresh('participants')->toStoreArray();
        });
    }

    /**
     * @return array<string, mixed>|null
     */
    public function leaderboard(int $id, int $userId): ?array
    {
        $challenge = $this->find($id, $userId);
        if ($challenge === null) {
            return null;
        }

        $entries = [];
        foreach ($challenge['participants'] as $participant) {
            if (($participant['status'] ?? '') !== 'accepted') {
                continue;
            }

            $streak = (int) ($participant['streak_days'] ?? 0);
            $progress = (float) ($participant['current_progress'] ?? 0);
            $achieved = (bool) ($participant['achieved'] ?? false);

            $entries[] = [
                'user_id' => (int) $participant['id'],
                'name' => (string) $participant['name'],
                'email' => (string) $participant['email'],
                'streak_days' => $streak,
                'longest_streak' => (int) ($participant['longest_streak'] ?? 0),
                'current_progress' => $progress,
                'badges' => array_values($participant['badges'] ?? []),
                'achieved' => $achieved,
                'score' => (int) round($progress) + ($streak * 10) + ($achieved ? 50 : 0),
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

    private function userCanAccess(Challenge $challenge, int $userId): bool
    {
        if ($this->isCreator($challenge, $userId)) {
            return true;
        }

        return $challenge->participants
            ->contains(fn (ChallengeParticipant $p): bool => (int) $p->participant_id === $userId && $p->status === 'accepted');
    }

    private function isCreator(Challenge $challenge, int $userId): bool
    {
        return (int) $challenge->creator_id === $userId;
    }

    private function nextProvisionalParticipantId(): int
    {
        $min = ChallengeParticipant::query()->where('participant_id', '<', 0)->min('participant_id');

        return $min === null ? -1 : ((int) $min) - 1;
    }
}
