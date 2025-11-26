// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\routes\app_routes.dart
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../login_page.dart';
import '../pages/profile_page.dart';
import '../pages/clubs_page.dart';
import '../pages/grades_page.dart';
import '../pages/schedule_page.dart';
import '../pages/absences_page.dart';
import '../pages/bills_page.dart';
import '../pages/activities_page.dart';
import '../pages/payment_page.dart';
import '../pages/search_page.dart';
import '../pages/notifications_page.dart';
import '../pages/chat_page.dart';
import '../pages/courses_page.dart';
import '../pages/news_page.dart';
import '../pages/year_schedule_page.dart';
import '../pages/firebase_test_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String clubs = '/clubs';
  static const String grades = '/grades';
  static const String schedule = '/schedule';
  static const String absences = '/absences';
  static const String bills = '/bills';
  static const String activities = '/activities';
  static const String payment = '/payment';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String chat = '/chat';
  static const String courses = '/courses';
  static const String news = '/news';
  static const String yearSchedule = '/year-schedule';
  static const String firebaseTest = '/firebase-test';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    profile: (context) => const ProfilePage(),
    clubs: (context) => const ClubsPage(),
    grades: (context) => const GradesPage(),
    schedule: (context) => const SchedulePage(),
    absences: (context) => const AbsencesPage(),
    bills: (context) => const BillsPage(),
    activities: (context) => const ActivitiesPage(),
    payment: (context) => const PaymentPage(),
    search: (context) => const SearchPage(),
    notifications: (context) => const NotificationsPage(),
    chat: (context) => const ChatPage(),
    courses: (context) => const CoursesPage(),
    news: (context) => const NewsPage(),
    yearSchedule: (context) => const YearSchedulePage(),
    firebaseTest: (context) => const FirebaseTestPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle dynamic routes if needed
    return null;
  }

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateReplacement(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
