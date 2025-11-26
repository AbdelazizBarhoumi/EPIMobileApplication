// ============================================================================
// YEAR SCHEDULE PAGE - Dynamic Academic Calendar (Enhanced)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/controllers/academic_calendar_controller.dart';
import '../core/models/academic_calendar.dart';

class YearSchedulePage extends StatefulWidget {
  const YearSchedulePage({super.key});

  @override
  State<YearSchedulePage> createState() => _YearSchedulePageState();
}

class _YearSchedulePageState extends State<YearSchedulePage> with TickerProviderStateMixin {
  int _selectedYear = DateTime.now().year;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🎓 YearSchedulePage: ===== INITIALIZING YEAR SCHEDULE PAGE =====');
    debugPrint('🎓 YearSchedulePage: Current year set to: $_selectedYear');
    debugPrint('🎓 YearSchedulePage: Device screen size: ${WidgetsBinding.instance.window.physicalSize}');
    debugPrint('🎓 YearSchedulePage: Platform brightness: ${WidgetsBinding.instance.window.platformBrightness}');

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadCalendars();
    _fadeController.forward();
  }

  @override
  void dispose() {
    debugPrint('🎓 YearSchedulePage: ===== DISPOSING YEAR SCHEDULE PAGE =====');
    _fadeController.dispose();
    super.dispose();
  }

  void _loadCalendars() {
    debugPrint('🎓 YearSchedulePage: ===== LOADING CALENDARS =====');
    debugPrint('🎓 YearSchedulePage: Target year: $_selectedYear');
    debugPrint('🎓 YearSchedulePage: Current timestamp: ${DateTime.now()}');

    final controller = context.read<AcademicCalendarController>();
    debugPrint('🎓 YearSchedulePage: Controller state before load: ${controller.state}');
    debugPrint('🎓 YearSchedulePage: Current calendar count: ${controller.calendars.length}');

    controller.loadCalendarsByYear(_selectedYear);

    debugPrint('🎓 YearSchedulePage: Load request sent to controller');
  }

  void _onYearChanged(int newYear) {
    debugPrint('🎓 YearSchedulePage: ===== YEAR CHANGED =====');
    debugPrint('🎓 YearSchedulePage: Previous year: $_selectedYear');
    debugPrint('🎓 YearSchedulePage: New year: $newYear');
    debugPrint('🎓 YearSchedulePage: Year difference: ${newYear - _selectedYear}');

    setState(() {
      _selectedYear = newYear;
      debugPrint('🎓 YearSchedulePage: State updated with new year');
    });

    _loadCalendars();
  }

  void _onRefreshPressed() {
    debugPrint('🎓 YearSchedulePage: ===== MANUAL REFRESH TRIGGERED =====');
    debugPrint('🎓 YearSchedulePage: Refresh timestamp: ${DateTime.now()}');
    _loadCalendars();
  }

  void _onCalendarCardTapped(AcademicCalendar calendar) {
    debugPrint('🎓 YearSchedulePage: ===== CALENDAR CARD TAPPED =====');
    debugPrint('🎓 YearSchedulePage: Calendar ID: ${calendar.id}');
    debugPrint('🎓 YearSchedulePage: Calendar name: ${calendar.name}');
    debugPrint('🎓 YearSchedulePage: Calendar status: ${calendar.status}');
    debugPrint('🎓 YearSchedulePage: Calendar season: ${calendar.season}');
    debugPrint('🎓 YearSchedulePage: Start date: ${calendar.startDate}');
    debugPrint('🎓 YearSchedulePage: End date: ${calendar.endDate}');
    debugPrint('🎓 YearSchedulePage: Duration: ${calendar.durationInWeeks} weeks');
    debugPrint('🎓 YearSchedulePage: Planned credits: ${calendar.plannedCredits}');
    debugPrint('🎓 YearSchedulePage: Important dates count: ${calendar.importantDates?.length ?? 0}');

    _showCalendarDetails(calendar);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎓 YearSchedulePage: ===== BUILDING WIDGET =====');
    debugPrint('🎓 YearSchedulePage: Build timestamp: ${DateTime.now()}');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB71C1C), // Dark red
              Color(0xFFD32F2F), // Medium red
              Color(0xFFFFEBEE), // Light pink
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<AcademicCalendarController>(
              builder: (context, controller, child) {
                debugPrint('🎓 YearSchedulePage: Consumer rebuild triggered');
                debugPrint('🎓 YearSchedulePage: Controller state: ${controller.state}');
                debugPrint('🎓 YearSchedulePage: Calendar count: ${controller.calendars.length}');
                debugPrint('🎓 YearSchedulePage: Error message: ${controller.errorMessage ?? 'None'}');

                return _buildContent(controller);
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    debugPrint('🎓 YearSchedulePage: Building app bar');

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB71C1C),
              Color(0xFFD32F2F),
            ],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          debugPrint('🎓 YearSchedulePage: Back button pressed');
          Navigator.pop(context);
        },
        tooltip: 'Back to previous page',
      ),
      title: const Text(
        "Academic Calendar",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _onRefreshPressed,
          tooltip: 'Refresh calendar data',
        ),
      ],
    );
  }

  Widget _buildContent(AcademicCalendarController controller) {
    debugPrint('🎓 YearSchedulePage: Building content based on state: ${controller.state}');

    // Loading state
    if (controller.state == AcademicCalendarLoadingState.loading) {
      debugPrint('🎓 YearSchedulePage: Rendering loading state');
      return _buildLoadingState();
    }

    // Error state
    if (controller.state == AcademicCalendarLoadingState.error) {
      debugPrint('🎓 YearSchedulePage: Rendering error state');
      return _buildErrorState(controller);
    }

    final calendars = controller.calendars;
    debugPrint('🎓 YearSchedulePage: Processing ${calendars.length} calendars');

    // Empty state
    if (calendars.isEmpty) {
      debugPrint('🎓 YearSchedulePage: Rendering empty state for year $_selectedYear');
      return _buildEmptyState();
    }

    // Success state
    debugPrint('🎓 YearSchedulePage: Rendering success state with ${calendars.length} calendars');
    return _buildCalendarList(calendars);
  }

  Widget _buildLoadingState() {
    debugPrint('🎓 YearSchedulePage: Building loading state UI');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading Academic Calendar...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fetching data for $_selectedYear',
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
    );
  }

  Widget _buildErrorState(AcademicCalendarController controller) {
    debugPrint('🎓 YearSchedulePage: Building error state UI');
    debugPrint('🎓 YearSchedulePage: Error message: ${controller.errorMessage}');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to Load Calendar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  controller.errorMessage ?? 'An unexpected error occurred while loading the academic calendar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      debugPrint('🎓 YearSchedulePage: Cancel button pressed in error state');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _onRefreshPressed,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    debugPrint('🎓 YearSchedulePage: Building empty state UI');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Academic Calendars Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'There are no academic calendars scheduled for $_selectedYear.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different year or check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarList(List<AcademicCalendar> calendars) {
    debugPrint('🎓 YearSchedulePage: Building calendar list with ${calendars.length} items');

    return Column(
      children: [
        // Year Selector
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB71C1C),
                Color(0xFFD32F2F),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _onYearChanged(_selectedYear - 1),
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                tooltip: 'Previous year',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _onYearChanged(_selectedYear + 1),
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                tooltip: 'Next year',
              ),
            ],
          ),
        ),

        // Calendar List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: calendars.length,
            itemBuilder: (context, index) {
              debugPrint('🎓 YearSchedulePage: Building calendar card at index $index');
              return _buildCalendarCard(calendars[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(AcademicCalendar calendar) {
    debugPrint('🎓 YearSchedulePage: Building enhanced calendar card for ${calendar.name}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _onCalendarCardTapped(calendar),
          borderRadius: BorderRadius.circular(20),
          splashColor: calendar.statusColor.withOpacity(0.1),
          highlightColor: calendar.statusColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: calendar.statusColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        calendar.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            calendar.statusColor,
                            calendar.statusColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: calendar.statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        calendar.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date range with enhanced styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${DateFormat('MMM dd, yyyy').format(calendar.startDate)} - ${DateFormat('MMM dd, yyyy').format(calendar.endDate)}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Duration and credits with enhanced cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.access_time,
                        value: '${calendar.durationInWeeks} weeks',
                        label: 'Duration',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.school,
                        value: '${calendar.plannedCredits}',
                        label: 'Credits',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Season indicator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: calendar.seasonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: calendar.seasonColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      calendar.season,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: calendar.seasonColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCalendarDetails(AcademicCalendar calendar) {
    debugPrint('🎓 YearSchedulePage: ===== SHOWING CALENDAR DETAILS =====');
    debugPrint('🎓 YearSchedulePage: Calendar: ${calendar.name}');
    debugPrint('🎓 YearSchedulePage: Important dates: ${calendar.importantDates?.length ?? 0}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Text(
                    calendar.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('MMMM dd, yyyy').format(calendar.startDate)} - ${DateFormat('MMMM dd, yyyy').format(calendar.endDate)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Status and info cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.info,
                          title: 'Status',
                          value: calendar.status.toUpperCase(),
                          color: calendar.statusColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.access_time,
                          title: 'Duration',
                          value: '${calendar.durationInWeeks} weeks',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.school,
                          title: 'Planned Credits',
                          value: '${calendar.plannedCredits}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          icon: Icons.calendar_view_week,
                          title: 'Season',
                          value: calendar.season,
                          color: calendar.seasonColor,
                        ),
                      ),
                    ],
                  ),

                  // Important dates section
                  if (calendar.importantDates != null && calendar.importantDates!.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red[50]!,
                            Colors.red[25]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event, color: Colors.red[700], size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Important Dates',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ...calendar.importantDates!.map((date) => _buildImportantDateItem(date)).toList(),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 56,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No important dates scheduled',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This academic calendar has no special dates marked.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImportantDateItem(ImportantDate date) {
    debugPrint('🎓 YearSchedulePage: Building important date item: ${date.title}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  date.color,
                  date.color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: date.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              date.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (date.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    date.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: date.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: date.color.withOpacity(0.3),
              ),
            ),
            child: Text(
              DateFormat('MMM dd').format(date.date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: date.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}