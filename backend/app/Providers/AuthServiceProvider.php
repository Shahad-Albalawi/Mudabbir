<?php

namespace App\Providers;

// use Illuminate\Support\Facades\Gate;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        \App\Models\Expense::class => \App\Policies\ExpensePolicy::class,
        \App\Models\Goal::class => \App\Policies\GoalPolicy::class,
        \App\Models\Budget::class => \App\Policies\BudgetPolicy::class,
        \App\Models\Challenge::class => \App\Policies\ChallengePolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        //
    }
}
