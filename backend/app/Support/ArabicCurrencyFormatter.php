<?php

namespace App\Support;

final class ArabicCurrencyFormatter
{
    private const EASTERN_DIGITS = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    public static function format(float $amount): string
    {
        $formatted = number_format($amount, 2, '.', ',');
        $parts = explode('.', $formatted);
        $integer = self::toEasternDigits(str_replace(',', '٬', $parts[0]));
        $fraction = self::toEasternDigits($parts[1] ?? '00');

        return $integer.'٫'.$fraction.' ﷼';
    }

    private static function toEasternDigits(string $value): string
    {
        return strtr($value, array_combine(range('0', '9'), self::EASTERN_DIGITS));
    }
}
