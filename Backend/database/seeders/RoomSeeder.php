<?php

namespace Database\Seeders;

use App\Models\Room;
use Illuminate\Database\Seeder;

class RoomSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $rooms = [
            // Computer Science Classrooms
            ['room_code' => 'CS-101', 'name' => 'CS Lab 1', 'type' => 'lab', 'building' => 'Engineering Building', 'floor' => '1', 'capacity' => 30, 'facilities' => ['computers', 'projector', 'whiteboard', 'air_conditioning']],
            ['room_code' => 'CS-102', 'name' => 'CS Lab 2', 'type' => 'lab', 'building' => 'Engineering Building', 'floor' => '1', 'capacity' => 30, 'facilities' => ['computers', 'projector', 'whiteboard', 'air_conditioning']],
            ['room_code' => 'CS-201', 'name' => 'CS Classroom 1', 'type' => 'classroom', 'building' => 'Engineering Building', 'floor' => '2', 'capacity' => 40, 'facilities' => ['projector', 'whiteboard', 'air_conditioning']],
            ['room_code' => 'CS-202', 'name' => 'CS Classroom 2', 'type' => 'classroom', 'building' => 'Engineering Building', 'floor' => '2', 'capacity' => 40, 'facilities' => ['projector', 'whiteboard', 'air_conditioning']],
            ['room_code' => 'CS-301', 'name' => 'CS Advanced Lab', 'type' => 'lab', 'building' => 'Engineering Building', 'floor' => '3', 'capacity' => 25, 'facilities' => ['high_spec_computers', 'projector', 'whiteboard', 'servers']],

            // Electrical Engineering
            ['room_code' => 'EE-101', 'name' => 'EE Lab 1', 'type' => 'lab', 'building' => 'Engineering Building', 'floor' => '1', 'capacity' => 25, 'facilities' => ['oscilloscopes', 'multimeters', 'workbenches', 'projector']],
            ['room_code' => 'EE-102', 'name' => 'EE Lab 2', 'type' => 'lab', 'building' => 'Engineering Building', 'floor' => '1', 'capacity' => 25, 'facilities' => ['oscilloscopes', 'multimeters', 'workbenches', 'projector']],
            ['room_code' => 'EE-201', 'name' => 'EE Classroom', 'type' => 'classroom', 'building' => 'Engineering Building', 'floor' => '2', 'capacity' => 35, 'facilities' => ['projector', 'whiteboard']],

            // Mechanical Engineering
            ['room_code' => 'ME-101', 'name' => 'ME Workshop', 'type' => 'lab', 'building' => 'Engineering Building', 'floor' => '1', 'capacity' => 20, 'facilities' => ['machinery', 'tools', 'safety_equipment']],
            ['room_code' => 'ME-201', 'name' => 'ME Classroom', 'type' => 'classroom', 'building' => 'Engineering Building', 'floor' => '2', 'capacity' => 35, 'facilities' => ['projector', 'whiteboard', 'cad_software']],

            // Business Administration
            ['room_code' => 'BA-101', 'name' => 'BA Classroom 1', 'type' => 'classroom', 'building' => 'Business Building', 'floor' => '1', 'capacity' => 45, 'facilities' => ['projector', 'whiteboard', 'video_conferencing']],
            ['room_code' => 'BA-102', 'name' => 'BA Classroom 2', 'type' => 'classroom', 'building' => 'Business Building', 'floor' => '1', 'capacity' => 45, 'facilities' => ['projector', 'whiteboard', 'video_conferencing']],
            ['room_code' => 'BA-201', 'name' => 'BA Seminar Room', 'type' => 'seminar_room', 'building' => 'Business Building', 'floor' => '2', 'capacity' => 25, 'facilities' => ['smart_board', 'video_conferencing', 'round_tables']],

            // General Purpose
            ['room_code' => 'GEN-101', 'name' => 'General Classroom 1', 'type' => 'classroom', 'building' => 'Main Building', 'floor' => '1', 'capacity' => 50, 'facilities' => ['projector', 'whiteboard']],
            ['room_code' => 'GEN-102', 'name' => 'General Classroom 2', 'type' => 'classroom', 'building' => 'Main Building', 'floor' => '1', 'capacity' => 50, 'facilities' => ['projector', 'whiteboard']],
            ['room_code' => 'GEN-201', 'name' => 'General Classroom 3', 'type' => 'classroom', 'building' => 'Main Building', 'floor' => '2', 'capacity' => 50, 'facilities' => ['projector', 'whiteboard']],
            ['room_code' => 'GEN-202', 'name' => 'General Classroom 4', 'type' => 'classroom', 'building' => 'Main Building', 'floor' => '2', 'capacity' => 50, 'facilities' => ['projector', 'whiteboard']],
            ['room_code' => 'GEN-301', 'name' => 'General Classroom 5', 'type' => 'classroom', 'building' => 'Main Building', 'floor' => '3', 'capacity' => 50, 'facilities' => ['projector', 'whiteboard']],

            // Auditorium
            ['room_code' => 'AUD-001', 'name' => 'Main Auditorium', 'type' => 'auditorium', 'building' => 'Main Building', 'floor' => 'Ground', 'capacity' => 200, 'facilities' => ['sound_system', 'projector', 'stage', 'microphones']],
        ];

        foreach ($rooms as $room) {
            Room::create($room);
        }

        $this->command->info('Rooms seeded successfully!');
    }
}
