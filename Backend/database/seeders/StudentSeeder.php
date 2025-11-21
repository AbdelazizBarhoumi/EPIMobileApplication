<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Student;
use App\Models\Major;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class StudentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $csMajor = Major::where('code', 'CS')->first();
        $eeMajor = Major::where('code', 'EE')->first();

        // Create admin/test user with student profile
        $user = User::create([
            'name' => 'John Doe',
            'email' => 'john.doe@university.edu',
            'password' => Hash::make('password'),
            'email_verified_at' => now(),
        ]);

        Student::create([
            'user_id' => $user->id,
            'student_id' => '109800001',
            'major_id' => $csMajor->id,
            'name' => 'John Doe',
            'email' => 'john.doe@university.edu',
            'year_level' => 3,
            'gpa' => 3.75,
            'credits_taken' => 90,
            'total_credits' => 169,
            'tuition_fees' => 15000.000,
            'academic_year' => '2024-2025',
            'class' => 'Third Year',
        ]);

        // Create another test student
        $user2 = User::create([
            'name' => 'Jane Smith',
            'email' => 'jane.smith@university.edu',
            'password' => Hash::make('password'),
            'email_verified_at' => now(),
        ]);

        Student::create([
            'user_id' => $user2->id,
            'student_id' => '109800002',
            'major_id' => $eeMajor->id,
            'name' => 'Jane Smith',
            'email' => 'jane.smith@university.edu',
            'year_level' => 3,
            'gpa' => 3.92,
            'credits_taken' => 85,
            'total_credits' => 169,
            'tuition_fees' => 15000.000,
            'academic_year' => '2024-2025',
            'class' => 'Third Year',
        ]);

        // Create additional random students
        $majors = Major::all();
        User::factory(8)->create()->each(function ($user) use ($majors) {
            Student::create([
                'user_id' => $user->id,
                'student_id' => '1098' . str_pad(Student::count() + 1, 5, '0', STR_PAD_LEFT),
                'major_id' => $majors->random()->id,
                'name' => $user->name,
                'email' => $user->email,
                'year_level' => rand(1, 5),
                'gpa' => rand(250, 400) / 100,
                'credits_taken' => rand(30, 140),
                'total_credits' => 169,
                'tuition_fees' => 15000.000,
                'academic_year' => '2024-2025',
                'class' => ['First Year', 'Second Year', 'Third Year', 'Fourth Year', 'Fifth Year'][rand(0, 4)],
            ]);
        });
    }
}
