<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ReportController extends Controller
{
    private const CACHE_TTL_MINUTES = 30;

    public function __construct(private ReportService $reports) {}

    public function monthly(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $month = $request->query('month');
        $monthKey = is_string($month) && preg_match('/^\d{4}-\d{2}$/', $month) ? $month : 'current';
        $cacheKey = "api:reports:monthly:user:{$userId}:{$monthKey}";

        $data = Cache::remember(
            $cacheKey,
            now()->addMinutes(self::CACHE_TTL_MINUTES),
            fn (): array => $this->reports->monthlyForUser(
                $userId,
                $monthKey === 'current' ? null : $monthKey,
            ),
        );

        return ApiResponse::success($data);
    }
}
