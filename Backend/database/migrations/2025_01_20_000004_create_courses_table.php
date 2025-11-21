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
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->string('course_code')->unique()->index(); // e.g., CS301
            $table->string('name'); // e.g., Data Structures & Algorithms
            $table->text('description')->nullable();
            $table->string('instructor');
            $table->integer('credits');
            $table->string('schedule'); // e.g., Mon, Wed 10:00-11:30
            $table->string('room'); // e.g., Room A-101
            $table->foreignId('academic_calendar_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
};
