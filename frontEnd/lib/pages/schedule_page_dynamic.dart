// ============================================================================
// SCHEDULE PAGE - Dynamic API Integration
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/controllers/schedule_controller.dart';
import '../core/models/schedule.dart';

class SchedulePageDynamic extends StatefulWidget {
  const SchedulePageDynamic({super.key});

  @override
  State<SchedulePageDynamic> createState() => _SchedulePageDynamicState();
}

class _SchedulePageDynamicState extends State<SchedulePageDynamic> {
  String _selectedDay = 'Monday';
  bool _isWeeklyView = false;
  String _currentDay = 'Monday';
  final List<Map<String, String>> _allDays = [
    {'key': 'Monday', 'label': 'Mon'},
    {'key': 'Tuesday', 'label': 'Tue'},
    {'key': 'Wednesday', 'label': 'Wed'},
    {'key': 'Thursday', 'label': 'Thu'},
    {'key': 'Friday', 'label': 'Fri'},
    {'key': 'Saturday', 'label': 'Sat'},
  ];

  List<Map<String, String>> get _days {
    final currentDayIndex = _allDays.indexWhere((day) => day['key'] == _currentDay);
    if (currentDayIndex == -1) return _allDays;
    return [
      ..._allDays.sublist(currentDayIndex),
      ..._allDays.sublist(0, currentDayIndex),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _setInitialDay();
  }

  void _setInitialDay() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    String dayName;
    switch (weekday) {
      case 1:
        dayName = 'Monday';
        break;
      case 2:
        dayName = 'Tuesday';
        break;
      case 3:
        dayName = 'Wednesday';
        break;
      case 4:
        dayName = 'Thursday';
        break;
      case 5:
        dayName = 'Friday';
        break;
      case 6:
        dayName = 'Saturday';
        break;
      case 7:
      default:
        dayName = 'Monday'; // Default to Monday for Sunday
        break;
    }
    _currentDay = dayName;
    setState(() {
      _selectedDay = dayName;
    });
  }

  @override
  void dispose() {
    // Reset orientation when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _loadData() {
    debugPrint('SchedulePageDynamic: _loadData called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('SchedulePageDynamic: addPostFrameCallback executing');
      context.read<ScheduleController>().loadMySchedule();
    });
  }

  void _toggleView() {
    setState(() {
      _isWeeklyView = !_isWeeklyView;
      if (_isWeeklyView) {
        // Force landscape for weekly view
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        // Allow all orientations for daily view
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Schedule",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(_isWeeklyView ? Icons.view_day : Icons.calendar_view_week, color: Colors.white),
            onPressed: _toggleView,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<ScheduleController>(
        builder: (context, controller, child) {
          debugPrint('SchedulePageDynamic: Consumer builder called, state: ${controller.state}');
          debugPrint('SchedulePageDynamic: Schedule data: ${controller.schedule}');
          if (controller.schedule != null) {
            debugPrint('SchedulePageDynamic: Schedule days: ${controller.schedule!.schedule.keys}');
            controller.schedule!.schedule.forEach((day, sessions) {
              debugPrint('SchedulePageDynamic: $day has ${sessions.length} sessions');
              sessions.forEach((session) {
                debugPrint('SchedulePageDynamic: Session - ${session.courseName} at ${session.startTime}-${session.endTime} in ${session.room}');
              });
            });
          }

          // Loading state
          if (controller.state == ScheduleLoadingState.loading) {
            debugPrint('SchedulePageDynamic: Showing loading state');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Loading schedule...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Error state
          if (controller.state == ScheduleLoadingState.error) {
            debugPrint('SchedulePageDynamic: Showing error state, error: ${controller.errorMessage}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Error loading schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(controller.errorMessage ?? 'Unknown error', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          // No data
          final schedule = controller.schedule;
          if (schedule == null) {
            debugPrint('SchedulePageDynamic: Schedule is null, showing no schedule message');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No schedule available', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          debugPrint('SchedulePageDynamic: Building schedule UI for selected day: $_selectedDay');
          return _isWeeklyView ? _buildWeeklyView(schedule) : _buildDailyView(schedule);
        },
      ),
    );
  }

  Widget _buildDailyView(WeeklySchedule schedule) {
    return Column(
      children: [
        // Week Day Selector
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final day = _days[index];
              final isSelected = day['key'] == _selectedDay;
              debugPrint('SchedulePageDynamic: Building day selector for ${day['key']}, selected: $isSelected');
              return GestureDetector(
                onTap: () {
                  debugPrint('SchedulePageDynamic: Day tapped: ${day['key']}');
                  setState(() {
                    _selectedDay = day['key']!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red[900] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day['label']!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Schedule Timeline
        Expanded(
          child: _buildScheduleList(schedule),
        ),
      ],
    );
  }

  Widget _buildWeeklyView(WeeklySchedule schedule) {
    // Force landscape orientation for weekly view
    if (_isWeeklyView) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 2.0,
      scaleEnabled: true,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with time slots
                Row(
                  children: [
                    // Day column header
                    Container(
                      width: 80,
                      height: 50,
                      alignment: Alignment.center,
                      child: const Text(
                        'Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    // Time slot headers - filter out last 2 columns if completely empty
                    ..._getTimeSlots().entries.where((entry) {
                      final slotNumber = entry.key;
                      final startTime = entry.value['start']!;
                      
                      // Check if this time slot has any sessions across all days
                      final hasAnySessions = _days.any((day) {
                        final dayKey = day['key']!;
                        final daySessions = schedule.getSessionsForDay(dayKey);
                        return daySessions.any((s) => s.startTime == startTime);
                      });
                      
                      // Hide last 2 columns (slots 6 and 7) if they're empty
                      if (slotNumber >= 6 && !hasAnySessions) {
                        return false;
                      }
                      return true;
                    }).map((entry) {
                      final slotData = entry.value;
                      final startTime = slotData['start']!;
                      final endTime = slotData['end']!;

                      // Check if this time slot has any sessions across all days
                      final hasAnySessions = _days.any((day) {
                        final dayKey = day['key']!;
                        final daySessions = schedule.getSessionsForDay(dayKey);
                        return daySessions.any((s) => s.startTime == startTime);
                      });

                      final columnWidth = hasAnySessions ? 120.0 : 60.0;

                      return Container(
                        width: columnWidth,
                        height: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$startTime\n$endTime',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: hasAnySessions ? 12 : 10,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ],
                ),
                // Day rows
                ..._days.map((day) {
                  final dayKey = day['key']!;
                  final daySessions = schedule.getSessionsForDay(dayKey);

                  return Row(
                    children: [
                      // Day column
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.grey[100],
                        ),
                        child: Text(
                          day['label']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Time slot columns - filter out last 2 columns if completely empty
                      ..._getTimeSlots().entries.where((entry) {
                        final slotNumber = entry.key;
                        final startTime = entry.value['start']!;
                        
                        // Check if this time slot has any sessions across all days
                        final hasAnySessions = _days.any((day) {
                          final dayKey = day['key']!;
                          final daySessions = schedule.getSessionsForDay(dayKey);
                          return daySessions.any((s) => s.startTime == startTime);
                        });
                        
                        // Hide last 2 columns (slots 6 and 7) if they're empty
                        if (slotNumber >= 6 && !hasAnySessions) {
                          return false;
                        }
                        return true;
                      }).map((entry) {
                        final slotData = entry.value;
                        final startTime = slotData['start']!;

                        // Check if this time slot has any sessions across all days
                        final hasAnySessions = _days.any((day) {
                          final dayKey = day['key']!;
                          final daySessions = schedule.getSessionsForDay(dayKey);
                          return daySessions.any((s) => s.startTime == startTime);
                        });

                        final columnWidth = hasAnySessions ? 120.0 : 60.0;
                        final session = daySessions.where((s) => s.startTime == startTime).isNotEmpty
                            ? daySessions.firstWhere((s) => s.startTime == startTime)
                            : null;

                        return GestureDetector(
                          onTap: session != null ? () => _showLectureDetails(session) : null,
                          child: Container(
                            width: columnWidth,
                            height: 80,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              color: session != null ? Colors.blue[50] : Colors.white,
                            ),
                            child: session != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.courseCode,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        session.courseName,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        session.room ?? 'TBA',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.blue,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Text(
                                      'Free',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleList(WeeklySchedule schedule) {
    final daySessions = schedule.getSessionsForDay(_selectedDay);
    final timeSlots = _getTimeSlots();
    debugPrint('SchedulePageDynamic: _buildScheduleList called for $_selectedDay, sessions count: ${daySessions.length}, time slots: ${timeSlots.length}');

    // Create a map of startTime to session for quick lookup
    final sessionMap = {for (var session in daySessions) session.startTime: session};

    // Filter out empty slots after 5:00 PM (17:00)
    final filteredSlots = <int, Map<String, String>>{};
    timeSlots.forEach((slotNumber, slotData) {
      final startTime = slotData['start']!;
      final session = sessionMap[startTime];
      
      // Parse hour from time (e.g., "17:15" -> 17)
      final hour = int.parse(startTime.split(':')[0]);
      
      // Include slot if: it has a session OR it's before 5:00 PM
      if (session != null || hour < 17) {
        filteredSlots[slotNumber] = slotData;
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredSlots.length,
      itemBuilder: (context, index) {
        final entry = filteredSlots.entries.elementAt(index);
        final slotNumber = entry.key;
        final slotData = entry.value;
        final startTime = slotData['start']!;
        final endTime = slotData['end']!;
        final session = sessionMap[startTime];

        debugPrint('SchedulePageDynamic: Building time slot $slotNumber ($startTime-$endTime): ${session?.courseName ?? 'Empty'}');
        return _buildTimeSlot(session, slotNumber, startTime, endTime, index);
      },
    );
  }

  Map<int, Map<String, String>> _getTimeSlots() {
    return {
      1: {'start': '08:30', 'end': '10:00'},
      2: {'start': '10:15', 'end': '11:45'},
      3: {'start': '12:00', 'end': '13:30'},
      4: {'start': '13:45', 'end': '15:15'},
      5: {'start': '15:30', 'end': '17:00'},
      6: {'start': '17:15', 'end': '18:45'},
      7: {'start': '19:00', 'end': '20:30'},
    };
  }

  Widget _buildTimeSlot(ScheduleSession? session, int slotNumber, String startTime, String endTime, int index) {
    if (session == null) {
      // Simple display for empty slots
      return Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Free',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    // Full display for occupied slots
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.indigo, Colors.pink, Colors.cyan];
    final color = colors[index % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.courseCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$startTime - $endTime',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.room ?? 'Room TBA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showLectureDetails(session),
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  void _showLectureDetails(ScheduleSession session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${session.courseCode} - ${session.courseName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time: ${session.startTime} - ${session.endTime}'),
              const SizedBox(height: 8),
              Text('Room: ${session.room ?? 'TBA'}'),
              const SizedBox(height: 8),
              Text('Instructor: ${session.instructor ?? 'TBA'}'),
              const SizedBox(height: 8),
              Text('Type: ${session.sessionType ?? 'Class'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
