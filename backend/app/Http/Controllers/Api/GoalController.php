<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Goal\AddGoalContributionRequest;
use App\Http\Requests\Goal\StoreGoalRequest;
use App\Http\Requests\Goal\UpdateGoalRequest;
use App\Services\GoalStore;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function __construct(private readonly GoalStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return ApiResponse::success($this->store->all($userId));
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->find($id, $userId);
        if (! $goal) {
            return ApiResponse::notFound('Goal not found');
        }

        return ApiResponse::success($goal);
    }

    public function store(StoreGoalRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return ApiResponse::created(
            $this->store->create($request->validated(), $userId)
        );
    }

    public function addContribution(AddGoalContributionRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->addContribution($id, $request->validated(), $userId);
        if (! $goal) {
            return ApiResponse::notFound('Goal not found or already completed');
        }

        return ApiResponse::success($goal);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return ApiResponse::notFound('Goal not found');
        }

        return ApiResponse::success(null, 'Deleted');
    }

    public function update(UpdateGoalRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $result = $this->store->update(
            $id,
            $request->validated(),
            $userId,
            $request->input('updated_at')
        );
        if (! $result) {
            return ApiResponse::notFound('Goal not found');
        }

        if (! empty($result['conflict'])) {
            return ApiResponse::conflict(
                'Server has a newer version of this goal.',
                $result['data']
            );
        }

        return ApiResponse::success($result['data']);
    }
}
