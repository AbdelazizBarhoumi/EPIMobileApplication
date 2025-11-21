<?php

namespace Database\Seeders;

use App\Models\Teacher;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TeacherSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $teachers = [
            [
                'name' => 'Dr. Sarah Johnson',
                'email' => 'sarah.johnson@university.edu',
                'department' => 'Computer Science',
                'title' => 'Professor',
                'specialization' => 'Software Engineering, Algorithms',
                'phone' => '+1-555-0101',
                'office_location' => 'CS Building, Room 301',
                'office_hours' => [
                    ['day' => 'Monday', 'start' => '14:00', 'end' => '16:00'],
                    ['day' => 'Wednesday', 'start' => '14:00', 'end' => '16:00'],
                ],
                'bio' => 'Professor with 15 years of experience in software engineering and algorithm design.',
            ],
            [
                'name' => 'Dr. Emily Rodriguez',
                'email' => 'emily.rodriguez@university.edu',
                'department' => 'Mathematics',
                'title' => 'Associate Professor',
                'specialization' => 'Calculus, Linear Algebra',
                'phone' => '+1-555-0102',
                'office_location' => 'Math Building, Room 205',
                'office_hours' => [
                    ['day' => 'Tuesday', 'start' => '10:00', 'end' => '12:00'],
                    ['day' => 'Thursday', 'start' => '10:00', 'end' => '12:00'],
                ],
                'bio' => 'Specializes in applied mathematics and calculus education.',
            ],
            [
                'name' => 'Dr. Michael Chen',
                'email' => 'michael.chen@university.edu',
                'department' => 'Computer Science',
                'title' => 'Assistant Professor',
                'specialization' => 'Data Structures, Programming',
                'phone' => '+1-555-0103',
                'office_location' => 'CS Building, Room 205',
                'office_hours' => [
                    ['day' => 'Monday', 'start' => '13:00', 'end' => '15:00'],
                    ['day' => 'Friday', 'start' => '13:00', 'end' => '15:00'],
                ],
                'bio' => 'Expert in data structures and object-oriented programming.',
            ],
            [
                'name' => 'Prof. David Williams',
                'email' => 'david.williams@university.edu',
                'department' => 'Computer Science',
                'title' => 'Professor',
                'specialization' => 'Computer Networks, Security',
                'phone' => '+1-555-0104',
                'office_location' => 'CS Building, Room 310',
                'office_hours' => [
                    ['day' => 'Tuesday', 'start' => '15:00', 'end' => '17:00'],
                    ['day' => 'Thursday', 'start' => '15:00', 'end' => '17:00'],
                ],
                'bio' => 'Renowned expert in network security and distributed systems.',
            ],
            [
                'name' => 'Dr. Jennifer Lee',
                'email' => 'jennifer.lee@university.edu',
                'department' => 'Computer Science',
                'title' => 'Associate Professor',
                'specialization' => 'Database Systems, Big Data',
                'phone' => '+1-555-0105',
                'office_location' => 'CS Building, Room 208',
                'office_hours' => [
                    ['day' => 'Wednesday', 'start' => '10:00', 'end' => '12:00'],
                    ['day' => 'Friday', 'start' => '10:00', 'end' => '12:00'],
                ],
                'bio' => 'Specializes in database management and big data analytics.',
            ],
            [
                'name' => 'Dr. Robert Martinez',
                'email' => 'robert.martinez@university.edu',
                'department' => 'Electrical Engineering',
                'title' => 'Professor',
                'specialization' => 'Circuit Design, Electronics',
                'phone' => '+1-555-0106',
                'office_location' => 'EE Building, Room 301',
                'office_hours' => [
                    ['day' => 'Monday', 'start' => '11:00', 'end' => '13:00'],
                ],
                'bio' => 'Expert in analog and digital circuit design.',
            ],
        ];

        foreach ($teachers as $index => $teacherData) {
            // Create user account
            $user = User::create([
                'name' => $teacherData['name'],
                'email' => $teacherData['email'],
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]);

            // Create teacher profile
            Teacher::create([
                'user_id' => $user->id,
                'teacher_id' => 'T' . str_pad($index + 1, 5, '0', STR_PAD_LEFT),
                'name' => $teacherData['name'],
                'email' => $teacherData['email'],
                'phone' => $teacherData['phone'],
                'department' => $teacherData['department'],
                'title' => $teacherData['title'],
                'specialization' => $teacherData['specialization'],
                'bio' => $teacherData['bio'],
                'office_location' => $teacherData['office_location'],
                'office_hours' => $teacherData['office_hours'],
                'is_active' => true,
            ]);
        }

        $this->command->info('Teachers seeded successfully!');
    }
}
