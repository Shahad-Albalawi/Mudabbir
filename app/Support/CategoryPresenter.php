<?php

namespace App\Support;

final class CategoryPresenter
{
    /** @var array<string, array{icon: string, color: string}> */
    private const MAP = [
        'طعام' => ['icon' => '🍽️', 'color' => '#4382DF'],
        'نقل' => ['icon' => '🚗', 'color' => '#4647AE'],
        'تسوق' => ['icon' => '🛍️', 'color' => '#AACCD6'],
        'فواتير' => ['icon' => '🧾', 'color' => '#112E81'],
        'صحة' => ['icon' => '💊', 'color' => '#10B981'],
        'ترفيه' => ['icon' => '🎬', 'color' => '#F59E0B'],
        'راتب' => ['icon' => '💰', 'color' => '#10B981'],
        'مكافأة' => ['icon' => '🎁', 'color' => '#10B981'],
        'هبه' => ['icon' => '🎁', 'color' => '#10B981'],
        'اخرى' => ['icon' => '📌', 'color' => '#64748B'],
        'Uncategorized' => ['icon' => '📊', 'color' => '#94A3B8'],
    ];

    /**
     * @return array{icon: string, color: string}
     */
    public static function present(?string $categoryName): array
    {
        $name = trim((string) $categoryName);
        if ($name !== '' && isset(self::MAP[$name])) {
            return self::MAP[$name];
        }

        return self::MAP['اخرى'];
    }
}
