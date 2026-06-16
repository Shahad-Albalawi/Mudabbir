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

    public function index(): JsonResponse
    {
        return response()->json(['success' => true, 'data' => $this->store->all()]);
    }

    public function show(int $id): JsonResponse
    {
        $expense = $this->store->find($id);
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

        return response()->json(
            ['success' => true, 'data' => $this->store->create($payload)],
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
        ]);

        $expense = $this->store->update($id, $payload);
        if (! $expense) {
            return response()->json(['success' => false, 'message' => 'Expense not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $expense]);
    }

    public function destroy(int $id): JsonResponse
    {
        if (! $this->store->delete($id)) {
            return response()->json(['success' => false, 'message' => 'Expense not found'], 404);
        }

        return response()->json(['success' => true, 'message' => 'Deleted']);
    }
}
