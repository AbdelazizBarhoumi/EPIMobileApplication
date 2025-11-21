// ============================================================================
// APP PROVIDERS - Dependency Injection Setup
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_client.dart';
import 'controllers/attendance_controller.dart';
import 'controllers/club_controller.dart';
import 'controllers/course_controller.dart';
import 'controllers/event_controller.dart';
import 'controllers/financial_controller.dart';
import 'controllers/grade_controller.dart';
import 'controllers/news_controller.dart';
import 'controllers/schedule_controller.dart';
import 'controllers/student_controller.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/club_service.dart';
import 'services/course_service.dart';
import 'services/event_service.dart';
import 'services/financial_service.dart';
import 'services/grade_service.dart';
import 'services/major_service.dart';
import 'services/news_service.dart';
import 'services/schedule_service.dart';
import 'services/student_service.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  final String baseUrl;

  const AppProviders({
    super.key,
    required this.child,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize API Client
    final apiClient = ApiClient(baseUrl: baseUrl);

    // Initialize Services
    final authService = AuthService(apiClient);
    final studentService = StudentService(apiClient);
    final gradeService = GradeService(apiClient);
    final courseService = CourseService(apiClient);
    final scheduleService = ScheduleService(apiClient);
    final financialService = FinancialService(apiClient);
    final attendanceService = AttendanceService(apiClient);
    final newsService = NewsService(apiClient);
    final clubService = ClubService(apiClient);
    final eventService = EventService(apiClient);
    final majorService = MajorService(apiClient);

    return MultiProvider(
      providers: [
        // API Client
        Provider<ApiClient>.value(value: apiClient),

        // Services
        Provider<AuthService>.value(value: authService),
        Provider<StudentService>.value(value: studentService),
        Provider<GradeService>.value(value: gradeService),
        Provider<CourseService>.value(value: courseService),
        Provider<ScheduleService>.value(value: scheduleService),
        Provider<FinancialService>.value(value: financialService),
        Provider<AttendanceService>.value(value: attendanceService),
        Provider<NewsService>.value(value: newsService),
        Provider<ClubService>.value(value: clubService),
        Provider<EventService>.value(value: eventService),
        Provider<MajorService>.value(value: majorService),

        // Controllers
        ChangeNotifierProvider<StudentController>(
          create: (_) => StudentController(studentService),
        ),
        ChangeNotifierProvider<GradeController>(
          create: (_) => GradeController(gradeService),
        ),
        ChangeNotifierProvider<CourseController>(
          create: (_) => CourseController(courseService),
        ),
        ChangeNotifierProvider<ScheduleController>(
          create: (_) => ScheduleController(scheduleService),
        ),
        ChangeNotifierProvider<FinancialController>(
          create: (_) => FinancialController(financialService),
        ),
        ChangeNotifierProvider<AttendanceController>(
          create: (_) => AttendanceController(attendanceService),
        ),
        ChangeNotifierProvider<NewsController>(
          create: (_) => NewsController(newsService),
        ),
        ChangeNotifierProvider<ClubController>(
          create: (_) => ClubController(clubService),
        ),
        ChangeNotifierProvider<EventController>(
          create: (_) => EventController(eventService),
        ),
      ],
      child: child,
    );
  }
}
