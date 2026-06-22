<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Budget\StoreBudgetRequest;
use App\Http\Requests\Budget\UpdateBudgetRequest;
use App\Services\BudgetStore;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function __construct(private readonly BudgetStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return ApiResponse::success($this->store->all($userId));
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = $this->store->find($id, $userId);
        if (! $budget) {
            return ApiResponse::notFound('Budget not found');
        }

        return ApiResponse::success($budget);
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return ApiResponse::created(
            $this->store->create($request->validated(), $userId)
        );
    }

    public function update(UpdateBudgetRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $result = $this->store->update(
            $id,
            $request->validated(),
            $userId,
            $request->input('updated_at')
        );
        if (! $result) {
            return ApiResponse::notFound('Budget not found');
        }

        if (! empty($result['conflict'])) {
            return ApiResponse::conflict(
                'Server has a newer version of this budget.',
                $result['data']
            );
        }

        return ApiResponse::success($result['data']);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return ApiResponse::notFound('Budget not found');
        }

        return ApiResponse::success(null, 'Deleted');
    }
}
