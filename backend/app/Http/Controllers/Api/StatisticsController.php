<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use App\Http\Controllers\Controller;
use App\Http\Requests\StatisticsRangeRequest;
use App\Services\StatisticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class StatisticsController extends Controller
{
    private const CACHE_TTL_MINUTES = 5;

    public function __construct(private StatisticsService $statistics) {}

    public function index(StatisticsRangeRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $range = $request->resolvedRange();
        $useCalendarMonth = ! $request->filled('from')
            && ! $request->filled('to')
            && ! $request->filled('period');

        $cacheKey = $useCalendarMonth
            ? "api:statistics:user:{$userId}:month"
            : "api:statistics:user:{$userId}:{$request->cacheSuffix()}";

        $data = Cache::remember(
            $cacheKey,
            now()->addMinutes(self::CACHE_TTL_MINUTES),
            function () use ($userId, $range, $useCalendarMonth): array {
                if ($useCalendarMonth) {
                    return $this->statistics->forUser($userId);
                }

                return $this->statistics->forUserRange(
                    $userId,
                    $range['from'],
                    $range['to'],
                );
            },
        );

        return ApiResponse::success($data);
    }
}
