# Student API Usage Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Authentication](#authentication)
4. [API Endpoints](#api-endpoints)
5. [Student Profile & Dashboard](#student-profile--dashboard)
6. [Course Management](#course-management)
7. [Financial Management](#financial-management)
8. [Events](#events)
9. [Clubs](#clubs)
10. [News](#news)
11. [Search](#search)
12. [Error Handling](#error-handling)
13. [Code Examples](#code-examples)

---

## Introduction

This API provides a comprehensive backend for the Student Management System. It allows students to:
- Manage their profile and view academic dashboard
- Access course information and attendance records
- View and pay bills
- Register for events
- Join clubs
- Stay updated with campus news
- Search across all content

**Base URL**: `http://your-domain.com/api`

**API Version**: 1.0

**Response Format**: JSON

---

## Getting Started

### Prerequisites
- A registered student account
- Valid student ID
- Internet connection
- API token for authenticated requests

### Quick Start
1. Register your account
2. Login to receive authentication token
3. Include token in all subsequent requests
4. Start using the API endpoints

---

## Authentication

### Register a New Account

**Endpoint**: `POST /register`

**Access**: Public

**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john.doe@university.edu",
  "password": "SecurePass123!",
  "password_confirmation": "SecurePass123!"
}
```

**Response** (200):
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@university.edu"
  },
  "token": "1|abc123def456..."
}
```

**Validation Rules**:
- `name`: Required, string
- `email`: Required, valid email, unique
- `password`: Required, minimum 8 characters
- `password_confirmation`: Must match password

---

### Login

**Endpoint**: `POST /login`

**Access**: Public

**Request Body**:
```json
{
  "email": "john.doe@university.edu",
  "password": "SecurePass123!"
}
```

**Response** (200):
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@university.edu"
  },
  "token": "1|abc123def456..."
}
```

**Important**: Save the token securely and include it in all authenticated requests.

---

### Logout

**Endpoint**: `POST /logout`

**Access**: Authenticated

**Headers**:
```
Authorization: Bearer {your_token}
```

**Response** (200):
```json
{
  "message": "Logged out successfully"
}
```

---

### Using Authentication Tokens

For all authenticated endpoints, include the token in the Authorization header:

```
Authorization: Bearer 1|abc123def456...
```

**Example cURL**:
```bash
curl -H "Authorization: Bearer 1|abc123def456..." \
     http://your-domain.com/api/student/profile
```

---

## API Endpoints

### Overview

| Category | Endpoint | Method | Auth Required |
|----------|----------|--------|---------------|
| Profile | `/student/profile` | GET | ✅ |
| Dashboard | `/student/dashboard` | GET | ✅ |
| Courses | `/student/courses` | GET | ✅ |
| Attendance | `/student/attendance` | GET | ✅ |
| Bills | `/financial/bills` | GET | ✅ |
| Payments | `/financial/payments` | POST | ✅ |
| Events | `/events` | GET | ❌ |
| Event Register | `/events/{id}/register` | POST | ✅ |
| Clubs | `/clubs` | GET | ❌ |
| Join Club | `/clubs/{id}/join` | POST | ✅ |
| News | `/news` | GET | ❌ |
| Search | `/search` | GET | ❌ |

---

## Student Profile & Dashboard

### Get Student Profile

**Endpoint**: `GET /student/profile`

**Access**: Authenticated

**Description**: Retrieve complete student profile including personal information, enrolled courses, bills, and payments.

**Response** (200):
```json
{
  "student": {
    "id": 1,
    "student_id": "STU2025001",
    "user_id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@university.edu",
    "phone": "+1234567890",
    "date_of_birth": "2003-05-15",
    "gender": "male",
    "address": "123 Campus Street, University City",
    "major": "Computer Science",
    "gpa": 3.75,
    "credits_completed": 90,
    "enrollment_date": "2023-09-01",
    "expected_graduation": "2027-06-15",
    "status": "active",
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john.doe@university.edu"
    },
    "courses": [
      {
        "id": 1,
        "course_code": "CS101",
        "course_name": "Introduction to Programming",
        "semester": "Fall 2025",
        "grade": "A",
        "status": "active"
      }
    ],
    "bills": [
      {
        "id": 1,
        "type": "tuition",
        "amount": 5000.00,
        "status": "pending"
      }
    ]
  }
}
```

**Error Response** (404):
```json
{
  "message": "Student profile not found"
}
```

---

### Get Student Dashboard

**Endpoint**: `GET /student/dashboard`

**Access**: Authenticated

**Description**: Get comprehensive dashboard with semester statistics, financial summary, and upcoming events.

**Response** (200):
```json
{
  "student": {
    "id": 1,
    "student_id": "STU2025001",
    "first_name": "John",
    "last_name": "Doe",
    "major": "Computer Science",
    "gpa": 3.75
  },
  "semester_stats": {
    "gpa": 3.75,
    "credits": 90,
    "current_courses": 5,
    "attendance_rate": 92.5
  },
  "financial_summary": {
    "total_bills": 8000.00,
    "total_paid": 5000.00,
    "pending_amount": 3000.00
  },
  "upcoming_events": [
    {
      "id": 1,
      "title": "Career Fair 2025",
      "event_date": "2025-12-01 10:00:00",
      "location": "Main Hall",
      "category": "career"
    }
  ]
}
```

---

## Course Management

### Get Enrolled Courses

**Endpoint**: `GET /student/courses`

**Access**: Authenticated

**Description**: Retrieve all courses the student is currently enrolled in.

**Response** (200):
```json
{
  "courses": [
    {
      "course": {
        "id": 1,
        "course_code": "CS101",
        "course_name": "Introduction to Programming",
        "description": "Learn programming fundamentals",
        "credits": 3,
        "department": "Computer Science",
        "instructor": {
          "name": "Dr. Smith",
          "email": "dr.smith@university.edu"
        }
      },
      "enrollment": {
        "semester": "Fall 2025",
        "grade": "A",
        "status": "active",
        "enrolled_at": "2025-09-01"
      }
    }
  ]
}
```

---

### Get Course Details

**Endpoint**: `GET /courses/{id}`

**Access**: Authenticated

**Description**: Get detailed information about a specific course.

**Response** (200):
```json
{
  "course": {
    "id": 1,
    "course_code": "CS101",
    "course_name": "Introduction to Programming",
    "description": "Comprehensive introduction to programming concepts",
    "credits": 3,
    "department": "Computer Science",
    "semester": "Fall 2025",
    "schedule": "Mon/Wed/Fri 10:00-11:00 AM",
    "location": "Building A, Room 201",
    "instructor": {
      "name": "Dr. Smith",
      "email": "dr.smith@university.edu",
      "office_hours": "Tue/Thu 2:00-4:00 PM"
    },
    "capacity": 50,
    "enrolled_count": 45,
    "syllabus": "http://link-to-syllabus.pdf"
  }
}
```

---

### Get Attendance Records

**Endpoint**: `GET /student/attendance`

**Access**: Authenticated

**Query Parameters**:
- `course_id` (optional): Filter by specific course

**Examples**:
- All attendance: `/student/attendance`
- Specific course: `/student/attendance?course_id=1`

**Response** (200):
```json
{
  "attendance": [
    {
      "id": 1,
      "course_id": 1,
      "date": "2025-11-15",
      "status": "present",
      "notes": null,
      "course": {
        "course_code": "CS101",
        "course_name": "Introduction to Programming"
      }
    },
    {
      "id": 2,
      "course_id": 1,
      "date": "2025-11-18",
      "status": "late",
      "notes": "Arrived 10 minutes late",
      "course": {
        "course_code": "CS101",
        "course_name": "Introduction to Programming"
      }
    }
  ],
  "summary": {
    "total": 30,
    "present": 27,
    "absent": 2,
    "late": 1
  }
}
```

**Attendance Status Values**:
- `present`: Student was on time
- `absent`: Student did not attend
- `late`: Student arrived late
- `excused`: Absence was excused

---

## Financial Management

### Get Bills

**Endpoint**: `GET /financial/bills`

**Access**: Authenticated

**Query Parameters**:
- `status` (optional): Filter by status (`pending`, `paid`, `overdue`)
- `type` (optional): Filter by type (`tuition`, `housing`, `meal_plan`, `library`, `other`)

**Examples**:
- All bills: `/financial/bills`
- Pending bills: `/financial/bills?status=pending`
- Tuition bills: `/financial/bills?type=tuition`

**Response** (200):
```json
{
  "bills": [
    {
      "id": 1,
      "student_id": 1,
      "type": "tuition",
      "amount": 5000.00,
      "due_date": "2025-12-31",
      "status": "pending",
      "description": "Fall 2025 Tuition",
      "semester": "Fall 2025",
      "is_overdue": false,
      "days_until_due": 41
    },
    {
      "id": 2,
      "student_id": 1,
      "type": "housing",
      "amount": 1500.00,
      "due_date": "2025-12-15",
      "status": "paid",
      "description": "Semester Housing Fee"
    }
  ],
  "summary": {
    "total": 6500.00,
    "paid": 1500.00,
    "pending": 5000.00
  }
}
```

**Bill Types**:
- `tuition`: Tuition fees
- `housing`: Dormitory/housing fees
- `meal_plan`: Meal plan charges
- `library`: Library fines
- `other`: Miscellaneous fees

---

### Get Single Bill

**Endpoint**: `GET /financial/bills/{id}`

**Access**: Authenticated

**Response** (200):
```json
{
  "bill": {
    "id": 1,
    "type": "tuition",
    "amount": 5000.00,
    "due_date": "2025-12-31",
    "status": "pending",
    "description": "Fall 2025 Tuition",
    "created_at": "2025-09-01",
    "payments": [
      {
        "id": 1,
        "amount": 2000.00,
        "method": "bank_transfer",
        "payment_date": "2025-10-01",
        "transaction_id": "TXN123456"
      }
    ],
    "total_paid": 2000.00,
    "remaining_balance": 3000.00
  }
}
```

---

### Create Payment

**Endpoint**: `POST /financial/payments`

**Access**: Authenticated

**Request Body**:
```json
{
  "bill_id": 1,
  "amount": 1000.00,
  "method": "card",
  "transaction_id": "TXN789012",
  "notes": "Payment for Fall tuition"
}
```

**Validation Rules**:
- `bill_id`: Required, must exist
- `amount`: Required, numeric, greater than 0
- `method`: Required, one of: `cash`, `card`, `bank_transfer`, `mobile_money`
- `transaction_id`: Optional, string
- `notes`: Optional, string

**Response** (201):
```json
{
  "message": "Payment recorded successfully",
  "payment": {
    "id": 2,
    "student_id": 1,
    "bill_id": 1,
    "amount": 1000.00,
    "method": "card",
    "transaction_id": "TXN789012",
    "status": "completed",
    "payment_date": "2025-11-20",
    "notes": "Payment for Fall tuition"
  },
  "bill": {
    "id": 1,
    "amount": 5000.00,
    "status": "pending",
    "total_paid": 3000.00,
    "remaining_balance": 2000.00
  }
}
```

**Error Response** (400):
```json
{
  "message": "Payment amount exceeds remaining bill balance",
  "remaining_balance": 2000.00
}
```

---

### Get Financial Summary

**Endpoint**: `GET /financial/summary`

**Access**: Authenticated

**Response** (200):
```json
{
  "summary": {
    "total_bills": 8000.00,
    "total_paid": 5000.00,
    "outstanding": 3000.00,
    "pending_bills_count": 2,
    "bills_by_type": {
      "tuition": 5000.00,
      "housing": 1500.00,
      "meal_plan": 1000.00,
      "library": 500.00
    }
  },
  "recent_payments": [
    {
      "id": 5,
      "amount": 1000.00,
      "method": "card",
      "payment_date": "2025-11-20",
      "bill": {
        "type": "tuition",
        "description": "Fall 2025 Tuition"
      }
    }
  ]
}
```

---

## Events

### List All Events

**Endpoint**: `GET /events`

**Access**: Public

**Query Parameters**:
- `category` (optional): Filter by category
- `upcoming` (optional): Set to `true` for upcoming events only

**Categories**:
- `academic`
- `sports`
- `cultural`
- `social`
- `career`
- `other`

**Examples**:
- All events: `/events`
- Career events: `/events?category=career`
- Upcoming only: `/events?upcoming=true`

**Response** (200):
```json
{
  "events": [
    {
      "id": 1,
      "title": "Career Fair 2025",
      "description": "Annual career fair with 50+ companies",
      "event_date": "2025-12-01 10:00:00",
      "event_end_date": "2025-12-01 16:00:00",
      "location": "Main Hall",
      "category": "career",
      "capacity": 500,
      "registered_count": 234,
      "spots_available": 266,
      "organizer": "Career Services",
      "image_url": "http://example.com/career-fair.jpg",
      "is_full": false,
      "is_upcoming": true
    }
  ]
}
```

---

### Get Event Details

**Endpoint**: `GET /events/{id}`

**Access**: Public

**Response** (200):
```json
{
  "event": {
    "id": 1,
    "title": "Career Fair 2025",
    "description": "Annual career fair featuring top companies...",
    "event_date": "2025-12-01 10:00:00",
    "event_end_date": "2025-12-01 16:00:00",
    "location": "Main Hall",
    "category": "career",
    "capacity": 500,
    "registered_count": 234,
    "spots_available": 266,
    "organizer": "Career Services",
    "contact_email": "careers@university.edu",
    "image_url": "http://example.com/career-fair.jpg",
    "is_full": false,
    "is_upcoming": true,
    "is_active": true
  }
}
```

---

### Register for Event

**Endpoint**: `POST /events/{id}/register`

**Access**: Authenticated

**Response** (200):
```json
{
  "success": true,
  "message": "Successfully registered for event",
  "registration": {
    "event_id": 1,
    "student_id": 1,
    "registered_at": "2025-11-20 14:30:00",
    "status": "registered"
  }
}
```

**Error Response** (400 - Event Full):
```json
{
  "success": false,
  "message": "Event is full"
}
```

**Error Response** (400 - Already Registered):
```json
{
  "success": false,
  "message": "Already registered for this event"
}
```

---

### Cancel Event Registration

**Endpoint**: `DELETE /events/{id}/register`

**Access**: Authenticated

**Response** (200):
```json
{
  "success": true,
  "message": "Registration cancelled successfully"
}
```

**Error Response** (404):
```json
{
  "success": false,
  "message": "Not registered for this event"
}
```

---

### Get My Registered Events

**Endpoint**: `GET /events/registered`

**Access**: Authenticated

**Response** (200):
```json
{
  "events": [
    {
      "id": 1,
      "title": "Career Fair 2025",
      "event_date": "2025-12-01 10:00:00",
      "location": "Main Hall",
      "registration": {
        "registered_at": "2025-11-20 14:30:00",
        "status": "registered"
      }
    }
  ]
}
```

---

## Clubs

### List All Clubs

**Endpoint**: `GET /clubs`

**Access**: Public

**Query Parameters**:
- `active` (optional): Set to `true` for active clubs only

**Response** (200):
```json
{
  "clubs": [
    {
      "id": 1,
      "name": "Computer Science Club",
      "description": "For students interested in programming and technology",
      "category": "academic",
      "advisor": "Dr. Johnson",
      "meeting_schedule": "Every Tuesday at 5 PM",
      "location": "Lab Building, Room 301",
      "contact_email": "cs.club@university.edu",
      "member_count": 45,
      "image_url": "http://example.com/cs-club.jpg",
      "is_active": true
    }
  ]
}
```

**Club Categories**:
- `academic`
- `sports`
- `arts`
- `cultural`
- `volunteer`
- `professional`
- `other`

---

### Get Club Details

**Endpoint**: `GET /clubs/{id}`

**Access**: Public

**Response** (200):
```json
{
  "club": {
    "id": 1,
    "name": "Computer Science Club",
    "description": "We organize coding competitions, tech talks...",
    "category": "academic",
    "advisor": "Dr. Johnson",
    "meeting_schedule": "Every Tuesday at 5 PM",
    "location": "Lab Building, Room 301",
    "contact_email": "cs.club@university.edu",
    "member_count": 45,
    "image_url": "http://example.com/cs-club.jpg",
    "is_active": true,
    "founded_date": "2020-09-01",
    "social_media": {
      "facebook": "https://facebook.com/csclub",
      "instagram": "@csclub"
    }
  }
}
```

---

### Join Club

**Endpoint**: `POST /clubs/{id}/join`

**Access**: Authenticated

**Response** (200):
```json
{
  "success": true,
  "message": "Successfully joined club",
  "membership": {
    "club_id": 1,
    "student_id": 1,
    "joined_at": "2025-11-20",
    "role": "member",
    "status": "active"
  }
}
```

**Error Response** (400 - Already Member):
```json
{
  "success": false,
  "message": "Already a member of this club"
}
```

---

### Leave Club

**Endpoint**: `DELETE /clubs/{id}/leave`

**Access**: Authenticated

**Response** (200):
```json
{
  "success": true,
  "message": "Successfully left club"
}
```

---

### Get My Clubs

**Endpoint**: `GET /clubs/my-clubs`

**Access**: Authenticated

**Response** (200):
```json
{
  "clubs": [
    {
      "id": 1,
      "name": "Computer Science Club",
      "category": "academic",
      "membership": {
        "joined_at": "2025-09-15",
        "role": "member",
        "status": "active"
      }
    }
  ]
}
```

---

## News

### Get News Feed

**Endpoint**: `GET /news`

**Access**: Public

**Query Parameters**:
- `category` (optional): Filter by category
- `limit` (optional): Number of items to return (default: 20)
- `page` (optional): Page number for pagination

**Categories**:
- `announcement`
- `academic`
- `events`
- `sports`
- `campus_life`
- `other`

**Examples**:
- Recent news: `/news`
- Announcements: `/news?category=announcement`
- First 10: `/news?limit=10`

**Response** (200):
```json
{
  "news": [
    {
      "id": 1,
      "title": "Fall 2025 Exam Schedule Released",
      "content": "The final exam schedule for Fall 2025 has been posted...",
      "excerpt": "Check your exam dates and locations...",
      "category": "academic",
      "author": "Academic Office",
      "published_at": "2025-11-15 09:00:00",
      "image_url": "http://example.com/exam-schedule.jpg",
      "is_featured": true,
      "views_count": 523
    }
  ],
  "pagination": {
    "total": 150,
    "per_page": 20,
    "current_page": 1,
    "last_page": 8
  }
}
```

---

### Get Single News Article

**Endpoint**: `GET /news/{id}`

**Access**: Public

**Response** (200):
```json
{
  "article": {
    "id": 1,
    "title": "Fall 2025 Exam Schedule Released",
    "content": "The complete final exam schedule for Fall 2025 semester...",
    "category": "academic",
    "author": "Academic Office",
    "published_at": "2025-11-15 09:00:00",
    "updated_at": "2025-11-15 09:00:00",
    "image_url": "http://example.com/exam-schedule.jpg",
    "is_featured": true,
    "views_count": 523,
    "tags": ["exams", "schedule", "fall2025"]
  }
}
```

---

## Search

### Global Search

**Endpoint**: `GET /search`

**Access**: Public

**Query Parameters**:
- `q` (required): Search query
- `type` (optional): Filter by type (`courses`, `events`, `clubs`, `news`)

**Examples**:
- Search all: `/search?q=programming`
- Search courses: `/search?q=programming&type=courses`
- Search events: `/search?q=career&type=events`

**Response** (200):
```json
{
  "query": "programming",
  "results": {
    "courses": [
      {
        "id": 1,
        "course_code": "CS101",
        "course_name": "Introduction to Programming",
        "department": "Computer Science"
      }
    ],
    "events": [
      {
        "id": 5,
        "title": "Programming Competition 2025",
        "event_date": "2025-12-10",
        "category": "academic"
      }
    ],
    "clubs": [
      {
        "id": 1,
        "name": "Computer Science Club",
        "category": "academic"
      }
    ],
    "news": [
      {
        "id": 15,
        "title": "New Programming Lab Opening",
        "category": "campus_life",
        "published_at": "2025-11-10"
      }
    ]
  },
  "total_results": 13
}
```

---

## Error Handling

### HTTP Status Codes

| Code | Meaning | When It Occurs |
|------|---------|----------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Validation failed or invalid data |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Validation errors |
| 500 | Server Error | Internal server error |

---

### Error Response Format

All errors follow this format:

```json
{
  "message": "Error description",
  "errors": {
    "field_name": [
      "Specific validation error"
    ]
  }
}
```

**Example - Validation Error** (422):
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email field is required."
    ],
    "password": [
      "The password must be at least 8 characters."
    ]
  }
}
```

**Example - Authentication Error** (401):
```json
{
  "message": "Unauthenticated."
}
```

**Example - Not Found Error** (404):
```json
{
  "message": "Resource not found"
}
```

---

## Code Examples

### Flutter/Dart Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://your-domain.com/api';
  String? authToken;

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      authToken = data['token'];
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  // Get Student Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/profile'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Get Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/dashboard'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard');
    }
  }

  // Get Bills
  Future<Map<String, dynamic>> getBills({String? status}) async {
    String url = '$baseUrl/financial/bills';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load bills');
    }
  }

  // Create Payment
  Future<Map<String, dynamic>> createPayment({
    required int billId,
    required double amount,
    required String method,
    String? transactionId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/financial/payments'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bill_id': billId,
        'amount': amount,
        'method': method,
        'transaction_id': transactionId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment failed');
    }
  }

  // Register for Event
  Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/register'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message']);
    }
  }

  // Join Club
  Future<Map<String, dynamic>> joinClub(int clubId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clubs/$clubId/join'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message']);
    }
  }

  // Search
  Future<Map<String, dynamic>> search(String query, {String? type}) async {
    String url = '$baseUrl/search?q=$query';
    if (type != null) {
      url += '&type=$type';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Search failed');
    }
  }
}
```

---

### Usage Example in Flutter Widget

```dart
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService api = ApiService();
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await api.getDashboard();
      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final student = dashboardData?['student'];
    final stats = dashboardData?['semester_stats'];
    final financial = dashboardData?['financial_summary'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${student['first_name']}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('GPA: ${stats['gpa']}'),
                    Text('Credits: ${stats['credits']}'),
                    Text('Attendance: ${stats['attendance_rate']}%'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Total Bills: \$${financial['total_bills']}'),
                    Text('Total Paid: \$${financial['total_paid']}'),
                    Text('Pending: \$${financial['pending_amount']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Best Practices

### 1. Token Management
- Store tokens securely using Flutter Secure Storage
- Include tokens in all authenticated requests
- Handle token expiration gracefully
- Implement token refresh mechanism

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Save token
await storage.write(key: 'auth_token', value: token);

// Read token
String? token = await storage.read(key: 'auth_token');

// Delete token on logout
await storage.delete(key: 'auth_token');
```

---

### 2. Error Handling
Always handle errors gracefully:

```dart
try {
  final data = await api.getBills();
  // Handle success
} on Exception catch (e) {
  // Show user-friendly error message
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text('Failed to load bills. Please try again.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

---

### 3. Loading States
Always show loading indicators:

```dart
class BillsScreen extends StatefulWidget {
  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  bool isLoading = true;
  List<dynamic> bills = [];

  @override
  void initState() {
    super.initState();
    loadBills();
  }

  Future<void> loadBills() async {
    setState(() => isLoading = true);
    try {
      final data = await api.getBills();
      setState(() {
        bills = data['bills'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return ListTile(
                title: Text(bill['description']),
                subtitle: Text('\$${bill['amount']}'),
                trailing: Text(bill['status']),
              );
            },
          );
  }
}
```

---

### 4. Caching
Cache frequently accessed data:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static Future<void> cacheProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_profile', jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_profile');
    if (cached != null) {
      return jsonDecode(cached);
    }
    return null;
  }
}
```

---

### 5. Pagination
Handle paginated responses:

```dart
class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> news = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadNews();
    
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
  }

  Future<void> loadNews() async {
    setState(() => isLoading = true);
    final data = await api.getNews(page: currentPage);
    setState(() {
      news = data['news'];
      isLoading = false;
    });
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoading) return;

    setState(() => isLoading = true);
    currentPage++;
    final data = await api.getNews(page: currentPage);
    
    setState(() {
      news.addAll(data['news']);
      hasMore = data['pagination']['current_page'] < 
                data['pagination']['last_page'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: news.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == news.length) {
          return Center(child: CircularProgressIndicator());
        }
        
        final article = news[index];
        return NewsCard(article: article);
      },
    );
  }
}
```

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Authentication endpoints**: 5 requests per minute
- **General endpoints**: 60 requests per minute
- **Search endpoint**: 20 requests per minute

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1637424000
```

---

## Support & Contact

### Technical Support
- Email: tech.support@university.edu
- Phone: +1-234-567-8900
- Office Hours: Monday-Friday, 9 AM - 5 PM

### Bug Reports
Please report bugs or issues to:
- GitHub: https://github.com/university/student-api/issues
- Email: bugs@university.edu

### Feature Requests
Submit feature requests through:
- Email: features@university.edu
- Student Portal feedback form

---

## Changelog

### Version 1.0.0 (November 2025)
- Initial release
- Complete student management system
- Financial management
- Event and club registration
- News and announcements
- Global search functionality

---

## FAQ

**Q: How do I get my initial credentials?**
A: Contact the registrar's office with your student ID to receive your initial login credentials.

**Q: What should I do if I forget my password?**
A: Use the `/forgot-password` endpoint or contact IT support.

**Q: Can I access the API from multiple devices?**
A: Yes, but you'll need to login on each device to get a unique token.

**Q: How long do authentication tokens last?**
A: Tokens are valid for 7 days. You'll need to login again after expiration.

**Q: Can I make payments for multiple bills at once?**
A: Currently, the API supports one payment per request. Make separate requests for multiple bills.

**Q: How do I cancel an event registration?**
A: Use the `DELETE /events/{id}/register` endpoint.

**Q: Are there any mobile apps available?**
A: The Flutter mobile app is under development and will be available soon.

**Q: How often is the news feed updated?**
A: News is updated in real-time as administrators post new content.

---

**Last Updated**: November 20, 2025  
**API Version**: 1.0  
**Documentation Version**: 1.0
