// ============================================================================
// ACADEMIC CALENDAR PAGE - Professional Design
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/controllers/academic_calendar_controller.dart';
import '../core/models/academic_calendar.dart';
import '../core/constants/app_colors.dart';

class YearSchedulePage extends StatefulWidget {
  const YearSchedulePage({super.key});

  @override
  State<YearSchedulePage> createState() => _YearSchedulePageState();
}

class _YearSchedulePageState extends State<YearSchedulePage> {
  int _selectedYear = DateTime.now().year;
  bool _hasLoadedInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCalendars();
      });
    }
  }

  void _loadCalendars() {
    context.read<AcademicCalendarController>().loadCalendarsByYear(_selectedYear);
  }

  void _onYearChanged(int newYear) {
    final currentYear = DateTime.now().year;
    if (newYear < currentYear || newYear > currentYear + 1) return;

    setState(() => _selectedYear = newYear);
    _loadCalendars();
  }

  double _calculateDateProgress(ImportantDate date) {
    final now = DateTime.now();
    final hasEndDate = date.endDate != null;
    
    if (!hasEndDate) {
      // For single day events: completed if date has passed
      return date.date.isBefore(now) ? 1.0 : 0.0;
    }
    
    // For date ranges
    if (now.isBefore(date.date)) {
      // Event hasn't started yet
      return 0.0;
    } else if (now.isAfter(date.endDate!)) {
      // Event has ended
      return 1.0;
    } else {
      // Event is in progress
      final totalDays = date.endDate!.difference(date.date).inDays;
      final elapsedDays = now.difference(date.date).inDays;
      return (elapsedDays / totalDays).clamp(0.0, 1.0);
    }
  }

  bool _isDateCurrent(ImportantDate date) {
    final now = DateTime.now();
    final hasEndDate = date.endDate != null;
    
    if (!hasEndDate) {
      // Single day event is current only on that exact day
      return now.year == date.date.year && 
             now.month == date.date.month && 
             now.day == date.date.day;
    }
    
    // Range event is current if today is within the range
    return now.isAfter(date.date.subtract(const Duration(days: 1))) && 
           now.isBefore(date.endDate!.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Academic Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
            onPressed: _loadCalendars,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildYearSelector(isDark),
          Expanded(
            child: Consumer<AcademicCalendarController>(
              builder: (context, controller, _) => _buildContent(controller, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(bool isDark) {
    final currentYear = DateTime.now().year;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _selectedYear > currentYear
                ? () => _onYearChanged(_selectedYear - 1)
                : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: _selectedYear > currentYear
                  ? (isDark ? Colors.white : AppColors.textPrimary)
                  : (isDark ? Colors.white24 : Colors.black26),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_selectedYear',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _selectedYear < currentYear + 1
                ? () => _onYearChanged(_selectedYear + 1)
                : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: _selectedYear < currentYear + 1
                  ? (isDark ? Colors.white : AppColors.textPrimary)
                  : (isDark ? Colors.white24 : Colors.black26),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AcademicCalendarController controller, bool isDark) {
    if (controller.state == AcademicCalendarLoadingState.loading) {
      return _buildLoadingState(isDark);
    }

    if (controller.state == AcademicCalendarLoadingState.error) {
      return _buildErrorState(controller, isDark);
    }

    final calendars = controller.calendars;
    if (calendars.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return _buildCalendarList(calendars, isDark);
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading calendar...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AcademicCalendarController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Calendar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadCalendars,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Calendars Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no academic calendars for $_selectedYear.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarList(List<AcademicCalendar> calendars, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: calendars.length,
      itemBuilder: (context, index) => _buildCalendarCard(calendars[index], isDark),
    );
  }

  Widget _buildCalendarCard(AcademicCalendar calendar, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCalendarDetails(calendar, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calendar.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            calendar.season,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: calendar.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        calendar.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: calendar.statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${DateFormat('MMM dd, yyyy').format(calendar.startDate)} - ${DateFormat('MMM dd, yyyy').format(calendar.endDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetric(
                        icon: Icons.access_time_rounded,
                        label: 'Duration',
                        value: '${calendar.durationInWeeks}w',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetric(
                        icon: Icons.school_rounded,
                        label: 'Credits',
                        value: '${calendar.plannedCredits}',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCalendarDetails(AcademicCalendar calendar, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            calendar.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: calendar.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            calendar.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: calendar.statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${DateFormat('MMMM dd, yyyy').format(calendar.startDate)} - ${DateFormat('MMMM dd, yyyy').format(calendar.endDate)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailMetric(
                            icon: Icons.access_time_rounded,
                            label: 'Duration',
                            value: '${calendar.durationInWeeks} weeks',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailMetric(
                            icon: Icons.school_rounded,
                            label: 'Credits',
                            value: '${calendar.plannedCredits}',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailMetric(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Season',
                      value: calendar.season,
                      isDark: isDark,
                    ),
                    if (calendar.importantDates != null && calendar.importantDates!.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        'Important Dates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...calendar.importantDates!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final date = entry.value;
                        final isFirst = index == 0;
                        final isLast = index == calendar.importantDates!.length - 1;
                        final previousDate = isFirst ? null : calendar.importantDates![index - 1];
                        
                        return _buildDateItem(
                          date: date,
                          isDark: isDark,
                          isFirst: isFirst,
                          isLast: isLast,
                          previousDate: previousDate,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMetric({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem({
    required ImportantDate date,
    required bool isDark,
    required bool isFirst,
    required bool isLast,
    ImportantDate? previousDate,
  }) {
    final hasEndDate = date.endDate != null;
    final progress = _calculateDateProgress(date);
    final isCurrent = _isDateCurrent(date);
    final isCompleted = progress >= 1.0;
    final isUpcoming = progress == 0.0;
    
    // Calculate previous date progress
    final previousProgress = previousDate != null ? _calculateDateProgress(previousDate) : null;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Top connector line - simple color based on previous event completion
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: previousProgress != null && previousProgress >= 1.0
                        ? previousDate!.color
                        : Colors.grey[300]!,
                  ),
                
                // Icon circle with progress indicator
                SizedBox(
                  width: 44,
                  height: 44,
                  child: hasEndDate && !isCompleted && progress > 0
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: date.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Progress indicator
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(date.color),
                                strokeWidth: 3,
                              ),
                            ),
                            // Icon
                            Icon(
                              date.icon,
                              color: date.color,
                              size: 20,
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: isCompleted ? date.color.withOpacity(0.1) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? date.color : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              date.icon,
                              color: isCompleted ? date.color : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ),
                ),
                
                // Bottom connector line - shows progress gradient for current event
                if (!isLast)
                  Expanded(
                    child: hasEndDate && progress > 0 && progress < 1.0
                        ? CustomPaint(
                            painter: _GradientLinePainter(
                              color: date.color,
                              progress: progress,
                              isDark: isDark,
                            ),
                            child: Container(),
                          )
                        : Container(
                            width: 2,
                            color: isCompleted ? date.color : Colors.grey[300]!,
                          ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent 
                      ? AppColors.primary 
                      : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB)),
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          date.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isUpcoming
                                ? (isDark ? Colors.white54 : Colors.grey[600])
                                : (isCompleted || isCurrent 
                                    ? date.color 
                                    : (isDark ? Colors.white70 : AppColors.textPrimary)),
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Date range
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isUpcoming
                            ? (isDark ? Colors.white38 : Colors.grey[400])
                            : (isCompleted || isCurrent 
                                ? date.color 
                                : (isDark ? Colors.white54 : AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasEndDate
                            ? '${DateFormat('MMM dd').format(date.date)} - ${DateFormat('MMM dd, yyyy').format(date.endDate!)}'
                            : DateFormat('MMM dd, yyyy').format(date.date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUpcoming
                              ? (isDark ? Colors.white38 : Colors.grey[400])
                              : (isCompleted || isCurrent 
                                  ? date.color 
                                  : (isDark ? Colors.white60 : AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                  
                  if (hasEndDate) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${date.endDate!.difference(date.date).inDays + 1} days',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                          ),
                        ),
                        if (isCurrent && progress > 0 && progress < 1) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${(progress * 100).toStringAsFixed(0)}% complete',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  
                  if (date.description != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      date.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for gradient line
class _GradientLinePainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isDark;

  _GradientLinePainter({
    required this.color,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    // Draw colored portion (from top to progress point)
    final coloredHeight = size.height * progress;
    paint.color = color;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, coloredHeight),
      paint,
    );

    // Draw gray portion (from progress point to bottom)
    paint.color = Colors.grey[300]!;
    canvas.drawLine(
      Offset(size.width / 2, coloredHeight),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}