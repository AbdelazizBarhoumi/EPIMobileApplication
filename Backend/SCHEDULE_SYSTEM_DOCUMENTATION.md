# Weekly Schedule System Documentation

## Overview

The system now includes a comprehensive weekly schedule management feature that supports:
- **Monday to Saturday** class schedule (6 days per week)
- **5 lecture slots per day** (08:00 - 17:30)
- **Major-specific schedules** for each year and semester
- **Automatic schedule generation** based on course credits
- **Room assignments** per major (CS-101, EE-102, etc.)
- **2 semesters per year** with independent schedules

## Database Structure

### Schedules Table
```php
schedules
├── id (primary key)
├── program_course_id (foreign key to program_courses)
├── day_of_week (enum: Monday-Saturday)
├── time_slot (integer: 1-5)
├── start_time (time: HH:MM)
├── end_time (time: HH:MM)
├── room (string: e.g., "CS-101")
├── timestamps
└── deleted_at (soft delete)

Unique constraint: [program_course_id, day_of_week, time_slot]
```

### Time Slots
```
Slot 1: 08:00 - 09:30
Slot 2: 10:00 - 11:30
Slot 3: 12:00 - 13:30
Slot 4: 14:00 - 15:30
Slot 5: 16:00 - 17:30
```

### Days of Week
- Monday
- Tuesday
- Wednesday
- Thursday
- Friday
- Saturday

## Academic Structure

### Year Organization
- Each major has **duration_years** (typically 4-5 years)
- Each year has **2 semesters**
- Each semester has its own:
  - Set of courses (defined in program_courses)
  - Weekly schedule (defined in schedules)
  - Grade components (CC, DS, Exam weights)

### Course Distribution
Courses are scheduled based on their credit hours:
- **2-credit courses**: 1 session per week
- **3-credit courses**: 2 sessions per week
- **4-credit courses**: 3 sessions per week

### Schedule Conflict Prevention
- Time slots are automatically offset based on:
  - Year level (years 1-5)
  - Semester (1 or 2)
  - Course sequence
- This prevents schedule conflicts within the same major/year/semester

## API Endpoints

### 1. Get Weekly Schedule for Major/Year/Semester
**GET** `/api/schedule/major/{major}/year/{year}/semester/{semester}`

Returns the complete weekly schedule grid for a specific major, year, and semester.

**Parameters:**
- `major` (int): Major ID
- `year` (int): Year level (1-5)
- `semester` (int): Semester number (1 or 2)

**Response:**
```json
{
  "success": true,
  "data": {
    "major": {
      "id": 1,
      "code": "CS",
      "name": "Computer Science"
    },
    "year": 1,
    "semester": 1,
    "schedule": {
      "Monday": {
        "1": {
          "time_slot": 1,
          "start_time": "08:00",
          "end_time": "09:30",
          "course": null
        },
        "2": {
          "time_slot": 2,
          "start_time": "10:00",
          "end_time": "11:30",
          "course": {
            "id": 1,
            "code": "CS101",
            "name": "Introduction to Programming",
            "instructor": "Dr. Smith",
            "room": "CS-101",
            "credits": 3,
            "is_required": true,
            "cc_weight": 40,
            "ds_weight": 20,
            "exam_weight": 40
          }
        },
        // ... slots 3-5
      },
      "Tuesday": {
        // ... slots 1-5
      },
      // ... Wednesday through Saturday
    },
    "time_slots": {
      "1": {"start": "08:00", "end": "09:30"},
      "2": {"start": "10:00", "end": "11:30"},
      "3": {"start": "12:00", "end": "13:30"},
      "4": {"start": "14:00", "end": "15:30"},
      "5": {"start": "16:00", "end": "17:30"}
    }
  }
}
```

### 2. Get Student's Personal Schedule
**GET** `/api/schedule/my-schedule`

Returns the authenticated student's current schedule based on their enrollments.

**Authentication:** Required (Bearer token)

**Response:**
```json
{
  "success": true,
  "data": {
    "student": {
      "id": 1,
      "student_id": "109800001",
      "name": "John Doe",
      "major": "Computer Science",
      "year_level": 3
    },
    "schedule": {
      "Monday": {
        "1": {
          "time_slot": 1,
          "start_time": "08:00",
          "end_time": "09:30",
          "course": {
            "id": 5,
            "code": "CS301",
            "name": "Software Engineering",
            "instructor": "Dr. Johnson",
            "room": "CS-301",
            "credits": 3,
            "cc_score": 85,
            "ds_score": 90,
            "exam_score": null,
            "final_grade": null
          }
        },
        // ... other slots
      },
      // ... other days
    },
    "time_slots": {
      // ... same as above
    }
  }
}
```

## Models

### Schedule Model
```php
// Get all schedules for a specific day
Schedule::forDay('Monday')->get();

// Get all schedules for a specific time slot
Schedule::forTimeSlot(2)->get();

// Get time range
$schedule->time_range; // "10:00 - 11:30"

// Static helpers
Schedule::getTimeSlots();    // Returns array of all time slots
Schedule::getDaysOfWeek();   // Returns array of all days
```

### ProgramCourse Model
```php
// Get schedules for a program course
$programCourse->schedules;

// Get weekly schedule organized by day
$programCourse->getWeeklySchedule();
```

### Major Model
```php
// Get curriculum with schedules
$major = Major::with(['courses.schedules'])->find(1);

// Get courses for specific year/semester with schedules
$courses = $major->courses()
    ->wherePivot('year_level', 2)
    ->wherePivot('semester', 1)
    ->with('schedules')
    ->get();
```

## Seeding

The `ScheduleSeeder` automatically generates schedules for all program courses:

1. **Credit-based scheduling:**
   - 3-credit courses: Monday & Wednesday
   - 2-credit courses: Tuesday
   - 4-credit courses: Monday, Wednesday, Thursday

2. **Automatic conflict resolution:**
   - Time slots offset by year and semester
   - Prevents overlapping schedules within same major

3. **Room assignment:**
   - Rooms assigned by major prefix (CS-, EE-, ME-, BA-)
   - Sequential numbering starting from 101

## Example Usage

### Get CS Year 1 Semester 1 Schedule
```bash
curl -X GET "http://localhost:8000/api/schedule/major/1/year/1/semester/1" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

### Get My Current Schedule
```bash
curl -X GET "http://localhost:8000/api/schedule/my-schedule" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

## Integration with Existing Systems

### Grade Tracking
- Each course in the schedule includes its grade weights (CC, DS, Exam)
- Student schedules show current grades when available
- Grades are automatically calculated using weights from program_courses

### Attendance
- Schedule data can be used for attendance tracking
- Each time slot can be linked to attendance records
- Day/time information available for attendance verification

### Course Enrollment
- Students see schedules for courses they're enrolled in
- Available courses show their scheduled times
- Helps students plan course selection to avoid conflicts

## Frontend Display Guidelines

### Weekly Grid View
```
Time    | Monday | Tuesday | Wednesday | Thursday | Friday | Saturday
--------|--------|---------|-----------|----------|--------|----------
08:00   | CS101  |         | CS101     |          |        |
10:00   |        | MATH101 |           | MATH101  |        |
12:00   | CS102  |         | CS102     |          |        |
14:00   |        |         |           |          | CS102  |
16:00   |        |         |           |          |        |
```

### Daily List View
```
Monday, November 20, 2025

08:00 - 09:30
📚 CS101 - Introduction to Programming
   Dr. Smith | CS-101 | 3 Credits

12:00 - 13:30
📚 CS102 - Data Structures
   Dr. Johnson | CS-102 | 3 Credits
```

### Course Detail View
```
CS301 - Software Engineering
Instructor: Dr. Johnson
Credits: 3 | Room: CS-301

Schedule:
  Monday    10:00 - 11:30
  Wednesday 10:00 - 11:30

Grades:
  CC:   85/100 (40%)
  DS:   90/100 (20%)
  Exam: --/100 (40%)
  Final: --
```

## Testing

Sample test data after seeding:
- **Total schedules:** 20 (across all majors/years/semesters)
- **CS Year 1 Semester 1:** Introduction to Programming
  - Monday Slot 2 (10:00-11:30) in CS-101
  - Wednesday Slot 3 (12:00-13:30) in CS-101

### Verify Schedule Data
```php
php artisan tinker

// Get total schedules
App\Models\Schedule::count();

// Get specific program course schedules
$pc = App\Models\ProgramCourse::with(['course', 'schedules'])->first();
$pc->schedules;

// Get student schedule
$student = App\Models\Student::with(['studentCourses.programCourse.schedules'])->first();
```

## Summary

✅ **Complete Schedule System Implemented:**
- Monday-Saturday class schedule (6 days)
- 5 time slots per day (08:00-17:30)
- Major/year/semester-specific schedules
- 2 semesters per year with independent schedules
- Automatic conflict prevention
- Room assignments per major
- Integration with grade tracking (CC, DS, Exam weights)
- Student personal schedule API
- Full curriculum schedule API
- All 46 tests passing

**Database:** 19 migrations, 9 seeders
**Models:** Schedule, ProgramCourse enhanced, Course enhanced
**Controllers:** ScheduleController (2 endpoints)
**API Routes:** 2 new schedule endpoints
