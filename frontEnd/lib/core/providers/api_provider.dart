// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\core\providers\api_provider.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../api_client.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../services/grade_service.dart';
import '../services/course_service.dart';
import '../services/schedule_service.dart';
import '../services/financial_service.dart';
import '../services/attendance_service.dart';
import '../services/news_service.dart';
import '../services/club_service.dart';
import '../services/event_service.dart';
import '../services/major_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/grade_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/financial_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/news_controller.dart';
import '../controllers/club_controller.dart';
import '../controllers/event_controller.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart' as auth_feature;
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';

class ApiProvider {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  static ApiClient createApiClient() {
    return ApiClient(baseUrl: baseUrl);
  }

  static List<SingleChildWidget> get providers => [
    // API Client
    Provider<ApiClient>(
      create: (_) => createApiClient(),
    ),

    // ========================================================================
    // SERVICES
    // ========================================================================
    ProxyProvider<ApiClient, AuthService>(
      update: (_, apiClient, __) => AuthService(apiClient),
    ),
    ProxyProvider<ApiClient, StudentService>(
      update: (_, apiClient, __) => StudentService(apiClient),
    ),
    ProxyProvider<ApiClient, GradeService>(
      update: (_, apiClient, __) => GradeService(apiClient),
    ),
    ProxyProvider<ApiClient, CourseService>(
      update: (_, apiClient, __) => CourseService(apiClient),
    ),
    ProxyProvider<ApiClient, ScheduleService>(
      update: (_, apiClient, __) => ScheduleService(apiClient),
    ),
    ProxyProvider<ApiClient, FinancialService>(
      update: (_, apiClient, __) => FinancialService(apiClient),
    ),
    ProxyProvider<ApiClient, AttendanceService>(
      update: (_, apiClient, __) => AttendanceService(apiClient),
    ),
    ProxyProvider<ApiClient, NewsService>(
      update: (_, apiClient, __) => NewsService(apiClient),
    ),
    ProxyProvider<ApiClient, ClubService>(
      update: (_, apiClient, __) => ClubService(apiClient),
    ),
    ProxyProvider<ApiClient, EventService>(
      update: (_, apiClient, __) => EventService(apiClient),
    ),
    ProxyProvider<ApiClient, MajorService>(
      update: (_, apiClient, __) => MajorService(apiClient),
    ),

    // Feature-specific repositories
    ProxyProvider<ApiClient, AuthRepository>(
      update: (_, apiClient, __) => AuthRepository(apiClient),
    ),
    ProxyProvider<ApiClient, ProfileRepository>(
      update: (_, apiClient, __) => ProfileRepository(apiClient),
    ),

    // ========================================================================
    // CONTROLLERS
    // ========================================================================
    ChangeNotifierProxyProvider<AuthService, AuthController>(
      create: (context) => AuthController(context.read<AuthService>()),
      update: (_, authService, authController) => authController ?? AuthController(authService),
    ),
    ChangeNotifierProxyProvider<StudentService, StudentController>(
      create: (context) => StudentController(context.read<StudentService>()),
      update: (_, service, controller) => controller ?? StudentController(service),
    ),
    ChangeNotifierProxyProvider<GradeService, GradeController>(
      create: (context) => GradeController(context.read<GradeService>()),
      update: (_, service, controller) => controller ?? GradeController(service),
    ),
    ChangeNotifierProxyProvider<CourseService, CourseController>(
      create: (context) => CourseController(context.read<CourseService>()),
      update: (_, service, controller) => controller ?? CourseController(service),
    ),
    ChangeNotifierProxyProvider<ScheduleService, ScheduleController>(
      create: (context) => ScheduleController(context.read<ScheduleService>()),
      update: (_, service, controller) => controller ?? ScheduleController(service),
    ),
    ChangeNotifierProxyProvider<FinancialService, FinancialController>(
      create: (context) => FinancialController(context.read<FinancialService>()),
      update: (_, service, controller) => controller ?? FinancialController(service),
    ),
    ChangeNotifierProxyProvider<AttendanceService, AttendanceController>(
      create: (context) => AttendanceController(context.read<AttendanceService>()),
      update: (_, service, controller) => controller ?? AttendanceController(service),
    ),
    ChangeNotifierProxyProvider<NewsService, NewsController>(
      create: (context) => NewsController(context.read<NewsService>()),
      update: (_, service, controller) => controller ?? NewsController(service),
    ),
    ChangeNotifierProxyProvider<ClubService, ClubController>(
      create: (context) => ClubController(context.read<ClubService>()),
      update: (_, service, controller) => controller ?? ClubController(service),
    ),
    ChangeNotifierProxyProvider<EventService, EventController>(
      create: (context) => EventController(context.read<EventService>()),
      update: (_, service, controller) => controller ?? EventController(service),
    ),

    // Feature-specific controllers
    ChangeNotifierProxyProvider<AuthRepository, auth_feature.AuthController>(
      create: (context) => auth_feature.AuthController(context.read<AuthRepository>()),
      update: (_, authRepository, authController) => authController ?? auth_feature.AuthController(authRepository),
    ),
    ChangeNotifierProxyProvider<ProfileRepository, ProfileController>(
      create: (context) => ProfileController(context.read<ProfileRepository>()),
      update: (_, profileRepository, profileController) => profileController ?? ProfileController(profileRepository),
    ),
  ];
}
