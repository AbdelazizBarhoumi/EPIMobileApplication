<?php

namespace Database\Seeders;

use App\Models\ProgramCourse;
use App\Models\Room;
use App\Models\Schedule;
use Illuminate\Database\Seeder;

class ScheduleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $timeSlots = Schedule::getTimeSlots();
        $daysOfWeek = Schedule::getDaysOfWeek();
        
        // Get all program courses
        $programCourses = ProgramCourse::with(['major', 'course'])->get();
        
        // Get available rooms
        $rooms = Room::where('is_available', true)->get();
        
        // Track room availability: [day][time_slot] = [room_ids]
        $roomAvailability = [];
        foreach ($daysOfWeek as $day) {
            $roomAvailability[$day] = [];
            foreach (array_keys($timeSlots) as $slot) {
                $roomAvailability[$day][$slot] = $rooms->pluck('id')->toArray();
            }
        }
        
        // Define schedule patterns for each semester
        // Pattern: [day_index, time_slot]
        $schedulePatterns = [
            // For 3-credit courses: 2 sessions per week
            3 => [
                ['Monday', 1],
                ['Wednesday', 1],
            ],
            // For 2-credit courses: 1 session per week  
            2 => [
                ['Tuesday', 2],
            ],
            // For 4-credit courses: 3 sessions per week
            4 => [
                ['Monday', 3],
                ['Wednesday', 3],
                ['Thursday', 3],
            ],
        ];
        
        // Room type preferences by major
        $roomTypePreferences = [
            'CS' => ['lab', 'classroom'],
            'EE' => ['lab', 'classroom'],
            'ME' => ['lab', 'classroom'],
            'BA' => ['classroom', 'seminar_room'],
        ];
        
        foreach ($programCourses as $programCourse) {
            $majorCode = $programCourse->major->code;
            $credits = $programCourse->course->credits;
            
            // Get schedule pattern based on credits
            $pattern = $schedulePatterns[$credits] ?? $schedulePatterns[3];
            
            // Offset time slots based on year and semester to avoid conflicts
            $yearOffset = ($programCourse->year_level - 1) * 2;
            $semesterOffset = ($programCourse->semester - 1);
            $totalOffset = $yearOffset + $semesterOffset;
            
            // Get preferred room types
            $preferredTypes = $roomTypePreferences[$majorCode] ?? ['classroom'];
            
            foreach ($pattern as $index => $slot) {
                [$day, $timeSlot] = $slot;
                
                // Adjust time slot with offset (cycle through 1-5)
                $adjustedTimeSlot = (($timeSlot + $totalOffset + $index) % 5) + 1;
                
                // Get time slot details
                $times = $timeSlots[$adjustedTimeSlot];
                
                // Find available room for this day/time
                $availableRoomIds = $roomAvailability[$day][$adjustedTimeSlot] ?? [];
                
                if (empty($availableRoomIds)) {
                    $this->command->warn("No available rooms for {$day} slot {$adjustedTimeSlot}");
                    continue;
                }
                
                // Try to find a room of preferred type
                $selectedRoomId = null;
                foreach ($preferredTypes as $type) {
                    $preferredRooms = $rooms->whereIn('id', $availableRoomIds)
                        ->where('type', $type)
                        ->pluck('id')
                        ->toArray();
                    
                    if (!empty($preferredRooms)) {
                        $selectedRoomId = $preferredRooms[0];
                        break;
                    }
                }
                
                // If no preferred room, use any available room
                if (!$selectedRoomId && !empty($availableRoomIds)) {
                    $selectedRoomId = $availableRoomIds[0];
                }
                
                if (!$selectedRoomId) {
                    $this->command->warn("Could not assign room for course {$programCourse->course->course_code}");
                    continue;
                }
                
                // Create schedule
                Schedule::create([
                    'program_course_id' => $programCourse->id,
                    'day_of_week' => $day,
                    'time_slot' => $adjustedTimeSlot,
                    'start_time' => $times['start'],
                    'end_time' => $times['end'],
                    'room_id' => $selectedRoomId,
                ]);
                
                // Mark room as unavailable for this day/time
                $roomAvailability[$day][$adjustedTimeSlot] = array_diff(
                    $roomAvailability[$day][$adjustedTimeSlot],
                    [$selectedRoomId]
                );
            }
        }
        
        $this->command->info('Schedules seeded successfully!');
    }
}
