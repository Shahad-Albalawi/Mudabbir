<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ExpenseStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    /** @var ExpenseStore */
    private $store;

    public function __construct(ExpenseStore $store)
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
        $expense = $this->store->find($id, $userId);
        if (! $expense) {
            return response()->json(['success' => false, 'message' => 'Expense not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $expense]);
    }

    public function store(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'date' => ['required', 'date'],
            'type' => ['sometimes', 'string', 'in:expense,income'],
            'notes' => ['nullable', 'string'],
            'account_id' => ['required', 'integer', 'min:1'],
            'category_id' => ['required', 'integer', 'min:1'],
            'account_name' => ['nullable', 'string', 'max:255'],
            'category_name' => ['nullable', 'string', 'max:255'],
            'is_recurring' => ['sometimes', 'boolean'],
            'recurrence_interval' => ['nullable', 'string', 'max:32'],
        ]);

        $userId = (int) $request->user()->id;

        return response()->json(
            ['success' => true, 'data' => $this->store->create($payload, $userId)],
            201
        );
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'amount' => ['sometimes', 'numeric', 'min:0.01'],
            'date' => ['sometimes', 'date'],
            'type' => ['sometimes', 'string', 'in:expense,income'],
            'notes' => ['nullable', 'string'],
            'account_id' => ['sometimes', 'integer', 'min:1'],
            'category_id' => ['sometimes', 'integer', 'min:1'],
            'account_name' => ['nullable', 'string', 'max:255'],
            'category_name' => ['nullable', 'string', 'max:255'],
            'is_recurring' => ['sometimes', 'boolean'],
            'recurrence_interval' => ['nullable', 'string', 'max:32'],
            'updated_at' => ['nullable', 'date'],
        ]);

        $userId = (int) $request->user()->id;
        $result = $this->store->update(
            $id,
            $payload,
            $userId,
            $request->input('updated_at')
        );
        if (! $result) {
            return response()->json(['success' => false, 'message' => 'Expense not found'], 404);
        }

        if (! empty($result['conflict'])) {
            return response()->json([
                'success' => false,
                'conflict' => true,
                'message' => 'Server has a newer version of this expense.',
                'data' => $result['data'],
            ], 409);
        }

        return response()->json(['success' => true, 'data' => $result['data']]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return response()->json(['success' => false, 'message' => 'Expense not found'], 404);
        }

        return response()->json(['success' => true, 'message' => 'Deleted']);
    }
}
