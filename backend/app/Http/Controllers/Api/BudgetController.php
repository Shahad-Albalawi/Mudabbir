<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Budget\StoreBudgetRequest;
use App\Http\Requests\Budget\UpdateBudgetRequest;
use App\Services\BudgetStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function __construct(private BudgetStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return $this->success($this->store->all($userId));
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = $this->store->find($id, $userId);
        if (! $budget) {
            return $this->notFound('Budget not found');
        }

        return $this->success($budget);
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return $this->created(
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
            return $this->notFound('Budget not found');
        }

        if (! empty($result['conflict'])) {
            return $this->conflict(
                'Server has a newer version of this budget.',
                $result['data']
            );
        }

        return $this->success($result['data']);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Budget not found');
        }

        return $this->success(null, 'Deleted');
    }
}
