<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Challenge\CreateChallengeFromTemplateRequest;
use App\Http\Requests\Challenge\InviteChallengeRequest;
use App\Http\Requests\Challenge\RecordChallengeProgressRequest;
use App\Http\Requests\Challenge\RespondChallengeRequest;
use App\Http\Requests\Challenge\StoreChallengeRequest;
use App\Http\Requests\Challenge\UpdateChallengeRequest;
use App\Services\ChallengeStore;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    public function __construct(private ChallengeStore $store) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        return $this->success($this->store->all($userId));
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = $this->store->find($id, $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($challenge);
    }

    public function store(StoreChallengeRequest $request): JsonResponse
    {
        return $this->created(
            $this->store->create(
                $request->validated(),
                $this->creatorFromUser($request->user())
            )
        );
    }

    public function update(UpdateChallengeRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = $this->store->update($id, $request->validated(), $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($challenge);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Challenge not found');
        }

        return $this->success(null, 'Deleted');
    }

    public function invite(InviteChallengeRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = $this->store->invite($id, (string) $request->validated()['email'], $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($challenge);
    }

    public function removeParticipant(Request $request, int $id, int $userId): JsonResponse
    {
        $actingUserId = (int) $request->user()->id;
        $challenge = $this->store->removeParticipant($id, $userId, $actingUserId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($challenge);
    }

    public function toggleStatus(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = $this->store->toggleStatus($id, $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($challenge);
    }

    public function respond(RespondChallengeRequest $request, int $id): JsonResponse
    {
        $user = $request->user();
        $challenge = $this->store->respond(
            $id,
            (string) $request->validated()['status'],
            (int) $user->id,
            (string) $user->email
        );
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($challenge);
    }

    public function pendingInvitations(Request $request): JsonResponse
    {
        $user = $request->user();

        return $this->success(
            $this->store->pendingInvitations((int) $user->id, (string) $user->email)
        );
    }

    public function templates(): JsonResponse
    {
        return $this->success($this->store->templates());
    }

    public function createFromTemplate(CreateChallengeFromTemplateRequest $request): JsonResponse
    {
        $challenge = $this->store->createFromTemplate(
            (string) $request->validated()['template_id'],
            $this->creatorFromUser($request->user())
        );
        if (! $challenge) {
            return $this->notFound('Template not found');
        }

        return $this->created($challenge);
    }

    public function checkIn(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $result = $this->store->checkIn($id, $userId);
        if (! $result) {
            return $this->notFound('Challenge or participant not found');
        }

        return $this->success($result['challenge'], '', 200, [
            'meta' => $result['meta'],
        ]);
    }

    public function recordProgress(RecordChallengeProgressRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = $this->store->recordProgress(
            $id,
            $userId,
            (float) $request->validated()['amount']
        );
        if (! $challenge) {
            return $this->notFound('Challenge or participant not found');
        }

        return $this->success($challenge);
    }

    public function leaderboard(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $board = $this->store->leaderboard($id, $userId);
        if (! $board) {
            return $this->notFound('Challenge not found');
        }

        return $this->success($board);
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
