<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Add Firebase UID to users table for notification system integration.
 * 
 * Firebase UID is needed to:
 * 1. Send push notifications via OneSignal (uses external_user_id = Firebase UID)
 * 2. Store notifications in Firestore (path: notifications/{firebase_uid}/items)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('firebase_uid')->nullable()->unique()->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('firebase_uid');
        });
    }
};
