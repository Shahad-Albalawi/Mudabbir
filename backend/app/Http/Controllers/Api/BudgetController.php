<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Concerns\DualWritesLegacyJson;
use App\Http\Controllers\Controller;
use App\Http\Requests\Budget\StoreBudgetRequest;
use App\Http\Requests\Budget\UpdateBudgetRequest;
use App\Models\Budget;
use App\Services\BudgetStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    use DualWritesLegacyJson;

    public function __construct(private BudgetStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budgets = Budget::query()
            ->forUser($userId)
            ->orderByDesc('id')
            ->get()
            ->map(fn (Budget $budget): array => $budget->toStoreArray())
            ->all();

        return $this->success($budgets);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = Budget::query()
            ->forUser($userId)
            ->whereKey($id)
            ->first();

        if (! $budget) {
            return $this->notFound('Budget not found');
        }

        return $this->success($budget->toStoreArray());
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = $this->store->create($request->validated(), $userId);
        $this->mirrorBudgetToLegacyJson($budget);

        return $this->created($budget);
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

        $this->mirrorBudgetToLegacyJson($result['data']);

        return $this->success($result['data']);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Budget not found');
        }

        $this->mirrorBudgetDeleteToLegacyJson($id, $userId);

        return $this->success(null, 'Deleted');
    }
}
