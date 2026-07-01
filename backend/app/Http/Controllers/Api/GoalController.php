<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Goal\AddGoalContributionRequest;
use App\Http\Requests\Goal\StoreGoalMilestoneRequest;
use App\Http\Requests\Goal\StoreGoalRequest;
use App\Http\Requests\Goal\UpdateGoalRequest;
use App\Http\Resources\GoalResource;
use App\Services\GoalStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function __construct(private GoalStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goals = collect($this->store->all($userId))
            ->map(fn (array $goal): array => (new GoalResource($goal))->resolve($request))
            ->all();

        return $this->success($goals);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->find($id, $userId);
        if (! $goal) {
            return $this->notFound('Goal not found');
        }

        return $this->success((new GoalResource($goal))->resolve($request));
    }

    public function store(StoreGoalRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->create($request->validated(), $userId);

        return $this->created((new GoalResource($goal))->resolve($request));
    }

    public function addMilestone(
        StoreGoalMilestoneRequest $request,
        int $id,
    ): JsonResponse {
        $userId = (int) $request->user()->id;
        $goal = $this->store->addMilestone($id, $request->validated(), $userId);
        if (! $goal) {
            return $this->notFound('Goal not found');
        }

        return $this->created((new GoalResource($goal))->resolve($request), 'Milestone added');
    }

    public function addContribution(AddGoalContributionRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->addContribution($id, $request->validated(), $userId);
        if (! $goal) {
            return $this->notFound('Goal not found or already completed');
        }

        return $this->success((new GoalResource($goal))->resolve($request));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Goal not found');
        }

        return $this->success(null, 'Deleted');
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
            return $this->notFound('Goal not found');
        }

        if (! empty($result['conflict'])) {
            return $this->conflict(
                'Server has a newer version of this goal.',
                (new GoalResource($result['data']))->resolve($request)
            );
        }

        return $this->success((new GoalResource($result['data']))->resolve($request));
    }
}
