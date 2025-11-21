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
        Schema::create('program_courses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('major_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->integer('year_level'); // 1, 2, 3, 4, 5
            $table->integer('semester'); // 1 or 2
            $table->boolean('is_required')->default(true); // Required vs Elective
            $table->integer('cc_weight')->default(40); // Continuous Control weight %
            $table->integer('ds_weight')->default(20); // Directed Study weight %
            $table->integer('exam_weight')->default(40); // Final Exam weight %
            $table->timestamps();
            $table->softDeletes();

            // Ensure unique course per major per year per semester
            $table->unique(['major_id', 'course_id', 'year_level', 'semester'], 'program_course_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('program_courses');
    }
};
