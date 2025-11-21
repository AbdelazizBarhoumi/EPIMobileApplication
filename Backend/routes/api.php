<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\Api\StudentController;
use App\Http\Controllers\Api\CourseController;
use App\Http\Controllers\Api\FinancialController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\ClubController;
use App\Http\Controllers\Api\NewsController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\MajorController;
use App\Http\Controllers\GradeController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\TeacherController;
use App\Http\Controllers\AttendanceController;

// Public routes
Route::post('/register', [RegisteredUserController::class, 'store']);
Route::post('/login', [AuthenticatedSessionController::class, 'store']);

// News routes (public)
Route::prefix('news')->group(function () {
    Route::get('/', [NewsController::class, 'index']);
    Route::get('/featured', [NewsController::class, 'featured']);
    Route::get('/recent', [NewsController::class, 'recent']);
    Route::get('/{id}', [NewsController::class, 'show']);
});

// Protected routes
Route::middleware(['auth:sanctum'])->group(function () {
    // Auth routes
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);

    // Student routes
    Route::prefix('student')->group(function () {
        Route::get('/profile', [StudentController::class, 'profile']);
        Route::get('/dashboard', [StudentController::class, 'dashboard']);
        Route::get('/courses', [StudentController::class, 'courses']);
        Route::get('/attendance', [StudentController::class, 'attendance']);
    });

    // Course routes
    Route::prefix('courses')->group(function () {
        Route::get('/', [CourseController::class, 'index']);
        Route::get('/schedule', [CourseController::class, 'schedule']);
        Route::get('/{id}', [CourseController::class, 'show']);
    });

    // Financial routes
    Route::prefix('financial')->group(function () {
        Route::get('/summary', [FinancialController::class, 'summary']);
        Route::get('/bills', [FinancialController::class, 'bills']);
        Route::get('/bills/{id}', [FinancialController::class, 'showBill']);
        Route::get('/payments', [FinancialController::class, 'payments']);
        Route::post('/payments', [FinancialController::class, 'createPayment']);
    });

    // Event routes
    Route::prefix('events')->group(function () {
        Route::get('/', [EventController::class, 'index']);
        Route::get('/my-events', [EventController::class, 'myEvents']);
        Route::get('/{id}', [EventController::class, 'show']);
        Route::post('/{id}/register', [EventController::class, 'register']);
        Route::delete('/{id}/register', [EventController::class, 'cancelRegistration']);
    });

    // Club routes
    Route::prefix('clubs')->group(function () {
        Route::get('/', [ClubController::class, 'index']);
        Route::get('/my-clubs', [ClubController::class, 'myClubs']);
        Route::get('/{id}', [ClubController::class, 'show']);
        Route::post('/{id}/join', [ClubController::class, 'join']);
        Route::delete('/{id}/leave', [ClubController::class, 'leave']);
    });

    // Search route
    Route::get('/search', [SearchController::class, 'search']);
    
    // Major/Program routes
    Route::prefix('majors')->group(function () {
        Route::get('/', [MajorController::class, 'index']);
        Route::get('/{major}', [MajorController::class, 'show']);
        Route::get('/{major}/curriculum', [MajorController::class, 'curriculum']);
        Route::get('/{major}/year/{year}', [MajorController::class, 'coursesByYear']);
        Route::get('/{major}/year/{year}/semester/{semester}', [MajorController::class, 'coursesByYearAndSemester']);
    });
    
    // Grade/Transcript routes
    Route::prefix('grades')->group(function () {
        Route::get('/student/{student}/transcript', [GradeController::class, 'transcript']);
        Route::get('/student/{student}/transcript/year/{year}', [GradeController::class, 'transcriptByYear']);
        Route::get('/student/{student}/current-semester', [GradeController::class, 'currentSemester']);
        Route::put('/student/{student}/course/{courseId}', [GradeController::class, 'updateGrades']);
        Route::get('/student/{student}/gpa', [GradeController::class, 'gpaStats']);
    });
    
    // Schedule routes
    Route::prefix('schedule')->group(function () {
        Route::get('/major/{major}/year/{year}/semester/{semester}', [ScheduleController::class, 'getWeeklySchedule']);
        Route::get('/my-schedule', [ScheduleController::class, 'getStudentSchedule']);
    });

    // Teacher routes
    Route::prefix('teachers')->group(function () {
        Route::get('/my-teachers', [TeacherController::class, 'getMyTeachers']);
        Route::get('/{teacher}', [TeacherController::class, 'show']);
        Route::get('/{teacher}/schedule', [TeacherController::class, 'getSchedule']);
    });

    // Attendance routes
    Route::prefix('attendance')->group(function () {
        Route::get('/my-attendance', [AttendanceController::class, 'getMyAttendance']);
        Route::get('/course/{courseId}', [AttendanceController::class, 'getCourseAttendance']);
        Route::post('/mark', [AttendanceController::class, 'markAttendance']);
        Route::post('/bulk-mark', [AttendanceController::class, 'bulkMarkAttendance']);
    });
});