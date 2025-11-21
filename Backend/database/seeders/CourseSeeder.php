<?php

namespace Database\Seeders;

use App\Models\Course;
use Illuminate\Database\Seeder;

class CourseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $courses = [
            [
                'course_code' => 'CS101',
                'name' => 'Introduction to Programming',
                'description' => 'Fundamental concepts of programming using modern languages',
                'credits' => 3,
                'instructor' => 'Dr. Sarah Johnson',
                'schedule' => 'Mon/Wed/Fri 10:00-11:00 AM',
                'room' => 'Building A, Room 201',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'CS102',
                'name' => 'Object-Oriented Programming',
                'description' => 'Advanced programming with OOP principles',
                'credits' => 4,
                'instructor' => 'Dr. Sarah Johnson',
                'schedule' => 'Tue/Thu 10:00-12:00',
                'room' => 'Building A, Room 202',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'CS201',
                'name' => 'Data Structures',
                'description' => 'Advanced data structures and algorithms',
                'credits' => 4,
                'instructor' => 'Prof. Michael Chen',
                'schedule' => 'Tue/Thu 14:00-16:00',
                'room' => 'Building A, Room 305',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'CS202',
                'name' => 'Algorithms',
                'description' => 'Algorithm design and analysis',
                'credits' => 4,
                'instructor' => 'Prof. Michael Chen',
                'schedule' => 'Mon/Wed 14:00-16:00',
                'room' => 'Building A, Room 306',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'CS203',
                'name' => 'Computer Architecture',
                'description' => 'Hardware and system architecture',
                'credits' => 3,
                'instructor' => 'Dr. James Anderson',
                'schedule' => 'Mon/Wed/Fri 09:00-10:00 AM',
                'room' => 'Building A, Room 301',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'CS301',
                'name' => 'Database Systems',
                'description' => 'Design and implementation of database systems',
                'credits' => 3,
                'instructor' => 'Dr. Amanda Lee',
                'schedule' => 'Tue/Thu 15:00-16:30',
                'room' => 'Building A, Room 401',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'CS302',
                'name' => 'Software Engineering',
                'description' => 'Software development lifecycle and methodologies',
                'credits' => 3,
                'instructor' => 'Prof. Robert Taylor',
                'schedule' => 'Mon/Wed 13:00-14:30',
                'room' => 'Building A, Room 402',
                'academic_calendar_id' => 1,
            ],
            [
                'course_code' => 'MATH101',
                'name' => 'Calculus I',
                'description' => 'Differential calculus',
                'credits' => 4,
                'instructor' => 'Dr. Emily Rodriguez',
                'schedule' => 'Mon/Wed/Fri 09:00-10:00 AM',
                'room' => 'Building B, Room 104',
                'academic_calendar_id' => 1,
            ],
        ];

        foreach ($courses as $course) {
            Course::create($course);
        }
    }
}
