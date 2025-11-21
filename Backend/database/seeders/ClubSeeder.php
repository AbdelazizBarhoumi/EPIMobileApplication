<?php

namespace Database\Seeders;

use App\Models\Club;
use Illuminate\Database\Seeder;

class ClubSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $clubs = [
            [
                'name' => 'Computer Science Club',
                'description' => 'A community for students interested in programming, technology, and innovation. We organize coding competitions, tech talks, and workshops.',
                'category' => 'academic',
                'president_name' => 'Alex Johnson',
                'meeting_schedule' => 'Every Tuesday at 5:00 PM - Building A, Room 301',
                'member_count' => 45,
                'is_active' => true,
            ],
            [
                'name' => 'Basketball Team',
                'description' => 'University basketball team. Practice sessions and competitive matches.',
                'category' => 'sports',
                'president_name' => 'Mike Thompson',
                'meeting_schedule' => 'Monday/Wednesday/Friday at 4:00 PM - Sports Complex',
                'member_count' => 20,
                'is_active' => true,
            ],
            [
                'name' => 'Drama Society',
                'description' => 'Explore your passion for theater and performing arts. Annual plays and workshops.',
                'category' => 'arts',
                'president_name' => 'Emma Williams',
                'meeting_schedule' => 'Thursday at 6:00 PM - Theater Hall',
                'member_count' => 30,
                'is_active' => true,
            ],
            [
                'name' => 'Environmental Club',
                'description' => 'Dedicated to environmental conservation and sustainability initiatives on campus.',
                'category' => 'social',
                'president_name' => 'Lisa Green',
                'meeting_schedule' => 'Every other Wednesday at 3:00 PM - Building C, Room 105',
                'member_count' => 35,
                'is_active' => true,
            ],
            [
                'name' => 'Business Leaders Association',
                'description' => 'Networking and professional development for future business leaders.',
                'category' => 'academic',
                'president_name' => 'Robert Taylor',
                'meeting_schedule' => 'Tuesday at 5:30 PM - Building D, Room 201',
                'member_count' => 40,
                'is_active' => true,
            ],
            [
                'name' => 'International Students Society',
                'description' => 'Supporting international students and promoting cultural exchange.',
                'category' => 'cultural',
                'president_name' => 'Yuki Tanaka',
                'meeting_schedule' => 'Friday at 4:00 PM - Student Center',
                'member_count' => 55,
                'is_active' => true,
            ],
            [
                'name' => 'Music Ensemble',
                'description' => 'For students passionate about music. Regular performances and concerts.',
                'category' => 'arts',
                'president_name' => 'Jennifer Brown',
                'meeting_schedule' => 'Monday/Wednesday at 7:00 PM - Music Hall',
                'member_count' => 25,
                'is_active' => true,
            ],
            [
                'name' => 'Debate Club',
                'description' => 'Develop critical thinking and public speaking skills through competitive debates.',
                'category' => 'academic',
                'president_name' => 'David Chen',
                'meeting_schedule' => 'Thursday at 5:00 PM - Building C, Room 301',
                'member_count' => 28,
                'is_active' => true,
            ],
        ];

        foreach ($clubs as $club) {
            Club::create($club);
        }
    }
}
