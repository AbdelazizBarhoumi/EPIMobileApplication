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
        Schema::create('student_courses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->foreignId('program_course_id')->nullable()->constrained()->nullOnDelete();
            $table->integer('year_taken'); // Academic year when enrolled (1-5)
            $table->integer('semester_taken'); // Semester when enrolled (1 or 2)
            $table->decimal('cc_score', 5, 2)->nullable(); // Continuous Control
            $table->decimal('ds_score', 5, 2)->nullable(); // Directed Study
            $table->decimal('exam_score', 5, 2)->nullable(); // Final Exam
            $table->integer('cc_weight')->default(40); // CC weight % for this enrollment
            $table->integer('ds_weight')->default(20); // DS weight % for this enrollment
            $table->integer('exam_weight')->default(40); // Exam weight % for this enrollment
            $table->decimal('final_grade', 5, 2)->nullable(); // Calculated final grade
            $table->string('letter_grade', 2)->nullable(); // A, B, C, etc.
            $table->enum('status', ['enrolled', 'completed', 'dropped'])->default('enrolled');
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['student_id', 'course_id', 'year_taken', 'semester_taken'], 'student_course_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('student_courses');
    }
};
