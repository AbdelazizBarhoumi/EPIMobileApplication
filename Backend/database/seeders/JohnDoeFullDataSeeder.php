<?php

namespace Database\Seeders;

use App\Models\Bill;
use App\Models\Club;
use App\Models\ClubMembership;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\Payment;
use App\Models\Student;
use App\Models\StudentAttendance;
use App\Models\StudentCourse;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class JohnDoeFullDataSeeder extends Seeder
{
    /**
     * Seed comprehensive data for John Doe (student_id = 1)
     * This includes bills, payments, attendance records, event registrations, and club memberships
     */
    public function run(): void
    {
        $studentId = 1;
        $student = Student::find($studentId);

        if (!$student) {
            $this->command->error('Student with ID 1 (John Doe) not found!');
            return;
        }

        $this->command->info("🌱 Seeding comprehensive data for {$student->name}...");

        // 1. BILLS - Create tuition and other bills
        $this->seedBills($studentId);

        // 2. PAYMENTS - Create payment records
        $this->seedPayments($studentId);

        // 3. ATTENDANCE - Create attendance records for enrolled courses
        $this->seedAttendance($studentId);

        // 4. EVENT REGISTRATIONS - Register for some events
        $this->seedEventRegistrations($studentId);

        // 5. CLUB MEMBERSHIPS - Join some clubs
        $this->seedClubMemberships($studentId);

        $this->command->info('✅ John Doe full data seeding completed!');
        $this->printSummary($studentId);
    }

    private function seedBills(int $studentId): void
    {
        $this->command->info('💰 Creating bills...');

        $bills = [
            [
                'student_id' => $studentId,
                'bill_type' => 'tuition',
                'description' => 'Tuition Fee - Fall 2024',
                'amount' => 7500.00,
                'due_date' => Carbon::now()->addDays(30),
                'status' => 'pending',
            ],
            [
                'student_id' => $studentId,
                'bill_type' => 'tuition',
                'description' => 'Tuition Fee - Spring 2025',
                'amount' => 7500.00,
                'due_date' => Carbon::now()->addMonths(6),
                'status' => 'pending',
            ],
            [
                'student_id' => $studentId,
                'bill_type' => 'library',
                'description' => 'Library Late Fee',
                'amount' => 25.00,
                'due_date' => Carbon::now()->addDays(15),
                'status' => 'pending',
            ],
            [
                'student_id' => $studentId,
                'bill_type' => 'lab',
                'description' => 'Computer Lab Fee',
                'amount' => 150.00,
                'due_date' => Carbon::now()->addDays(20),
                'status' => 'pending',
            ],
            [
                'student_id' => $studentId,
                'bill_type' => 'accommodation',
                'description' => 'Dormitory Fee - Fall 2024',
                'amount' => 2000.00,
                'due_date' => Carbon::now()->subDays(10), // Overdue
                'status' => 'overdue',
            ],
        ];

        foreach ($bills as $billData) {
            Bill::create($billData);
        }

        $this->command->info('   ✓ Created ' . count($bills) . ' bills');
    }

    private function seedPayments(int $studentId): void
    {
        $this->command->info('💳 Creating payment records...');

        $payments = [
            [
                'student_id' => $studentId,
                'bill_id' => null,
                'amount' => 5000.00,
                'payment_date' => Carbon::now()->subMonths(2),
                'method' => 'transfer',
                'transaction_reference' => 'PAY-2024-001-' . $studentId,
                'notes' => 'Partial Tuition Payment - Fall 2024',
            ],
            [
                'student_id' => $studentId,
                'bill_id' => null,
                'amount' => 2000.00,
                'payment_date' => Carbon::now()->subMonth(),
                'method' => 'card',
                'transaction_reference' => 'PAY-2024-002-' . $studentId,
                'notes' => 'Dormitory Payment',
            ],
            [
                'student_id' => $studentId,
                'bill_id' => null,
                'amount' => 1500.00,
                'payment_date' => Carbon::now()->subWeeks(2),
                'method' => 'cash',
                'transaction_reference' => 'PAY-2024-003-' . $studentId,
                'notes' => 'Lab Fee and Library Fee',
            ],
        ];

        foreach ($payments as $paymentData) {
            Payment::create($paymentData);
        }

        $this->command->info("   ✓ Created " . count($payments) . " payment records");
    }

    private function seedAttendance(int $studentId): void
    {
        $this->command->info('📅 Creating attendance records...');

        // Get John Doe's enrolled courses with their schedules
        $enrolledCourses = StudentCourse::where('student_id', $studentId)
            ->with(['programCourse'])
            ->get();

        if ($enrolledCourses->isEmpty()) {
            $this->command->warn('   ⚠ No enrolled courses found, skipping attendance');
            return;
        }

        $attendanceCount = 0;

        // Create attendance for the last 30 days
        foreach ($enrolledCourses as $enrollment) {
            if (!$enrollment->programCourse) {
                continue;
            }

            // Get schedules for this program course
            $schedules = \App\Models\Schedule::where('program_course_id', $enrollment->program_course_id)
                ->pluck('id')
                ->toArray();

            if (empty($schedules)) {
                $this->command->warn("   ⚠ No schedules found for program_course_id: {$enrollment->program_course_id}");
                continue;
            }

            // Generate realistic attendance records per schedule
            foreach ($schedules as $scheduleId) {
                $sessions = rand(10, 15); // More sessions per schedule

                for ($i = 0; $i < $sessions; $i++) {
                    $date = Carbon::now()->subDays(rand(1, 60));

                    // 92% attendance rate with some variety
                    $random = rand(1, 100);
                    if ($random <= 85) {
                        $status = 'present';
                    } elseif ($random <= 92) {
                        $status = 'late';
                    } else {
                        $status = 'absent';
                    }

                    try {
                        DB::table('student_attendance')->insert([
                            'student_id' => $studentId,
                            'schedule_id' => $scheduleId,
                            'date' => $date->format('Y-m-d'),
                            'status' => $status,
                            'notes' => $status === 'absent' ? 'Absent without notice' : ($status === 'late' ? 'Arrived 15 minutes late' : null),
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                        $attendanceCount++;
                    } catch (\Exception $e) {
                        // Skip duplicates
                        continue;
                    }
                }
            }
        }

        $this->command->info("   ✓ Created {$attendanceCount} attendance records across {$enrolledCourses->count()} courses");
    }

    private function seedEventRegistrations(int $studentId): void
    {
        $this->command->info('🎉 Creating event registrations...');

        // Get available events
        $events = Event::where('is_active', true)
            ->where('event_date', '>', now())
            ->limit(4)
            ->get();

        if ($events->isEmpty()) {
            $this->command->warn('   ⚠ No upcoming events found, skipping registrations');
            return;
        }

        $registrationCount = 0;

        foreach ($events as $event) {
            try {
                EventRegistration::create([
                    'event_id' => $event->id,
                    'student_id' => $studentId,
                    'registered_at' => now(),
                    'status' => 'registered',
                ]);
                $registrationCount++;
            } catch (\Exception $e) {
                // Skip if already registered
                continue;
            }
        }

        $this->command->info("   ✓ Registered for {$registrationCount} events");
    }

    private function seedClubMemberships(int $studentId): void
    {
        $this->command->info('🏆 Creating club memberships...');

        // Get or create clubs
        $clubs = $this->ensureClubsExist();

        $membershipCount = 0;

        // Join 2-3 random clubs
        $clubsToJoin = $clubs->random(min(3, $clubs->count()));

        foreach ($clubsToJoin as $club) {
            try {
                DB::table('club_memberships')->insert([
                    'club_id' => $club->id,
                    'student_id' => $studentId,
                    'role' => 'member',
                    'join_date' => Carbon::now()->subMonths(rand(1, 12))->format('Y-m-d'),
                    'status' => 'active',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                $membershipCount++;
            } catch (\Exception $e) {
                // Skip if already member
                continue;
            }
        }

        $this->command->info("   ✓ Joined {$membershipCount} clubs");
    }

    private function ensureClubsExist()
    {
        if (Club::count() > 0) {
            return Club::all();
        }

        $this->command->info('   Creating sample clubs...');

        $clubsData = [
            [
                'name' => 'Computer Science Club',
                'description' => 'A club for CS students to collaborate on projects and learn together',
                'category' => 'academic',
                'advisor' => 'Dr. Sarah Johnson',
                'meeting_schedule' => 'Every Thursday at 4 PM',
                'member_count' => 45,
                'is_active' => true,
            ],
            [
                'name' => 'Robotics Club',
                'description' => 'Build and compete with robots',
                'category' => 'technical',
                'advisor' => 'Prof. Michael Chen',
                'meeting_schedule' => 'Tuesdays and Fridays at 3 PM',
                'member_count' => 32,
                'is_active' => true,
            ],
            [
                'name' => 'Debate Society',
                'description' => 'Improve public speaking and critical thinking skills',
                'category' => 'social',
                'advisor' => 'Dr. Emily Brown',
                'meeting_schedule' => 'Wednesdays at 5 PM',
                'member_count' => 28,
                'is_active' => true,
            ],
            [
                'name' => 'Photography Club',
                'description' => 'Explore the art of photography',
                'category' => 'arts',
                'advisor' => 'Ms. Lisa Anderson',
                'meeting_schedule' => 'Weekends',
                'member_count' => 20,
                'is_active' => true,
            ],
        ];

        foreach ($clubsData as $clubData) {
            Club::create($clubData);
        }

        return Club::all();
    }

    private function printSummary(int $studentId): void
    {
        $this->command->info("\n📊 ===== DATA SUMMARY FOR JOHN DOE =====");

        $bills = Bill::where('student_id', $studentId)->count();
        $payments = Payment::where('student_id', $studentId)->count();
        $attendance = DB::table('student_attendance')->where('student_id', $studentId)->count();
        $events = EventRegistration::where('student_id', $studentId)->count();
        $clubs = ClubMembership::where('student_id', $studentId)->count();
        $courses = StudentCourse::where('student_id', $studentId)->count();

        $this->command->table(
            ['Category', 'Count'],
            [
                ['Enrolled Courses', $courses],
                ['Bills', $bills],
                ['Payments', $payments],
                ['Attendance Records', $attendance],
                ['Event Registrations', $events],
                ['Club Memberships', $clubs],
            ]
        );

        // Financial Summary
        $totalBills = Bill::where('student_id', $studentId)->sum('amount');
        $totalPaid = Payment::where('student_id', $studentId)->sum('amount');
        $outstanding = $totalBills - $totalPaid;

        $this->command->info("\n💰 FINANCIAL SUMMARY:");
        $this->command->info("   Total Bills: TND " . number_format($totalBills, 2));
        $this->command->info("   Total Paid: TND " . number_format($totalPaid, 2));
        $this->command->info("   Outstanding: TND " . number_format($outstanding, 2));
    }
}
