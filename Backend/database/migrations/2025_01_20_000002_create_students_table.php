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
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->string('student_id')->unique()->index(); // e.g., 109800200
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('major_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('avatar_url')->nullable();
            $table->integer('year_level')->default(1); // Current year: 1, 2, 3, 4, 5
            $table->decimal('gpa', 3, 2)->default(0.00);
            $table->integer('credits_taken')->default(0);
            $table->integer('total_credits')->default(169);
            $table->decimal('tuition_fees', 10, 3)->default(0.000);
            $table->string('academic_year'); // e.g., 2024-2025
            $table->string('class'); // e.g., Third Year
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
