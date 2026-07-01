<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Expense\StoreExpenseRequest;
use App\Http\Requests\Expense\UpdateExpenseRequest;
use App\Http\Resources\ExpenseResource;
use App\Models\Expense;
use App\Services\ExpenseDatabaseSync;
use App\Services\ExpenseStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    public function __construct(
        private ExpenseStore $store,
        private ExpenseDatabaseSync $sync,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $this->sync->syncUser($userId);

        $perPage = min(max((int) $request->query('per_page', 15), 1), 100);
        $sort = (string) $request->query('sort', 'date');
        if (! in_array($sort, ['amount', 'date'], true)) {
            $sort = 'date';
        }

        $paginator = Expense::query()
            ->forUser($userId)
            ->byDateRange($request->query('from'), $request->query('to'))
            ->byCategory($request->query('category'))
            ->byAmount(
                $request->filled('min') ? (float) $request->query('min') : null,
                $request->filled('max') ? (float) $request->query('max') : null,
            )
            ->sorted($sort)
            ->paginate($perPage);

        $paginator->through(
            fn (Expense $expense): array => (new ExpenseResource($expense))->resolve($request)
        );

        return $this->paginated($paginator, 'Expenses loaded');
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $expense = $this->store->find($id, $userId);
        if (! $expense) {
            return $this->notFound('Expense not found');
        }

        return $this->success(ExpenseResource::fromStoreArray($expense));
    }

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $expense = $this->store->create($request->validated(), $userId);

        return $this->created(ExpenseResource::fromStoreArray($expense));
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
            return $this->notFound('Expense not found');
        }

        if (! empty($result['conflict'])) {
            return $this->conflict(
                'Server has a newer version of this expense.',
                ExpenseResource::fromStoreArray($result['data'])
            );
        }

        return $this->success(ExpenseResource::fromStoreArray($result['data']));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Expense not found');
        }

        return $this->success(null, 'Deleted');
    }
}
