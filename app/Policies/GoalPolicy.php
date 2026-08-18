<?php

namespace App\Policies;

use App\Models\Goal;
use App\Models\User;

class GoalPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Goal $goal): bool
    {
        return (int) $goal->user_id === (int) $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Goal $goal): bool
    {
        return (int) $goal->user_id === (int) $user->id;
    }

    public function delete(User $user, Goal $goal): bool
    {
        return (int) $goal->user_id === (int) $user->id;
    }

    public function contribute(User $user, Goal $goal): bool
    {
        return (int) $goal->user_id === (int) $user->id && ! $goal->is_completed;
    }

    public function addMilestone(User $user, Goal $goal): bool
    {
        return (int) $goal->user_id === (int) $user->id;
    }
}
