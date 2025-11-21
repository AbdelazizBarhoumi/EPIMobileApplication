<?php

namespace Database\Seeders;

use App\Models\AcademicCalendar;
use Illuminate\Database\Seeder;

class AcademicCalendarSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $calendars = [
            [
                'name' => 'Fall 2025',
                'start_date' => '2025-09-01',
                'end_date' => '2025-12-20',
                'status' => 'active',
                'planned_credits' => 15,
                'important_dates' => [
                    'classes_begin' => '2025-09-01',
                    'add_drop_deadline' => '2025-09-15',
                    'midterms' => '2025-10-20',
                    'thanksgiving_break' => '2025-11-23',
                    'finals_begin' => '2025-12-10',
                    'finals_end' => '2025-12-20',
                ],
            ],
            [
                'name' => 'Spring 2026',
                'start_date' => '2026-01-15',
                'end_date' => '2026-05-15',
                'status' => 'upcoming',
                'planned_credits' => 15,
                'important_dates' => [
                    'classes_begin' => '2026-01-15',
                    'add_drop_deadline' => '2026-01-29',
                    'spring_break' => '2026-03-15',
                    'midterms' => '2026-03-01',
                    'finals_begin' => '2026-05-05',
                    'finals_end' => '2026-05-15',
                ],
            ],
            [
                'name' => 'Summer 2026',
                'start_date' => '2026-06-01',
                'end_date' => '2026-08-15',
                'status' => 'upcoming',
                'planned_credits' => 6,
                'important_dates' => [
                    'classes_begin' => '2026-06-01',
                    'add_drop_deadline' => '2026-06-08',
                    'independence_day' => '2026-07-04',
                    'finals_week' => '2026-08-08',
                ],
            ],
        ];

        foreach ($calendars as $calendar) {
            AcademicCalendar::create($calendar);
        }
    }
}
