<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use App\Http\Controllers\Controller;
use App\Services\StatisticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class StatisticsController extends Controller
{
    private const CACHE_TTL_MINUTES = 5;

    public function __construct(private StatisticsService $statistics) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $cacheKey = "api:statistics:user:{$userId}";

        $data = Cache::remember(
            $cacheKey,
            now()->addMinutes(self::CACHE_TTL_MINUTES),
            fn (): array => $this->statistics->forUser($userId),
        );

        return ApiResponse::success($data);
    }
}
