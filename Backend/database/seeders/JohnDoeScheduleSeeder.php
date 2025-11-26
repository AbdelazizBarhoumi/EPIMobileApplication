<?php

namespace Database\Seeders;

use App\Models\Schedule;
use App\Models\StudentCourse;
use Illuminate\Database\Seeder;

class JohnDoeScheduleSeeder extends Seeder
{
    /**
     * Add extra schedule sessions for John Doe to ensure he has classes every day till 9 PM
     */
    public function run(): void
    {
        $studentId = 1;
        $timeSlots = Schedule::getTimeSlots();
        $daysOfWeek = Schedule::getDaysOfWeek();

        // Get John Doe's enrolled courses
        $studentCourses = StudentCourse::where('student_id', $studentId)->with('programCourse.course')->get();

        if ($studentCourses->isEmpty()) {
            $this->command->warn('John Doe has no enrolled courses');
            return;
        }

        $this->command->info("Adding extra schedule sessions for John Doe...");

        foreach ($studentCourses as $studentCourse) {
            $programCourse = $studentCourse->programCourse;

            // Add sessions for slots 6 and 7 (evening) on all days
            foreach ($daysOfWeek as $day) {
                foreach ([6, 7] as $slot) {
                    // Check if schedule already exists
                    $existing = Schedule::where('program_course_id', $programCourse->id)
                        ->where('day_of_week', $day)
                        ->where('time_slot', $slot)
                        ->first();

                    if (!$existing) {
                        // Find an available room (simple approach - use room 1)
                        $roomId = 1; // Assuming room 1 exists

                        $times = $timeSlots[$slot];

                        Schedule::create([
                            'program_course_id' => $programCourse->id,
                            'day_of_week' => $day,
                            'time_slot' => $slot,
                            'start_time' => $times['start'],
                            'end_time' => $times['end'],
                            'room_id' => $roomId,
                        ]);

                        $this->command->info("Added {$day} slot {$slot} for course {$programCourse->course->course_code}");
                    }
                }
            }
        }

        $this->command->info('John Doe schedule enhancement completed!');
    }
}