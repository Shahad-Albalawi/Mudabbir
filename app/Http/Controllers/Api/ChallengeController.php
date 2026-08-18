<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Concerns\AuthorizesResourceAccess;
use App\Http\Controllers\Controller;
use App\Http\Requests\Challenge\CreateChallengeFromTemplateRequest;
use App\Http\Requests\Challenge\InviteChallengeRequest;
use App\Http\Requests\Challenge\RecordChallengeProgressRequest;
use App\Http\Requests\Challenge\RespondChallengeRequest;
use App\Http\Requests\Challenge\StoreChallengeRequest;
use App\Http\Requests\Challenge\UpdateChallengeRequest;
use App\Http\Requests\PaginatedListRequest;
use App\Http\Resources\ChallengeResource;
use App\Models\Challenge;
use App\Repositories\ChallengeRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    use AuthorizesResourceAccess;

    public function __construct(private ChallengeRepository $store) {}

    public function index(PaginatedListRequest $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        $paginator = Challenge::query()
            ->with('participants')
            ->accessibleBy($userId)
            ->orderByDesc('id')
            ->paginate($request->perPage());

        $paginator->through(
            fn (Challenge $challenge): array => (new ChallengeResource($challenge))->resolve($request)
        );

        return $this->paginated($paginator, 'Challenges loaded');
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $challenge = Challenge::query()
            ->with('participants')
            ->whereKey($id)
            ->first();

        if ($challenge === null || ! $this->canAccess($request, 'view', $challenge)) {
            return $this->notFound('Challenge not found');
        }

        return $this->success((new ChallengeResource($challenge))->resolve($request));
    }

    public function store(StoreChallengeRequest $request): JsonResponse
    {
        $challenge = $this->store->create(
            $request->validated(),
            $this->creatorFromUser($request->user())
        );

        return $this->created(ChallengeResource::fromStoreArray($challenge));
    }

    public function update(UpdateChallengeRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'update', $challenge)) {
            return $this->notFound('Challenge not found');
        }

        $challenge = $this->store->update($id, $request->validated(), $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }


        return $this->success(ChallengeResource::fromStoreArray($challenge));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'delete', $challenge)) {
            return $this->notFound('Challenge not found');
        }

        if (! $this->store->delete($id, $userId)) {
            return $this->notFound('Challenge not found');
        }


        return $this->success(null, 'Deleted');
    }

    public function invite(InviteChallengeRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'invite', $challenge)) {
            return $this->notFound('Challenge not found');
        }

        $challenge = $this->store->invite($id, (string) $request->validated()['email'], $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }


        return $this->success(ChallengeResource::fromStoreArray($challenge));
    }

    public function removeParticipant(Request $request, int $id, int $userId): JsonResponse
    {
        $actingUserId = (int) $request->user()->id;
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $request->user()?->can('removeParticipant', [$challenge, $userId])) {
            return $this->notFound('Challenge not found');
        }

        $challenge = $this->store->removeParticipant($id, $userId, $actingUserId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }


        return $this->success(ChallengeResource::fromStoreArray($challenge));
    }

    public function toggleStatus(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'toggleStatus', $challenge)) {
            return $this->notFound('Challenge not found');
        }

        $challenge = $this->store->toggleStatus($id, $userId);
        if (! $challenge) {
            return $this->notFound('Challenge not found');
        }


        return $this->success(ChallengeResource::fromStoreArray($challenge));
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


        return $this->success(ChallengeResource::fromStoreArray($challenge));
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


        return $this->created(ChallengeResource::fromStoreArray($challenge));
    }

    public function checkIn(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'participate', $challenge)) {
            return $this->notFound('Challenge or participant not found');
        }

        $result = $this->store->checkIn($id, $userId);
        if (! $result) {
            return $this->notFound('Challenge or participant not found');
        }


        return $this->success(
            ChallengeResource::fromStoreArray($result['challenge']),
            '',
            200,
            ['meta' => $result['meta']],
        );
    }

    public function recordProgress(RecordChallengeProgressRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->with('participants')->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'participate', $challenge)) {
            return $this->notFound('Challenge or participant not found');
        }

        $challenge = $this->store->recordProgress(
            $id,
            $userId,
            (float) $request->validated()['amount']
        );
        if (! $challenge) {
            return $this->notFound('Challenge or participant not found');
        }


        return $this->success(ChallengeResource::fromStoreArray($challenge));
    }

    public function leaderboard(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $challenge = Challenge::query()->whereKey($id)->first();
        if ($challenge === null || ! $this->canAccess($request, 'view', $challenge)) {
            return $this->notFound('Challenge not found');
        }

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
