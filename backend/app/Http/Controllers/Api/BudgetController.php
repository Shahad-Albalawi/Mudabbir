<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Concerns\AuthorizesResourceAccess;
use App\Http\Controllers\Concerns\DualWritesLegacyJson;
use App\Http\Controllers\Controller;
use App\Http\Requests\Budget\StoreBudgetRequest;
use App\Http\Requests\Budget\UpdateBudgetRequest;
use App\Http\Requests\PaginatedListRequest;
use App\Http\Resources\BudgetResource;
use App\Models\Budget;
use App\Repositories\BudgetRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    use AuthorizesResourceAccess;
    use DualWritesLegacyJson;

    public function __construct(private BudgetRepository $store) {}

    public function index(PaginatedListRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        $paginator = Budget::query()
            ->forUser($userId)
            ->orderByDesc('id')
            ->paginate($request->perPage());

        $paginator->through(
            fn (Budget $budget): array => (new BudgetResource($budget))->resolve($request)
        );

        return $this->paginated($paginator, 'Budgets loaded');
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $budget = Budget::query()->whereKey($id)->first();

        if ($budget === null || ! $this->canAccess($request, 'view', $budget)) {
            return $this->notFound('Budget not found');
        }

        return $this->success((new BudgetResource($budget))->resolve($request));
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = $this->store->create($request->validated(), $userId);
        $this->mirrorBudgetToLegacyJson($budget);

        return $this->created(BudgetResource::fromStoreArray($budget));
    }

    public function update(UpdateBudgetRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = Budget::query()->whereKey($id)->first();
        if ($budget === null || ! $this->canAccess($request, 'update', $budget)) {
            return $this->notFound('Budget not found');
        }

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
                BudgetResource::fromStoreArray($result['data'])
            );
        }

        $this->mirrorBudgetToLegacyJson($result['data']);

        return $this->success(BudgetResource::fromStoreArray($result['data']));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $budget = Budget::query()->whereKey($id)->first();
        if ($budget === null || ! $this->canAccess($request, 'delete', $budget)) {
            return $this->notFound('Budget not found');
        }

        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Budget not found');
        }

        $this->mirrorBudgetDeleteToLegacyJson($id, $userId);

        return $this->success(null, 'Deleted');
    }
}
