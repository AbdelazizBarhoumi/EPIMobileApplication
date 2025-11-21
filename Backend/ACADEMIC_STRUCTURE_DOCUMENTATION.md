# Academic Structure & Grade Management System

## Overview
This document describes the enhanced academic structure that properly handles majors, years, courses, and comprehensive grade tracking across a student's entire academic program.

## Database Structure

### Core Tables

#### 1. **majors** (Academic Programs)
Defines degree programs with their requirements:
- `code`: Unique identifier (CS, EE, ME, BA)
- `name`: Full program name (Computer Science, Electrical Engineering)
- `department`: Department name
- `duration_years`: Program length (typically 4-5 years)
- `total_credits_required`: Credits needed to graduate (169 for engineering)
- `degree_type`: Bachelor of Science, etc.

#### 2. **students**
Enhanced with major relationship and year tracking:
- `major_id`: Foreign key to majors table
- `year_level`: Current year (1-5)
- `gpa`: Calculated overall GPA
- `credits_taken`: Completed credits
- `total_credits`: Total required (inherited from major)

#### 3. **courses**
Course definitions (removed grade_components - now in program_courses):
- `course_code`: Unique identifier (CS101, CS202)
- `name`: Course name
- `description`: Course description
- `credits`: Credit hours
- `instructor`: Faculty name
- `schedule`: Class times
- `room`: Location
- `academic_calendar_id`: Semester offered

#### 4. **program_courses** (Curriculum Definition)
Defines which courses belong to which major in which year:
- `major_id`: The program
- `course_id`: The course
- `year_level`: Which year (1-5)
- `semester`: Which semester (1 or 2)
- `is_required`: Required vs elective
- `cc_weight`: Continuous Control weight % (default 40)
- `ds_weight`: Directed Study weight % (default 20)
- `exam_weight`: Final Exam weight % (default 40)

**Key Feature**: Grade component weights (CC, DS, Exam) are defined here, allowing different weights for the same course in different programs.

#### 5. **student_courses** (Enrollments & Grades)
Tracks individual student enrollments and grades:
- `student_id`: The student
- `course_id`: The course
- `program_course_id`: Link to curriculum definition (optional)
- `year_taken`: Academic year when enrolled (1-5)
- `semester_taken`: Semester when enrolled (1 or 2)
- `cc_score`: Continuous Control score (0-100)
- `ds_score`: Directed Study score (0-100)
- `exam_score`: Final Exam score (0-100)
- `cc_weight`, `ds_weight`, `exam_weight`: Weights for this enrollment
- `final_grade`: Calculated weighted average (auto-computed)
- `letter_grade`: A, B, C, D, F (auto-computed)
- `status`: enrolled, completed, dropped

**Auto-Calculation**: When scores are updated, `final_grade` and `letter_grade` are automatically calculated using the weights.

## Key Relationships

### Major → Courses (Many-to-Many via program_courses)
```php
$major = Major::find(1);
$year2Courses = $major->getCoursesByYear(2);
$year2Semester1 = $major->getCoursesByYearAndSemester(2, 1);
$curriculum = $major->getCurriculum(); // All years structured
```

### Student → Major (Belongs To)
```php
$student = Student::find(1);
$major = $student->major; // Student's program
$availableCourses = $student->getAvailableCourses(); // For current year
```

### Student → Grades (Full Transcript)
```php
$student = Student::find(1);

// Full transcript across all years
$transcript = $student->getFullTranscript();

// Specific year
$year2Transcript = $student->getTranscriptByYear(2);

// Specific semester
$semester = $student->getTranscriptByYearAndSemester(2, 1);

// GPA calculations
$overallGPA = $student->calculateOverallGPA();
$year2GPA = $student->calculateYearGPA(2);
```

## API Endpoints

### Major/Program Endpoints

```http
GET /api/majors
# List all majors with student counts

GET /api/majors/{id}
# Get specific major details

GET /api/majors/{id}/curriculum
# Get complete curriculum organized by year and semester

GET /api/majors/{id}/year/{year}
# Get all courses for a specific year

GET /api/majors/{id}/year/{year}/semester/{semester}
# Get courses for specific year and semester
```

### Grade/Transcript Endpoints

```http
GET /api/grades/student/{id}/transcript
# Full academic transcript across all years
# Returns:
# - Organized by year → semester
# - All course grades with components (CC, DS, Exam)
# - Year-by-year GPA
# - Overall GPA
# - Credits taken/remaining

GET /api/grades/student/{id}/transcript/year/{year}
# Transcript for specific year

GET /api/grades/student/{id}/current-semester
# Current semester grades only

PUT /api/grades/student/{id}/course/{courseId}
# Update grades for a specific enrollment
# Body: { cc_score, ds_score, exam_score, status }

GET /api/grades/student/{id}/gpa
# GPA statistics:
# - Overall GPA
# - GPA by year
# - Credits progress
```

## Example API Response: Full Transcript

```json
{
  "success": true,
  "data": {
    "student": {
      "id": 1,
      "student_id": "109800001",
      "name": "John Doe",
      "major": "Computer Science",
      "current_year": 3
    },
    "transcript": [
      {
        "year": 1,
        "semesters": [
          {
            "semester": 1,
            "courses": [
              {
                "course_code": "CS101",
                "course_name": "Introduction to Programming",
                "credits": 3,
                "cc_score": 85.00,
                "ds_score": 78.00,
                "exam_score": 82.00,
                "cc_weight": 40,
                "ds_weight": 20,
                "exam_weight": 40,
                "final_grade": 82.20,
                "letter_grade": "B",
                "status": "completed"
              }
            ],
            "semester_credits": 7
          },
          {
            "semester": 2,
            "courses": [...],
            "semester_credits": 8
          }
        ],
        "year_gpa": 3.45
      },
      {
        "year": 2,
        "semesters": [...],
        "year_gpa": 3.28
      },
      {
        "year": 3,
        "semesters": [...],
        "year_gpa": 0.00
      }
    ],
    "overall_gpa": 2.32,
    "credits_taken": 90,
    "credits_remaining": 79
  }
}
```

## How Grade Weights Work

### Scenario 1: Same course, different majors
**CS301 (Database Systems)** in Computer Science program:
- CC: 30%, DS: 30%, Exam: 40%

**CS301 (Database Systems)** in Business Administration program:
- CC: 40%, DS: 20%, Exam: 40%

This is defined in `program_courses` table, allowing flexibility per major.

### Scenario 2: Grade Calculation
When a student enrollment record is saved with scores:
```php
StudentCourse::create([
    'student_id' => 1,
    'course_id' => 5,
    'cc_score' => 85,
    'ds_score' => 78,
    'exam_score' => 82,
    'cc_weight' => 40,
    'ds_weight' => 20,
    'exam_weight' => 40,
]);
```

Auto-calculated:
```
final_grade = (85 * 40/100) + (78 * 20/100) + (82 * 40/100)
            = 34 + 15.6 + 32.8
            = 82.4

letter_grade = B (since 82.4 is between 80-90)
```

## Student Registration Updates

Registration now requires `major_id` instead of string `major`:

```json
POST /api/register
{
  "name": "John Doe",
  "email": "john@university.edu",
  "password": "password123",
  "password_confirmation": "password123",
  "major_id": 1,
  "year_level": 1,
  "academic_year": "2024-2025",
  "class": "First Year"
}
```

Response includes full major object:
```json
{
  "user": {...},
  "student": {
    "id": 11,
    "student_id": "109800011",
    "major_id": 1,
    "name": "John Doe",
    "year_level": 1,
    "major": {
      "id": 1,
      "code": "CS",
      "name": "Computer Science",
      "department": "Engineering",
      "duration_years": 5,
      "total_credits_required": 169
    }
  },
  "token": "..."
}
```

## Seeded Data

### Majors
1. Computer Science (CS) - 5 years, 169 credits
2. Electrical Engineering (EE) - 5 years, 169 credits
3. Mechanical Engineering (ME) - 5 years, 169 credits
4. Business Administration (BA) - 4 years, 132 credits

### Courses
8 courses including CS101, CS102, CS201, CS202, CS203, CS301, CS302, MATH101

### Program Courses
8 program course mappings for CS major across years 1-3

### Students
10 students with varying year levels (1-5), all with grades for their completed courses

### Test Credentials
```
Email: john.doe@university.edu
Password: password
Student ID: 109800001
Major: Computer Science
Year: 3
```

## Key Features

1. **Year-based Structure**: Students progress through years, courses are organized by year and semester
2. **Flexible Grade Weights**: Different majors can have different weight distributions for the same course
3. **Full Transcript Access**: Students can view ALL grades from year 1 through current year
4. **Auto-Grade Calculation**: Final grades calculated automatically when component scores entered
5. **GPA Tracking**: Overall GPA and year-by-year GPA calculation
6. **Curriculum Visibility**: Students can see what courses they need for each year
7. **Program Integration**: Everything tied to the student's specific major/program

## Migration Order (Important!)
1. majors
2. students (requires majors)
3. academic_calendars
4. courses (requires academic_calendars)
5. program_courses (requires majors + courses)
6. student_courses (requires students + courses)

## Models Created/Updated

**New Models:**
- `Major` - Academic programs
- `ProgramCourse` - Curriculum definitions
- `StudentCourse` - Grade records with auto-calculation

**Updated Models:**
- `Student` - Added major relationship, transcript methods, GPA calculations
- `Course` - Added major relationships, removed grade_components

**New Controllers:**
- `MajorController` - Manage majors and view curricula
- `GradeController` - View transcripts, update grades, calculate GPAs

## Testing the System

```bash
# Check data
php artisan tinker

# View student with grades
$student = App\Models\Student::with('major', 'studentCourses.course')->first();
echo $student->name . ' - ' . $student->major->name;
echo 'GPA: ' . $student->calculateOverallGPA();

# View major curriculum
$major = App\Models\Major::find(1);
$curriculum = $major->getCurriculum();

# View transcript
$transcript = $student->getFullTranscript();
```
