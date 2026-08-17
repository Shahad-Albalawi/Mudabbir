<?php

namespace App\Http\Resources;

use App\Models\Challenge;
use App\Support\ArabicCurrencyFormatter;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Challenge|array<string, mixed> */
class ChallengeResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        $challenge = $this->resource instanceof Challenge
            ? $this->resource->toStoreArray()
            : (array) $this->resource;

        return self::shape($challenge);
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    public static function fromStoreArray(array $row): array
    {
        return self::shape($row);
    }

    /**
     * @param  array<string, mixed>  $challenge
     * @return array<string, mixed>
     */
    private static function shape(array $challenge): array
    {
        $amount = (float) ($challenge['amount'] ?? 0);

        return [
            'id' => (int) $challenge['id'],
            'user_id' => (int) ($challenge['user_id'] ?? 0),
            'name' => (string) ($challenge['name'] ?? ''),
            'amount' => $amount,
            'amount_formatted' => ArabicCurrencyFormatter::format($amount),
            'start_date' => (string) $challenge['start_date'],
            'end_date' => (string) $challenge['end_date'],
            'achieved' => (bool) ($challenge['achieved'] ?? false),
            'creator_id' => (int) ($challenge['creator_id'] ?? 0),
            'creator' => $challenge['creator'] ?? null,
            'participants' => $challenge['participants'] ?? [],
            'created_at' => $challenge['created_at'] ?? null,
            'updated_at' => $challenge['updated_at'] ?? null,
        ];
    }
}
