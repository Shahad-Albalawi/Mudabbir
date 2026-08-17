<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Concerns\AuthorizesResourceAccess;
use App\Http\Controllers\Concerns\DualWritesLegacyJson;
use App\Http\Controllers\Controller;
use App\Http\Requests\Goal\AddGoalContributionRequest;
use App\Http\Requests\Goal\StoreGoalMilestoneRequest;
use App\Http\Requests\Goal\StoreGoalRequest;
use App\Http\Requests\Goal\UpdateGoalRequest;
use App\Http\Requests\PaginatedListRequest;
use App\Http\Resources\GoalResource;
use App\Models\Goal;
use App\Repositories\GoalRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    use AuthorizesResourceAccess;
    use DualWritesLegacyJson;

    public function __construct(private GoalRepository $store) {}

    public function index(PaginatedListRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        $paginator = Goal::query()
            ->forUser($userId)
            ->with(['contributions', 'milestones'])
            ->orderByDesc('id')
            ->paginate($request->perPage());

        $paginator->through(
            fn (Goal $goal): array => (new GoalResource($goal->toStoreArray()))->resolve($request)
        );

        return $this->paginated($paginator, 'Goals loaded');
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $goal = Goal::query()
            ->with(['contributions', 'milestones'])
            ->whereKey($id)
            ->first();

        if ($goal === null || ! $this->canAccess($request, 'view', $goal)) {
            return $this->notFound('Goal not found');
        }

        return $this->success((new GoalResource($goal->toStoreArray()))->resolve($request));
    }

    public function store(StoreGoalRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->create($request->validated(), $userId);
        $this->mirrorGoalToLegacyJson($goal);

        return $this->created((new GoalResource($goal))->resolve($request));
    }

    public function addMilestone(
        StoreGoalMilestoneRequest $request,
        int $id,
    ): JsonResponse {
        $userId = (int) $request->user()->id;
        $goal = Goal::query()->whereKey($id)->first();
        if ($goal === null || ! $this->canAccess($request, 'addMilestone', $goal)) {
            return $this->notFound('Goal not found');
        }

        $goal = $this->store->addMilestone($id, $request->validated(), $userId);
        if (! $goal) {
            return $this->notFound('Goal not found');
        }

        $this->mirrorGoalToLegacyJson($goal);

        return $this->created((new GoalResource($goal))->resolve($request), 'Milestone added');
    }

    public function addContribution(AddGoalContributionRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = Goal::query()->whereKey($id)->first();
        if ($goal === null || ! $this->canAccess($request, 'contribute', $goal)) {
            return $this->notFound('Goal not found or already completed');
        }

        $goal = $this->store->addContribution($id, $request->validated(), $userId);
        if (! $goal) {
            return $this->notFound('Goal not found or already completed');
        }

        $this->mirrorGoalToLegacyJson($goal);

        return $this->success((new GoalResource($goal))->resolve($request));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = Goal::query()->whereKey($id)->first();
        if ($goal === null || ! $this->canAccess($request, 'delete', $goal)) {
            return $this->notFound('Goal not found');
        }

        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Goal not found');
        }

        $this->mirrorGoalDeleteToLegacyJson($id, $userId);

        return $this->success(null, 'Deleted');
    }

    public function update(UpdateGoalRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = Goal::query()->whereKey($id)->first();
        if ($goal === null || ! $this->canAccess($request, 'update', $goal)) {
            return $this->notFound('Goal not found');
        }

        $result = $this->store->update(
            $id,
            $request->validated(),
            $userId,
            $request->input('updated_at')
        );
        if (! $result) {
            return $this->notFound('Goal not found');
        }

        if (! empty($result['conflict'])) {
            return $this->conflict(
                'Server has a newer version of this goal.',
                (new GoalResource($result['data']))->resolve($request)
            );
        }

        $this->mirrorGoalToLegacyJson($result['data']);

        return $this->success((new GoalResource($result['data']))->resolve($request));
    }
}
