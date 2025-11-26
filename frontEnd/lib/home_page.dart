// ============================================================================
// HOME PAGE - Main Dashboard
// ============================================================================
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
// Import all pages - Using dynamic versions
import 'pages/profile_page_dynamic.dart';
import 'pages/clubs_page.dart';
import 'pages/grades_page_dynamic.dart';
import 'pages/schedule_page_dynamic.dart';
import 'pages/absences_page_dynamic.dart';
import 'pages/bills_page_enhanced.dart';
import 'pages/activities_page.dart';
import 'pages/payment_page.dart';
import 'pages/search_page.dart';
import 'pages/notifications_page.dart';
import 'pages/news_page.dart';
import 'pages/year_schedule_page.dart';
import 'pages/courses_page_dynamic.dart';
import 'features/chat/presentation/pages/chat_list_page.dart';
// Import controllers and models
import 'core/controllers/event_controller.dart';
import 'core/controllers/student_controller.dart';
import 'core/controllers/financial_controller.dart';
import 'core/controllers/schedule_controller.dart';
import 'core/controllers/course_controller.dart';
import 'core/models/event.dart';
import 'core/models/schedule.dart';
import 'shared/widgets/shimmer_loading.dart';
import 'core/firebase/firebase_service.dart';

// ============================================================================
// HOMEPAGE WIDGET - Main Application Dashboard
// ============================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ========================================================================
  // STATE VARIABLES
  // ========================================================================

  /// Banner images for carousel slider - fallback while loading events
  final List<String> imageList = [
    "assets/Banners1.jpg",
    "assets/Banners2.jpg",
    "assets/Banners3.jpg",
    "assets/Banners4.jpg",
    "assets/Banners5.jpg",
    "assets/Banners6.jpg",
  ];

  /// Bottom navigation bar controller
  final NotchBottomBarController _controller = NotchBottomBarController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    print('\n🚀 ===== HOME PAGE INIT =====');
    print('🚀 Starting data load sequence...');
    // Load cached data immediately (non-blocking)
    // Then refresh from API in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // All controllers should load from cache first, then refresh from API
      // This provides instant UI update with cached data
      // while fetching fresh data in the background
      
      print('🚀 Post-frame callback triggered, calling _loadDataWithRetry...');
      _loadDataWithRetry();
    });
  }

  /// Load data with automatic retry on failure
  Future<void> _loadDataWithRetry() async {
    print('\n📋 ===== LOADING ALL DATA =====');
    
    final studentController = context.read<StudentController>();
    final financialController = context.read<FinancialController>();
    final scheduleController = context.read<ScheduleController>();
    final courseController = context.read<CourseController>();
    final eventController = context.read<EventController>();

    print('\n1️⃣ Loading Student Profile...');
    await _retryLoad(() => studentController.loadProfile(), 'Student Profile');
    
    print('\n2️⃣ Loading Financial Summary...');
    await _retryLoad(() => financialController.loadSummary(), 'Financial Summary');
    
    print('\n3️⃣ Loading Bills...');
    await _retryLoad(() => financialController.loadBills(), 'Bills');
    
    print('\n4️⃣ Loading Schedule...');
    await _retryLoad(() => scheduleController.loadMySchedule(), 'Schedule');
    
    print('\n5️⃣ Loading Courses...');
    await _retryLoad(() => courseController.loadStudentCourses(), 'Courses');
    
    print('\n6️⃣ Loading Events...');
    await _retryLoad(() => eventController.loadEvents(), 'Events');
    
    print('\n✅ ===== ALL DATA LOADED =====\n');
  }

  /// Retry loading data with 3 attempts, 2 second delay between retries
  Future<void> _retryLoad(Future<void> Function() loadFunction, String dataName) async {
    int attempts = 0;
    const maxAttempts = 3;
    const retryDelay = Duration(seconds: 2);

    print('🔄 Starting retry loop for: $dataName');

    while (attempts < maxAttempts) {
      try {
        print('  ⏳ Attempt ${attempts + 1}/$maxAttempts for $dataName');
        await loadFunction();
        // Success - exit retry loop
        if (attempts > 0) {
          print('  ✅ $dataName loaded successfully after ${attempts + 1} attempts');
        } else {
          print('  ✅ $dataName loaded successfully on first attempt');
        }
        return;
      } catch (e) {
        attempts++;
        print('  ❌ Attempt $attempts failed: $e');
        
        // Check if it's an authentication error
        if (e.toString().contains('Unauthorized')) {
          print('  🔐 AUTH ERROR DETECTED: $e');
          print('  🔐 Redirecting to login page...');
          // Navigate to login page
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }
        
        if (attempts < maxAttempts) {
          print('  ⏸️ Waiting ${retryDelay.inSeconds}s before retry...');
          await Future.delayed(retryDelay);
        } else {
          print('  ❌ FINAL FAILURE after $maxAttempts attempts: $e');
        }
      }
    }
  }

  /// Test notification functionality
  void _testNotification() async {
    try {
      // Test Firebase Messaging Service
      final messagingService = FirebaseService.instance.messaging;
      
      if (messagingService != null) {
        // Test if messaging service is available
        final token = await messagingService.getToken();
        debugPrint('FCM Token: $token');
        
        // Test local notification
        await messagingService.showTestNotification(
          '💬 New Chat Message',
          'Dr. Ahmed Ben Ali: The assignment deadline has been extended to next week.',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Test notification sent! Check your notification panel.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Firebase Messaging not available on this platform');
      }
    } catch (e) {
      debugPrint('❌ Notification test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Notification failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Bottom navigation bar items
  final List<BottomBarItem> bottomBarItems = [
    const BottomBarItem(
      inActiveItem: Icon(Icons.home_filled, color: Colors.grey),
      activeItem: Icon(Icons.home_filled, color: Colors.white),
      itemLabel: 'Home',
    ),
    const BottomBarItem(
      inActiveItem: Icon(Icons.search, color: Colors.grey),
      activeItem: Icon(Icons.search, color: Colors.white),
      itemLabel: 'Search',
    ),
    const BottomBarItem(
      inActiveItem: Icon(Icons.calendar_month_rounded, color: Colors.grey),
      activeItem: Icon(Icons.calendar_month_rounded, color: Colors.white),
      itemLabel: 'Schedule',
    ),
    const BottomBarItem(
      inActiveItem: Icon(Icons.notifications, color: Colors.grey),
      activeItem: Icon(Icons.notifications, color: Colors.white),
      itemLabel: 'Notifications',
    ),
    const BottomBarItem(
      inActiveItem: Icon(Icons.chat_bubble, color: Colors.grey),
      activeItem: Icon(Icons.chat_bubble, color: Colors.white),
      itemLabel: 'Chat',
    ),
  ];

  // ========================================================================
  // BUILD METHOD
  // ========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================================
      // SECTION 1: APP BAR - Header with User Info and Notifications
      // ========================================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.red[900],
          centerTitle: true,
          automaticallyImplyLeading: false,

          // User profile section (left side) - Dynamic
          title: Consumer<StudentController>(
            builder: (context, studentController, child) {
              final student = studentController.student;
              final isLoading = student == null;
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePageDynamic()),
                  );
                },
                child: Row(
                  children: [
                    // User avatar - Shimmer while loading
                    isLoading
                        ? const ShimmerCircle(diameter: 45)
                        : CircleAvatar(
                            radius: 22.5,
                            backgroundColor: Colors.white,
                            child: student.name.isNotEmpty
                                ? Text(
                                    student.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Colors.red[900],
                                    size: 24,
                                  ),
                          ),
                    const SizedBox(width: 10),

                    // User name and role - Shimmer while loading
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                            ? const ShimmerText(width: 120, height: 16)
                            : Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                        const SizedBox(height: 4),
                        isLoading
                            ? const ShimmerText(width: 60, height: 14)
                            : Text(
                                "Student",
                                style: TextStyle(
                                  fontFamily: "SourceSerifLight",
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[350],
                                ),
                              ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),

          // Notification button (right side)
          actions: [
            Container(
              margin: const EdgeInsets.all(10),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()),
                  );
                },
                icon: const Icon(Icons.notifications_active),
                color: Colors.white,
              ),
            )
          ],
        ),
      ),

      // ========================================================================
      // SECTION 2: BODY - Main Content Area
      // ========================================================================
      body: RefreshIndicator(
        onRefresh: _loadDataWithRetry,
        color: Colors.red[900],
        backgroundColor: Colors.white,
        child: ListView(
          children: [
          // --------------------------------------------------------------------
          // BLOCK 2.1: Curved Background Header
          // --------------------------------------------------------------------
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.09,
            decoration: BoxDecoration(
              color: Colors.red[900],
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(
                  MediaQuery.of(context).size.width,
                  300.0,
                ),
              ),
            ),
          ),

          // --------------------------------------------------------------------
          // BLOCK 2.2: Financial Summary Card - Dynamic
          // --------------------------------------------------------------------
          Transform.translate(
            offset: Offset(0, -MediaQuery.of(context).size.height * 0.09),
            child: Consumer2<FinancialController, StudentController>(
              builder: (context, financialController, studentController, child) {
                final summary = financialController.summary;
                final student = studentController.student;
                final isLoading = summary == null || student == null;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(blurRadius: 5.0, color: Colors.grey)
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30,
                        top: 10,
                        bottom: 10,
                        right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left side: Tuition fees - Dynamic
                        Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PaymentPage()),
                              );
                            },
                            icon: const Icon(
                                Icons.account_balance_wallet_rounded),
                            color: Colors.red,
                            iconSize: 20,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                " Outstanding",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                              isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 8, top: 2),
                                      child: ShimmerText(width: 80, height: 13),
                                    )
                                  : Text(
                                      " TND ${summary.totalOutstanding.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontFamily: "Rowdies",
                                  fontWeight: FontWeight.w200,
                                  fontSize: 13,
                                  color: Colors.red[300],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),

                        // Right side: Current credits - Dynamic
                        Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const GradesPageDynamic()),
                              );
                            },
                            icon: const Icon(Icons.analytics_rounded),
                            color: Colors.red,
                            iconSize: 20,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                " Current Credits",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                              isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 8, top: 2),
                                      child: ShimmerText(width: 50, height: 13),
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          " ${student.creditsTaken} ",
                                    style: TextStyle(
                                      fontFamily: "Rowdies",
                                      fontWeight: FontWeight.w200,
                                      fontSize: 13,
                                      color: Colors.red[300],
                                    ),
                                  ),
                                  Text(
                                    "/ ${student.totalCredits}",
                                    style: TextStyle(
                                      fontFamily: "Rowdies",
                                      fontWeight: FontWeight.w200,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Transform.translate(
              offset: Offset(0, -MediaQuery.of(context).size.height * 0.055),
              child: Column(
                  children: [

          // --------------------------------------------------------------------
          // BLOCK 2.3: Current/Next Class Card - Dynamic from Schedule
          // --------------------------------------------------------------------
          Consumer<ScheduleController>(
            builder: (context, scheduleController, child) {
              final schedule = scheduleController.schedule;
              final isLoading = schedule == null;
              final now = DateTime.now();
              
              // Find current or next upcoming session from today's schedule
              ScheduleSession? currentSession;
              ScheduleSession? nextSession;
              if (schedule != null) {
                // Get day name
                final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                final todayName = dayNames[now.weekday];
                final todaySessions = schedule.schedule[todayName] ?? [];
                
                // Find current session (if now is within its time) or next upcoming
                for (var session in todaySessions) {
                  final startTime = DateTime(now.year, now.month, now.day, 
                    int.parse(session.startTime.split(':')[0]),
                    int.parse(session.startTime.split(':')[1]));
                  final endTime = DateTime(now.year, now.month, now.day, 
                    int.parse(session.endTime.split(':')[0]),
                    int.parse(session.endTime.split(':')[1]));
                  
                  if (now.isAfter(startTime) && now.isBefore(endTime)) {
                    currentSession = session;
                  } else if (now.isBefore(startTime)) {
                    if (nextSession == null) {
                      nextSession = session;
                    } else {
                      final nextStart = DateTime(now.year, now.month, now.day, 
                        int.parse(nextSession.startTime.split(':')[0]),
                        int.parse(nextSession.startTime.split(':')[1]));
                      if (startTime.isBefore(nextStart)) {
                        nextSession = session;
                      }
                    }
                  }
                }
              }
              
              final displaySession = currentSession ?? nextSession;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    _showLectureDetails(displaySession);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[700]!, Colors.red[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSession != null ? "Current Class" : "Next Class",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              isLoading
                                  ? const ShimmerText(width: 150, height: 16)
                                  : Text(
                                      displaySession?.courseName ?? "No class scheduled for today",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              if (!isLoading && displaySession != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${displaySession.startTime} - ${displaySession.endTime}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.business,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Room ${displaySession.room ?? 'TBA'}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------------------------
          // BLOCK 2.4: Quick Access Icon Grid
          // --------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Year Schedule, Clubs, Grades, Schedule
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildQuickAccessButton(
                      icon: Icons.calendar_view_month_rounded,
                      label: "Year Plan",
                      iconSize: 32,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const YearSchedulePage()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.badge_rounded,
                      label: "Clubs",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ClubsPage()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.assignment,
                      label: "Grades",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GradesPageDynamic()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.text_snippet_rounded,
                      label: "Schedule",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SchedulePageDynamic()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Row 2: Absences, Bills, Activities, Materials
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildQuickAccessButton(
                      icon: Icons.event_busy_rounded,
                      label: "Absences",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AbsencesPageDynamic()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.feed_rounded,
                      label: "Bills",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BillsPageEnhanced()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.task_rounded,
                      label: "Activities",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ActivitiesPage()),
                        );
                      },
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.chat_bubble_rounded,
                      label: "Materials",
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchPage()),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --------------------------------------------------------------------
          // BLOCK 2.5: Information & News Section Header
          // --------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Information & News",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewsPage()),
                    );
                  },
                  child: const Text(
                    "More",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --------------------------------------------------------------------
          // BLOCK 2.6: Events Carousel Slider (Last 10 Events from API)
          // --------------------------------------------------------------------
          Consumer<EventController>(
            builder: (context, eventController, child) {
              final events = eventController.events.take(10).toList();
              final isLoading = events.isEmpty && eventController.errorMessage == null;
              
              if (isLoading) {
                // Show shimmer placeholder while loading
                return Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }
              
              if (events.isEmpty) {
                // Fallback to static images when no events available
                return CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    initialPage: 0,
                    autoPlay: true,
                    reverse: false,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    scrollDirection: Axis.horizontal,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(milliseconds: 2000),
                    onPageChanged: (index, reason) => {}, // Remove unused index tracking
                  ),
                  items: imageList.asMap().entries.map((entry) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewsPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        child: Image.asset(
                          entry.value,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                  )).toList(),
                );
              }

              // Display last 10 events dynamically
              return CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  initialPage: 0,
                  autoPlay: true,
                  reverse: false,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: events.length > 1,
                  scrollDirection: Axis.horizontal,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 2000),
                  onPageChanged: (index, reason) => {}, // Remove unused index tracking
                ),
                items: events.map((event) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewsPage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red[700]!, Colors.red[900]!],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Event image or placeholder
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: event.imageUrl != null
                                ? Image.network(
                                    event.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stack) => _buildEventPlaceholder(event),
                                  )
                                : _buildEventPlaceholder(event),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Event info
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.location ?? 'Location not specified',
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------------------------
          // BLOCK 2.7: Academic Alerts & Quick Stats (HIDDEN - No API yet)
          // TODO: Implement activities/deadlines API and controller
          // --------------------------------------------------------------------
          // Commented out static content - will be implemented when API is ready
          
          // const SizedBox(height: 24),

          // --------------------------------------------------------------------
          // BLOCK 2.8: Current Semester Courses Card - Dynamic
          // --------------------------------------------------------------------
          Consumer<CourseController>(
            builder: (context, courseController, child) {
              final courses = courseController.courses.take(5).toList();
              final totalCourses = courseController.courses.length;
              final totalCredits = courseController.courses.fold<int>(0, (sum, course) => sum + course.credits);
              final isLoading = courses.isEmpty && courseController.errorMessage == null;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Title and View All Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Current Semester Courses",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoursesPageDynamic(),
                              ),
                            );
                          },
                          child: const Text("View All"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Semester Info Header - Dynamic
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[700]!, Colors.red[900]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${_getCurrentSemester()} - Current Semester",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$totalCourses Courses • $totalCredits Credits",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: const Text(
                              "Active",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Courses List - Dynamic (Show max 5)
                    if (isLoading && totalCourses == 0)
                      // Show 3 shimmer placeholders while loading
                      ...List.generate(3, (index) => Column(
                        children: [
                          if (index > 0) const SizedBox(height: 10),
                          _buildCourseShimmer(),
                        ],
                      ))
                    else if (courses.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "No courses enrolled",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...courses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final course = entry.value;
                        final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.indigo];
                        
                        return Column(
                          children: [
                            if (index > 0) const SizedBox(height: 10),
                            _buildCourseItem(
                              code: course.courseCode,
                              name: course.name,
                              credits: course.credits,
                              color: colors[index % colors.length],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CoursesPageDynamic(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    
                    const SizedBox(height: 16),

                    // Summary Stats - Dynamic
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.school,
                            value: totalCourses.toString(),
                            label: "Courses",
                            color: Colors.blue,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                            icon: Icons.credit_score,
                            value: totalCredits.toString(),
                            label: "Credits",
                            color: Colors.green,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                            icon: Icons.calendar_today,
                            value: _getCurrentSemesterWeeks().toString(),
                            label: "Weeks",
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ====================================================================
          // BLOCK 2.9: Firebase Test Button (Development Only)
          // ====================================================================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/firebase-test');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bug_report, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Test Firebase Connection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Test Notification Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: _testNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.notifications_active),
              label: const Text('🔔 Test Chat Notification'),
            ),
          ),

          const SizedBox(height: 20),
        ]))
        ],
      ),
      ),
      extendBody: false, //make  true  for transparency
      // ========================================================================
      // SECTION 3: BOTTOM NAVIGATION BAR
      // ========================================================================
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        bottomBarItems: bottomBarItems,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SchedulePageDynamic()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatListPage()),
            );
          }
        },
        kIconSize: 24.0,
        kBottomRadius: 28.0,
        showLabel: true,
        itemLabelStyle: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
        notchColor: Colors.red[900]!,
        color: Colors.white,
        showShadow: true,
        durationInMilliSeconds: 300,
        elevation: 30,
        bottomBarHeight: 65,
        removeMargins: false,
        bottomBarWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    double iconSize = 30,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.width * 0.15,
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: iconSize,
            color: Colors.red[900],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Rowdies",
            fontWeight: FontWeight.w200,
            color: Colors.grey,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  void _showLectureDetails(ScheduleSession? session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (session == null) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No Upcoming Classes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Check your schedule for future classes",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Course Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[700]!, Colors.red[900]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.book,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.courseName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${session.courseCode} - ${session.instructor ?? 'Instructor TBA'}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Lecture Info Cards
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: "Time",
                      content: "${session.dayOfWeek}, ${session.startTime} - ${session.endTime}",
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.business,
                      title: "Building",
                      content: "Main Campus",
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.room,
                      title: "Room",
                      content: "Room ${session.room ?? 'TBA'}",
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.topic,
                      title: "Session Type",
                      content: session.sessionType ?? "Lecture",
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Section
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.description,
                            label: "Materials",
                            color: Colors.purple,
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Opening course materials...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.chat_bubble,
                            label: "Chat",
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Opening course chat...')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.calendar_today,
                            label: "Schedule",
                            color: Colors.green,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SchedulePageDynamic()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.assignment,
                            label: "Assignments",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ActivitiesPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Additional Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Don't forget to bring your laptop for practical exercises",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem({
    required String code,
    required String name,
    required int credits,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  code.substring(2), // Show just the number (e.g., "301")
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$credits CR",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Helper to get current semester name
  String _getCurrentSemester() {
    final now = DateTime.now();
    // Fall: Sept-Dec, Spring: Jan-May, Summer: Jun-Aug
    if (now.month >= 9 && now.month <= 12) {
      return "Fall ${now.year}";
    } else if (now.month >= 1 && now.month <= 5) {
      return "Spring ${now.year}";
    } else {
      return "Summer ${now.year}";
    }
  }

  /// Helper to calculate weeks elapsed in current semester
  int _getCurrentSemesterWeeks() {
    final now = DateTime.now();
    DateTime semesterStart;
    
    // Determine semester start date
    if (now.month >= 9 && now.month <= 12) {
      // Fall: starts September 1st
      semesterStart = DateTime(now.year, 9, 1);
    } else if (now.month >= 1 && now.month <= 5) {
      // Spring: starts February 1st
      semesterStart = DateTime(now.year, 2, 1);
    } else {
      // Summer: starts June 1st
      semesterStart = DateTime(now.year, 6, 1);
    }
    
    // Calculate weeks elapsed
    final difference = now.difference(semesterStart);
    return (difference.inDays / 7).ceil();
  }

  /// Builds a placeholder widget for events without images
  Widget _buildEventPlaceholder(Event event) {
    // Choose icon based on event category
    IconData icon = event.category.toLowerCase().contains('academic')
        ? Icons.school
        : event.category.toLowerCase().contains('sport')
            ? Icons.sports
            : event.category.toLowerCase().contains('cultural')
                ? Icons.palette
                : Icons.event;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[700]!, Colors.red[900]!],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Builds shimmer skeleton for course items while loading
  Widget _buildCourseShimmer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 50, height: 50, borderRadius: BorderRadius.circular(10)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerText(width: 60, height: 12),
                SizedBox(height: 6),
                ShimmerText(width: double.infinity, height: 14),
              ],
            ),
          ),
          ShimmerBox(width: 50, height: 30, borderRadius: BorderRadius.circular(20)),
        ],
      ),
    );
  }
}
