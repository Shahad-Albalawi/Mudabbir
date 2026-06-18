<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ChallengeStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    /** @var ChallengeStore */
    private $store;

    public function __construct(ChallengeStore $store)
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
        $challenge = $this->store->find($id, $userId);
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

        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => $this->store->create($payload, $this->creatorFromUser($user)),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'amount' => ['sometimes', 'numeric', 'min:0'],
            'start_date' => ['sometimes', 'date'],
            'end_date' => ['sometimes', 'date'],
        ]);

        $userId = (int) $request->user()->id;
        $challenge = $this->store->update($id, $payload, $userId);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'message' => 'Deleted']);
    }

    public function invite(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'email' => ['required', 'email'],
        ]);

        $userId = (int) $request->user()->id;
        $challenge = $this->store->invite($id, (string) $payload['email'], $userId);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function removeParticipant(Request $request, int $id, int $userId): JsonResponse
    {
        $actingUserId = (int) $request->user()->id;
        $challenge = $this->store->removeParticipant($id, $userId, $actingUserId);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function toggleStatus(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = $this->store->toggleStatus($id, $userId);
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

        $user = $request->user();
        $challenge = $this->store->respond(
            $id,
            (string) $payload['status'],
            (int) $user->id,
            (string) $user->email
        );
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function pendingInvitations(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => $this->store->pendingInvitations((int) $user->id, (string) $user->email),
        ]);
    }

    public function templates(): JsonResponse
    {
        return response()->json(['success' => true, 'data' => $this->store->templates()]);
    }

    public function createFromTemplate(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'template_id' => ['required', 'string', 'max:64'],
        ]);

        $challenge = $this->store->createFromTemplate(
            (string) $payload['template_id'],
            $this->creatorFromUser($request->user())
        );
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Template not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge], 201);
    }

    public function checkIn(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $result = $this->store->checkIn($id, $userId);
        if (! $result) {
            return response()->json(['success' => false, 'message' => 'Challenge or participant not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $result['challenge'],
            'meta' => $result['meta'],
        ]);
    }

    public function recordProgress(Request $request, int $id): JsonResponse
    {
        $payload = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
        ]);

        $userId = (int) $request->user()->id;
        $challenge = $this->store->recordProgress($id, $userId, (float) $payload['amount']);
        if (! $challenge) {
            return response()->json(['success' => false, 'message' => 'Challenge or participant not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $challenge]);
    }

    public function leaderboard(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $board = $this->store->leaderboard($id, $userId);
        if (! $board) {
            return response()->json(['success' => false, 'message' => 'Challenge not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $board]);
    }

    /**
     * @return array{id: int, name: string, email: string}
     */
    private function creatorFromUser($user): array
    {
        return [
            'id' => (int) $user->id,
            'name' => (string) $user->name,
            'email' => (string) $user->email,
        ];
    }
}
