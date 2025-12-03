<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Migration: Remove unnecessary notification tables from MySQL
 * 
 * Why: Firebase Cloud Messaging handles all notification delivery.
 * MySQL is not needed for notification storage - use Firestore instead.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('notification_deliveries');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('fcm_tokens');
    }

    public function down(): void
    {
        // Not reversible - old system was over-engineered
    }
};
