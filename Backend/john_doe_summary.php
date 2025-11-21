<?php

use Illuminate\Support\Facades\DB;
use App\Models\Student;

$student = Student::find(1);

echo "\n";
echo "========================================\n";
echo "   JOHN DOE - COMPLETE DATA SUMMARY     \n";
echo "========================================\n\n";

echo "📚 STUDENT INFO:\n";
echo "  Name: {$student->name}\n";
echo "  ID: {$student->student_id}\n";
echo "  Email: {$student->email}\n";
echo "  Year: {$student->year_level} | GPA: {$student->gpa}\n";
echo "  Credits: {$student->credits_taken}/{$student->total_credits}\n";
echo "  Tuition: TND {$student->tuition_fees}\n\n";

$courses = DB::table('student_courses')->where('student_id', 1)->count();
$bills = DB::table('bills')->where('student_id', 1)->count();
$billTotal = DB::table('bills')->where('student_id', 1)->sum('amount');
$payments = DB::table('payments')->where('student_id', 1)->count();
$paymentTotal = DB::table('payments')->where('student_id', 1)->sum('amount');
$attendance = DB::table('student_attendance')->where('student_id', 1)->count();
$events = DB::table('event_registrations')->where('student_id', 1)->count();
$clubs = DB::table('club_memberships')->where('student_id', 1)->count();

echo "📊 DATA COUNTS:\n";
echo "  ✓ Courses Enrolled: {$courses}\n";
echo "  ✓ Bills: {$bills} (TND {$billTotal})\n";
echo "  ✓ Payments: {$payments} (TND {$paymentTotal})\n";
echo "  ✓ Outstanding: TND " . ($billTotal - $paymentTotal) . "\n";
echo "  ✓ Attendance Records: {$attendance}\n";
echo "  ✓ Event Registrations: {$events}\n";
echo "  ✓ Club Memberships: {$clubs}\n\n";

echo "📋 COURSE DETAILS:\n";
$courseDetails = DB::table('student_courses as sc')
    ->join('program_courses as pc', 'sc.program_course_id', '=', 'pc.id')
    ->join('courses as c', 'pc.course_id', '=', 'c.id')
    ->where('sc.student_id', 1)
    ->select('c.course_code', 'c.name', 'c.credits')
    ->get();

foreach ($courseDetails as $course) {
    echo "  • {$course->course_code}: {$course->name} ({$course->credits} cr)\n";
}

echo "\n💰 BILL DETAILS:\n";
$billDetails = DB::table('bills')->where('student_id', 1)->get();
foreach ($billDetails as $bill) {
    echo "  • {$bill->description}: TND {$bill->amount} - {$bill->status}\n";
}

echo "\n💳 PAYMENT HISTORY:\n";
$paymentDetails = DB::table('payments')->where('student_id', 1)->get();
foreach ($paymentDetails as $payment) {
    echo "  • {$payment->payment_date}: TND {$payment->amount} ({$payment->method}) - {$payment->notes}\n";
}

echo "\n🎉 EVENT REGISTRATIONS:\n";
$eventDetails = DB::table('event_registrations as er')
    ->join('events as e', 'er.event_id', '=', 'e.id')
    ->where('er.student_id', 1)
    ->select('e.title', 'e.event_date', 'er.status')
    ->get();
    
if ($eventDetails->isEmpty()) {
    echo "  No events registered\n";
} else {
    foreach ($eventDetails as $event) {
        echo "  • {$event->title} - {$event->event_date} ({$event->status})\n";
    }
}

echo "\n🏆 CLUB MEMBERSHIPS:\n";
$clubDetails = DB::table('club_memberships as cm')
    ->join('clubs as c', 'cm.club_id', '=', 'c.id')
    ->where('cm.student_id', 1)
    ->select('c.name', 'cm.role', 'cm.join_date')
    ->get();
    
if ($clubDetails->isEmpty()) {
    echo "  No clubs joined\n";
} else {
    foreach ($clubDetails as $club) {
        echo "  • {$club->name} - {$club->role} (since {$club->join_date})\n";
    }
}

echo "\n========================================\n";
echo "✅ ALL DATA SUCCESSFULLY SEEDED!\n";
echo "========================================\n\n";
