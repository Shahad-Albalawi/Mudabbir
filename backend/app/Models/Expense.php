<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Expense extends Model
{
    public $incrementing = false;

    protected $keyType = 'int';

    protected $fillable = [
        'id',
        'user_id',
        'amount',
        'date',
        'type',
        'notes',
        'account_id',
        'category_id',
        'account_name',
        'category_name',
        'is_recurring',
        'recurrence_interval',
        'synced_at',
    ];

    protected $casts = [
        'amount' => 'float',
        'date' => 'date',
        'is_recurring' => 'boolean',
        'synced_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function scopeForUser(Builder $query, int $userId): Builder
    {
        return $query->where('user_id', $userId);
    }

    public function scopeByDateRange(Builder $query, ?string $from, ?string $to): Builder
    {
        if ($from) {
            $query->whereDate('date', '>=', $from);
        }
        if ($to) {
            $query->whereDate('date', '<=', $to);
        }

        return $query;
    }

    public function scopeByCategory(Builder $query, ?string $category): Builder
    {
        if ($category === null || $category === '') {
            return $query;
        }

        if (is_numeric($category)) {
            return $query->where('category_id', (int) $category);
        }

        return $query->where('category_name', $category);
    }

    public function scopeByAmount(Builder $query, ?float $min, ?float $max): Builder
    {
        if ($min !== null) {
            $query->where('amount', '>=', $min);
        }
        if ($max !== null) {
            $query->where('amount', '<=', $max);
        }

        return $query;
    }

    public function scopeSorted(Builder $query, string $sort = 'date'): Builder
    {
        return match ($sort) {
            'amount' => $query->orderByDesc('amount')->orderByDesc('date'),
            default => $query->orderByDesc('date')->orderByDesc('id'),
        };
    }
}
