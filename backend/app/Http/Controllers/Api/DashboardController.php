<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use App\Http\Controllers\Controller;
use App\Services\DashboardCache;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class DashboardController extends Controller
{
    public function __construct(private DashboardService $dashboard) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $cacheKey = DashboardCache::keyForUser($userId);

        $data = Cache::remember(
            $cacheKey,
            now()->addMinutes(DashboardCache::TTL_MINUTES),
            fn (): array => $this->dashboard->forUser($userId),
        );

        return ApiResponse::success($data);
    }
}
