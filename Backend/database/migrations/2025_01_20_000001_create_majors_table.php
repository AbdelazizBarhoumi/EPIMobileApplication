<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('majors', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique()->index(); // e.g., CS, EE, ME
            $table->string('name'); // e.g., Computer Science, Electrical Engineering
            $table->text('description')->nullable();
            $table->string('department'); // e.g., Engineering, Business
            $table->integer('duration_years')->default(5); // Number of years to complete
            $table->integer('total_credits_required')->default(169);
            $table->string('degree_type')->default('Bachelor'); // Bachelor, Master, etc.
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('majors');
    }
};
