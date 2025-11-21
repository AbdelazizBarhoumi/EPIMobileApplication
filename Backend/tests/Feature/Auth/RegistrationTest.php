<?php

namespace Tests\Feature\Auth;

use App\Models\Major;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_new_users_can_register(): void
    {
        $major = Major::factory()->create();
        
        $response = $this->post('/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
            'major_id' => $major->id,
            'year_level' => 1,
            'academic_year' => '2024-2025',
            'class' => 'First Year',
        ]);

        $this->assertAuthenticated();
        $response->assertStatus(200);
        
        // Verify student was created
        $this->assertDatabaseHas('students', [
            'email' => 'test@example.com',
            'major_id' => $major->id,
        ]);
    }
}
