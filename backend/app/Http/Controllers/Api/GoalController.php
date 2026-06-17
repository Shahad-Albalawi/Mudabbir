<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\GoalStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    /** @var GoalStore */
    private $store;

    public function __construct(GoalStore $store)
    {
        $this->store = $store;
    }

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return response()->json(['success' => true, 'data' => $this->store->all($userId)]);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $goal = $this->store->find($id, $userId);
        if (! $goal) {
            return response()->json(['success' => false, 'message' => 'Goal not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $goal]);
    }

    public function store(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'target' => ['required', 'numeric', 'min:0.01'],
            'current_amount' => ['sometimes', 'numeric', 'min:0'],
            'type' => ['sometimes', 'string', 'max:64'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
            'image_path' => ['nullable', 'string'],
        ]);

        $userId = (int) $request->user()->id;

        return response()->json(
            ['success' => true, 'data' => $this->store->create($payload, $userId)],
            201
        );
    }

    public function addContribution(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'note' => ['nullable', 'string'],
        ]);

        $userId = (int) $request->user()->id;
        $goal = $this->store->addContribution($id, $payload, $userId);
        if (! $goal) {
            return response()->json(
                ['success' => false, 'message' => 'Goal not found or already completed'],
                404
            );
        }

        return response()->json(['success' => true, 'data' => $goal]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return response()->json(['success' => false, 'message' => 'Goal not found'], 404);
        }

        return response()->json(['success' => true, 'message' => 'Deleted']);
    }
}
