// ============================================================================
// SCHEDULE PAGE - Dynamic API Integration
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/controllers/schedule_controller.dart';
import '../core/models/schedule.dart';

class SchedulePageDynamic extends StatefulWidget {
  const SchedulePageDynamic({super.key});

  @override
  State<SchedulePageDynamic> createState() => _SchedulePageDynamicState();
}

class _SchedulePageDynamicState extends State<SchedulePageDynamic> {
  String _selectedDay = 'monday';
  final List<Map<String, String>> _days = [
    {'key': 'monday', 'label': 'Mon'},
    {'key': 'tuesday', 'label': 'Tue'},
    {'key': 'wednesday', 'label': 'Wed'},
    {'key': 'thursday', 'label': 'Thu'},
    {'key': 'friday', 'label': 'Fri'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleController>().loadMySchedule();
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<ScheduleController>(
        builder: (context, controller, child) {
          // Loading state
          if (controller.state == ScheduleLoadingState.loading) {
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
                    return GestureDetector(
                      onTap: () {
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
        },
      ),
    );
  }

  Widget _buildScheduleList(WeeklySchedule schedule) {
    final daySessions = _getDaySchedule(schedule, _selectedDay);

    if (daySessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.free_breakfast, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No classes today', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }

    // Sort sessions by start time
    daySessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: daySessions.length,
      itemBuilder: (context, index) => _buildTimeSlot(daySessions[index], index),
    );
  }

  List<ScheduleSession> _getDaySchedule(WeeklySchedule schedule, String day) {
    return schedule.getSessionsForDay(day);
  }

  Widget _buildTimeSlot(ScheduleSession session, int index) {
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
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${session.startTime} - ${session.endTime}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${session.courseCode} - ${session.courseName}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.instructor ?? 'TBA',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.room, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(session.room ?? 'TBA', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                session.sessionType?.toUpperCase() ?? 'CLASS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
