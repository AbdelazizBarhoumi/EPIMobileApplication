<?php

namespace Database\Seeders;

use App\Models\News;
use Illuminate\Database\Seeder;

class NewsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $news = [
            [
                'title' => 'Fall 2025 Exam Schedule Released',
                'description' => 'The final exam schedule for Fall 2025 semester has been officially released. Students are advised to check their individual schedules and note the dates, times, and locations for all exams. Make sure to arrive at least 15 minutes before the scheduled start time. Good luck with your preparations!',
                'category' => 'academic',
                'author' => 'Academic Office',
                'publish_date' => now()->subDays(2),
                'is_featured' => true,
                'is_published' => true,
            ],
            [
                'title' => 'Career Fair 2025 - December 1st',
                'description' => 'The annual Career Fair will take place on December 1st, 2025, from 10 AM to 4 PM in the Main Hall. Over 50 companies from various industries will be present. This is a great opportunity to network, explore internship opportunities, and secure job placements. Dress professionally and bring multiple copies of your resume.',
                'category' => 'events',
                'author' => 'Career Services',
                'publish_date' => now()->subDays(5),
                'is_featured' => true,
                'is_published' => true,
            ],
            [
                'title' => 'New Computer Science Lab Opens',
                'description' => 'The university has inaugurated a state-of-the-art computer science lab equipped with the latest technology. The lab features 60 high-performance workstations, virtual reality equipment, and advanced networking infrastructure. Students can book time slots through the online portal.',
                'category' => 'general',
                'author' => 'IT Department',
                'publish_date' => now()->subDays(7),
                'is_featured' => false,
                'is_published' => true,
            ],
            [
                'title' => 'Basketball Team Wins Championship',
                'description' => 'Congratulations to our university basketball team for winning the Inter-University Championship! The team showed exceptional performance throughout the tournament. The final match was held on November 15th, with our team securing victory with a score of 78-72. Special mention to team captain Alex Johnson for outstanding leadership.',
                'category' => 'sports',
                'author' => 'Sports Department',
                'publish_date' => now()->subDays(4),
                'is_featured' => true,
                'is_published' => true,
            ],
            [
                'title' => 'Spring 2026 Registration Opens December 5th',
                'description' => 'Registration for Spring 2026 semester will begin on December 5th, 2025. Students will be able to register based on their credit hours completed. Senior students can register starting December 5th, juniors on December 6th, and so on. Please consult with your academic advisor before registration.',
                'category' => 'academic',
                'author' => 'Registrar Office',
                'publish_date' => now()->subDays(1),
                'is_featured' => true,
                'is_published' => true,
            ],
            [
                'title' => 'Library Extended Hours During Finals',
                'description' => 'To support students during the final exam period, the library will extend its operating hours. From December 10th to December 22nd, the library will be open 24/7. Additional study rooms and quiet zones will be available. Please remember to bring your student ID for after-hours access.',
                'category' => 'announcement',
                'author' => 'Library Services',
                'publish_date' => now()->subDays(3),
                'is_featured' => false,
                'is_published' => true,
            ],
            [
                'title' => 'International Food Festival - November 25th',
                'description' => 'The International Students Society invites everyone to the annual International Food Festival on November 25th at the Student Center. Experience cuisine from over 20 countries, cultural performances, and music. Tickets are $10 and proceeds support international student programs.',
                'category' => 'events',
                'author' => 'International Students Society',
                'publish_date' => now()->subHours(12),
                'is_featured' => false,
                'is_published' => true,
            ],
            [
                'title' => 'Mental Health Awareness Week',
                'description' => 'November 20-24 is Mental Health Awareness Week. The Counseling Center is organizing various activities including stress management workshops, yoga sessions, and free consultations. Remember, taking care of your mental health is just as important as your physical health. All services are confidential and free for students.',
                'category' => 'general',
                'author' => 'Counseling Center',
                'publish_date' => now()->subHours(6),
                'is_featured' => true,
                'is_published' => true,
            ],
        ];

        foreach ($news as $article) {
            News::create($article);
        }
    }
}
