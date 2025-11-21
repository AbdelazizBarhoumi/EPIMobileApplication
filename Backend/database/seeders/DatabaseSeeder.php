<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            AcademicCalendarSeeder::class,
            MajorSeeder::class,
            CourseSeeder::class,
            TeacherSeeder::class,
            RoomSeeder::class,
            ProgramCourseSeeder::class,
            ScheduleSeeder::class,
            StudentSeeder::class,
            StudentGradeSeeder::class,
            ClubSeeder::class,
            NewsSeeder::class,
        ]);

        $this->command->info('Database seeded successfully!');
    }
}
