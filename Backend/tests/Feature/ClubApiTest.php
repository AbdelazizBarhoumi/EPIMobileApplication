<?php

namespace Tests\Feature;

use App\Models\Club;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ClubApiTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected Student $student;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');

        $this->user = User::factory()->create();
        $this->student = Student::factory()->create(['user_id' => $this->user->id]);
    }

    public function test_can_list_clubs(): void
    {
        Sanctum::actingAs($this->user);

        Club::factory()->count(3)->create();

        $response = $this->getJson('/api/clubs');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'data' => [
                        '*' => [
                            'id',
                            'name',
                            'description',
                            'category',
                            'member_count',
                        ],
                    ],
                ],
            ]);
    }

    public function test_can_join_club(): void
    {
        Sanctum::actingAs($this->user);

        $club = Club::factory()->create([
            'member_count' => 10,
        ]);

        $response = $this->postJson("/api/clubs/{$club->id}/join");

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Successfully joined club',
            ]);

        $this->assertDatabaseHas('club_memberships', [
            'student_id' => $this->student->id,
            'club_id' => $club->id,
            'status' => 'active',
        ]);
    }

    public function test_cannot_join_club_twice(): void
    {
        Sanctum::actingAs($this->user);

        $club = Club::factory()->create();

        $this->student->clubs()->attach($club->id, [
            'join_date' => now(),
            'role' => 'member',
            'status' => 'active',
        ]);

        $response = $this->postJson("/api/clubs/{$club->id}/join");

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'Already a member of this club',
            ]);
    }

    public function test_can_leave_club(): void
    {
        Sanctum::actingAs($this->user);

        $club = Club::factory()->create();

        $this->student->clubs()->attach($club->id, [
            'join_date' => now(),
            'role' => 'member',
            'status' => 'active',
        ]);

        $response = $this->deleteJson("/api/clubs/{$club->id}/leave");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Successfully left club',
            ]);
    }

    public function test_can_get_my_clubs(): void
    {
        Sanctum::actingAs($this->user);

        $club1 = Club::factory()->create();
        $club2 = Club::factory()->create();

        $this->student->clubs()->attach($club1->id, [
            'join_date' => now(),
            'role' => 'member',
            'status' => 'active',
        ]);

        $this->student->clubs()->attach($club2->id, [
            'join_date' => now(),
            'role' => 'member',
            'status' => 'active',
        ]);

        $response = $this->getJson('/api/clubs/my-clubs');

        $response->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertCount(2, $response->json('data'));
    }
}
