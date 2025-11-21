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
        Schema::create('rooms', function (Blueprint $table) {
            $table->id();
            $table->string('room_code')->unique(); // CS-101, LAB-A1, etc.
            $table->string('name');
            $table->enum('type', ['classroom', 'lab', 'auditorium', 'seminar_room']);
            $table->string('building')->nullable();
            $table->string('floor')->nullable();
            $table->integer('capacity');
            $table->json('facilities')->nullable(); // ['projector', 'computers', 'whiteboard']
            $table->boolean('is_available')->default(true);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rooms');
    }
};
