<?php

namespace App\Policies;

use App\Models\Challenge;
use App\Models\User;

class ChallengePolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Challenge $challenge): bool
    {
        return $challenge->isAccessibleBy((int) $user->id);
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Challenge $challenge): bool
    {
        return $challenge->isCreator((int) $user->id);
    }

    public function delete(User $user, Challenge $challenge): bool
    {
        return $challenge->isCreator((int) $user->id);
    }

    public function invite(User $user, Challenge $challenge): bool
    {
        return $challenge->isCreator((int) $user->id);
    }

    public function toggleStatus(User $user, Challenge $challenge): bool
    {
        return $challenge->isCreator((int) $user->id);
    }

    public function removeParticipant(User $user, Challenge $challenge, int $participantId): bool
    {
        if (! $challenge->isAccessibleBy((int) $user->id)) {
            return false;
        }

        if ($participantId === (int) $challenge->creator_id) {
            return false;
        }

        if ($challenge->isCreator((int) $user->id)) {
            return true;
        }

        return $participantId === (int) $user->id;
    }

    public function participate(User $user, Challenge $challenge): bool
    {
        return $challenge->hasAcceptedParticipant((int) $user->id);
    }
}
