<?php

namespace Database\Seeders;

use App\Models\Major;
use Illuminate\Database\Seeder;

class MajorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $majors = [
            [
                'code' => 'CS',
                'name' => 'Computer Science',
                'description' => 'Study of computation, information processing, and the design of computer systems',
                'department' => 'Engineering',
                'duration_years' => 5,
                'total_credits_required' => 169,
                'degree_type' => 'Bachelor of Science',
                'is_active' => true,
            ],
            [
                'code' => 'EE',
                'name' => 'Electrical Engineering',
                'description' => 'Study of electrical systems, electronics, and electromagnetism',
                'department' => 'Engineering',
                'duration_years' => 5,
                'total_credits_required' => 169,
                'degree_type' => 'Bachelor of Science',
                'is_active' => true,
            ],
            [
                'code' => 'ME',
                'name' => 'Mechanical Engineering',
                'description' => 'Study of mechanical systems, thermodynamics, and materials science',
                'department' => 'Engineering',
                'duration_years' => 5,
                'total_credits_required' => 169,
                'degree_type' => 'Bachelor of Science',
                'is_active' => true,
            ],
            [
                'code' => 'BA',
                'name' => 'Business Administration',
                'description' => 'Study of business management, finance, and organizational behavior',
                'department' => 'Business',
                'duration_years' => 4,
                'total_credits_required' => 132,
                'degree_type' => 'Bachelor of Business Administration',
                'is_active' => true,
            ],
        ];

        foreach ($majors as $major) {
            Major::create($major);
        }
    }
}
