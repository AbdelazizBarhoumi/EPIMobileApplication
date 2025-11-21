# Database Requirements for Student App (Main Database)

## Student Profile
- **Student ID**: Unique identifier (e.g., 109800200)
- **Name**: Full name (e.g., Abdelaziz Barhoumi)
- **Email**: Student email (e.g., abdelaziz.barhoumi@epi.tn)
- **Major**: Field of study (e.g., Information System)
- **Avatar URL**: Path to profile picture
- **GPA**: Current GPA (e.g., 3.9)
- **Credits Taken**: Number of credits completed (e.g., 155)
- **Total Credits**: Total credits required (e.g., 169)
- **Tuition Fees**: Outstanding tuition amount (e.g., 2500.0 TND)
- **Academic Year**: Current year (e.g., 2024-2025)
- **Class**: Year level (e.g., Third Year)

## Courses
- **Course ID**: Unique identifier
- **Course Code**: Short code (e.g., CS301)
- **Course Name**: Full name (e.g., Data Structures & Algorithms)
- **Instructor**: Professor name (e.g., Dr. Ahmed Ben Ali)
- **Credits**: Credit hours (e.g., 4)
- **Schedule**: Days and times (e.g., Mon, Wed 10:00-11:30)
- **Room**: Classroom location (e.g., Room A-101)
- **Grade Components**:
  - CC (Continuous Control): Percentage score
  - DS (Directed Study): Percentage score
  - Exam: Final exam percentage
- **Final Grade**: Calculated grade
- **Semester**: Which semester the course belongs to

## Grades
- References course grades
- Overall GPA calculation
- Semester GPA
- Grade distribution (A, B, C, etc.)

## Schedule
- Weekly schedule based on enrolled courses
- Time slots per day
- Room assignments
- Instructor information

## Attendance/Absences
- **Attendance Records**:
  - Course ID
  - Date
  - Status (Present/Absent)
  - Session type (Lecture/Lab)
- **Summary per Course**:
  - Total classes
  - Present count
  - Absent count
  - Attendance percentage
- **Overall Attendance Rate**

## Financial/Bills
- **Bills**:
  - Bill ID
  - Description (e.g., Tuition Fee - Fall 2024)
  - Amount
  - Due Date
  - Status (Paid/Pending/Overdue)
- **Payments**:
  - Payment ID
  - Amount paid
  - Date
  - Method (Card, Transfer, Cash, etc.)
- **Outstanding Balance**
- **Payment History**

## Activities/Events
- **Event ID**: Unique identifier
- **Title**: Event name (e.g., Tech Innovation Workshop)
- **Description**: Detailed description
- **Date & Time**: When the event occurs
- **Location**: Venue (e.g., Building A, Room 301)
- **Category**: Type (Academic, Sports, Cultural, Social)
- **Registration Status**: Whether student is registered
- **Capacity**: Maximum participants
- **Organizer**: Who organized the event

## Clubs
- **Club ID**: Unique identifier
- **Name**: Club name (e.g., Tech Club)
- **Description**: What the club is about
- **Category**: Type of club
- **Member Count**: Number of active members
- **President/Leader**: Club leadership
- **Meeting Schedule**: When they meet
- **Membership Status**: Whether student is a member
- **Join Date**: When student joined (if member)

## News/Announcements
- **News ID**: Unique identifier
- **Title**: Headline
- **Description**: Full content
- **Image URL**: Associated image
- **Publish Date**: When posted
- **Category**: Type (Academic, Events, Financial, etc.)
- **Link**: Optional external link
- **Author**: Who posted it

## Academic Calendar (Year Schedule)
- **Semester ID**: Unique identifier
- **Name**: Semester name (e.g., Fall 2024)
- **Start Date**: When semester begins
- **End Date**: When semester ends
- **Status**: Active/Upcoming/Past
- **Credits**: Planned credits for semester
- **Courses Count**: Number of courses
- **Important Dates/Events**:
  - Classes begin
  - Add/drop deadline
  - Midterms
  - Finals
  - Holidays
  - Registration periods

## Search Functionality
- Search across all entities:
  - Courses (by code, name, instructor)
  - Events (by title, description)
  - Clubs (by name, description)
  - People (professors, students if applicable)
  - News (by title, content)

## Home Dashboard Data
- Aggregated data for quick view:
  - Current tuition balance
  - Credits progress (taken/total)
  - Recent notifications count
  - Upcoming events
  - News carousel images and headlines
