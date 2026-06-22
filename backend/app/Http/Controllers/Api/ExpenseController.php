<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Expense\StoreExpenseRequest;
use App\Http\Requests\Expense\UpdateExpenseRequest;
use App\Services\ExpenseStore;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    public function __construct(private readonly ExpenseStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return ApiResponse::success($this->store->all($userId));
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $expense = $this->store->find($id, $userId);
        if (! $expense) {
            return ApiResponse::notFound('Expense not found');
        }

        return ApiResponse::success($expense);
    }

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return ApiResponse::created(
            $this->store->create($request->validated(), $userId)
        );
    }

    public function update(UpdateExpenseRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $result = $this->store->update(
            $id,
            $request->validated(),
            $userId,
            $request->input('updated_at')
        );
        if (! $result) {
            return ApiResponse::notFound('Expense not found');
        }

        if (! empty($result['conflict'])) {
            return ApiResponse::conflict(
                'Server has a newer version of this expense.',
                $result['data']
            );
        }

        return ApiResponse::success($result['data']);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return ApiResponse::notFound('Expense not found');
        }

        return ApiResponse::success(null, 'Deleted');
    }
}
