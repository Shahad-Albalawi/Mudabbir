<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('goals', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->decimal('target', 14, 2);
            $table->decimal('current_amount', 14, 2)->default(0);
            $table->string('type', 32)->default('Saving');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('image_path')->nullable();
            $table->boolean('is_completed')->default(false);
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'is_completed']);
        });

        Schema::create('goal_contributions', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->unsignedBigInteger('goal_id');
            $table->decimal('amount', 14, 2);
            $table->timestamp('contributed_at');
            $table->string('note')->nullable();
            $table->timestamps();

            $table->foreign('goal_id')->references('id')->on('goals')->cascadeOnDelete();
            $table->index('goal_id');
        });

        Schema::create('goal_milestones', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->unsignedBigInteger('goal_id');
            $table->string('title');
            $table->decimal('target_amount', 14, 2);
            $table->boolean('is_achieved')->default(false);
            $table->timestamp('achieved_at')->nullable();
            $table->timestamps();

            $table->foreign('goal_id')->references('id')->on('goals')->cascadeOnDelete();
            $table->index('goal_id');
        });

        Schema::create('budgets', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->decimal('amount', 14, 2);
            $table->date('start_date');
            $table->date('end_date');
            $table->unsignedBigInteger('account_id');
            $table->timestamps();

            $table->index(['user_id', 'start_date', 'end_date']);
        });

        Schema::create('challenges', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('creator_id')->constrained('users')->cascadeOnDelete();
            $table->string('creator_name');
            $table->string('creator_email');
            $table->string('name');
            $table->decimal('amount', 14, 2)->default(0);
            $table->date('start_date');
            $table->date('end_date');
            $table->boolean('achieved')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'creator_id']);
        });

        Schema::create('challenge_participants', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('challenge_id');
            $table->bigInteger('participant_id');
            $table->string('name');
            $table->string('email');
            $table->string('status', 16)->default('pending');
            $table->decimal('target_amount', 14, 2)->nullable();
            $table->boolean('achieved')->default(false);
            $table->decimal('current_progress', 14, 2)->default(0);
            $table->unsignedInteger('streak_days')->default(0);
            $table->unsignedInteger('longest_streak')->default(0);
            $table->date('last_check_in')->nullable();
            $table->json('badges')->nullable();
            $table->timestamps();

            $table->foreign('challenge_id')->references('id')->on('challenges')->cascadeOnDelete();
            $table->index(['challenge_id', 'participant_id']);
            $table->index(['challenge_id', 'email']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('challenge_participants');
        Schema::dropIfExists('challenges');
        Schema::dropIfExists('budgets');
        Schema::dropIfExists('goal_milestones');
        Schema::dropIfExists('goal_contributions');
        Schema::dropIfExists('goals');
    }
};
