<?php

namespace App\Services\Legacy;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\UsesJsonStorePath;

class LegacyJsonChallengeStore
{
    use ManagesJsonFileStore;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('challenges.json');
    }

    /**
     * @param  array<string, mixed>  $row
     */
    public function upsertFromStoreArray(array $row): void
    {
        $this->mutateStore(function (array &$data) use ($row): void {
            $normalized = $this->normalize($row);
            $id = (int) $normalized['id'];
            $found = false;

            foreach ($data['challenges'] as $idx => $challenge) {
                if ((int) $challenge['id'] === $id) {
                    $data['challenges'][$idx] = $normalized;
                    $found = true;
                    break;
                }
            }

            if (! $found) {
                $data['challenges'][] = $normalized;
            }

            $data['next_challenge_id'] = max((int) $data['next_challenge_id'], $id + 1);
        });
    }

    public function deleteById(int $id, int $userId): void
    {
        $this->mutateStore(function (array &$data) use ($id, $userId): void {
            $data['challenges'] = array_values(array_filter(
                $data['challenges'],
                fn (array $challenge): bool => ! (
                    (int) $challenge['id'] === $id
                    && (int) ($challenge['creator_id'] ?? $challenge['user_id'] ?? 0) === $userId
                )
            ));
        });
    }

    /** @return array<string, mixed> */
    protected function emptyDocument(): array
    {
        return [
            'next_challenge_id' => 1,
            'next_user_id' => 1000,
            'next_provisional_participant_id' => -1,
            'challenges' => [],
        ];
    }

    protected function collectionKey(): string
    {
        return 'challenges';
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    private function normalize(array $row): array
    {
        $creator = $row['creator'] ?? [];
        $participants = [];
        foreach ($row['participants'] ?? [] as $participant) {
            if (! is_array($participant)) {
                continue;
            }
            $participants[] = [
                'id' => (int) $participant['id'],
                'name' => (string) ($participant['name'] ?? ''),
                'email' => (string) ($participant['email'] ?? ''),
                'status' => (string) ($participant['status'] ?? 'pending'),
                'target_amount' => $participant['target_amount'] ?? null,
                'achieved' => (bool) ($participant['achieved'] ?? false),
                'current_progress' => (float) ($participant['current_progress'] ?? 0),
                'streak_days' => (int) ($participant['streak_days'] ?? 0),
                'longest_streak' => (int) ($participant['longest_streak'] ?? 0),
                'last_check_in' => $participant['last_check_in'] ?? null,
                'badges' => $participant['badges'] ?? [],
            ];
        }

        return [
            'id' => (int) $row['id'],
            'user_id' => (int) ($row['user_id'] ?? $row['creator_id'] ?? 0),
            'creator_id' => (int) ($row['creator_id'] ?? $row['user_id'] ?? 0),
            'creator' => [
                'id' => (int) ($creator['id'] ?? $row['creator_id'] ?? 0),
                'name' => (string) ($creator['name'] ?? ''),
                'email' => (string) ($creator['email'] ?? ''),
            ],
            'name' => (string) $row['name'],
            'amount' => (float) ($row['amount'] ?? 0),
            'start_date' => (string) $row['start_date'],
            'end_date' => (string) $row['end_date'],
            'achieved' => (bool) ($row['achieved'] ?? false),
            'participants' => $participants,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }
}
