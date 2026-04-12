<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ChallengeStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    public function __construct(private readonly ChallengeStore $store) {}

    public function index(): JsonResponse
    {
        return response()->json(['success' => true, 'data' => $this->store->all()]);
    }

    public function show(int $id): JsonResponse
    {
        $challenge = $this->store->find($id);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function store(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
        ]);

        return response()->json(['success' => true, 'data' => $this->store->create($payload)], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'amount' => ['sometimes', 'numeric', 'min:0'],
            'start_date' => ['sometimes', 'date'],
            'end_date' => ['sometimes', 'date'],
        ]);

        $challenge = $this->store->update($id, $payload);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function destroy(int $id): JsonResponse
    {
        if (! $this->store->delete($id)) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'message' => 'Deleted']);
    }

    public function invite(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'email' => ['required', 'email'],
        ]);
        $challenge = $this->store->invite($id, (string) $payload['email']);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function removeParticipant(int $id, int $userId): JsonResponse
    {
        $challenge = $this->store->removeParticipant($id, $userId);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function toggleStatus(int $id): JsonResponse
    {
        $challenge = $this->store->toggleStatus($id);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function respond(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'status' => ['required', 'in:accepted,rejected'],
        ]);

        $challenge = $this->store->respond($id, (string) $payload['status']);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function pendingInvitations(): JsonResponse
    {
        return response()->json(['success' => true, 'data' => $this->store->pendingInvitations()]);
    }
}
