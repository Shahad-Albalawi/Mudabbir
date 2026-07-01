<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expenses', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->decimal('amount', 14, 2);
            $table->date('date');
            $table->string('type', 16)->default('expense');
            $table->text('notes')->nullable();
            $table->unsignedBigInteger('account_id');
            $table->unsignedBigInteger('category_id');
            $table->string('account_name')->default('');
            $table->string('category_name')->default('');
            $table->boolean('is_recurring')->default(false);
            $table->string('recurrence_interval')->nullable();
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'date']);
            $table->index(['user_id', 'category_id']);
            $table->index(['user_id', 'amount']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expenses');
    }
};
