// ============================================================================
// ABSENCES PAGE - Dynamic API Integration
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/controllers/attendance_controller.dart';
import '../core/models/attendance.dart';

class AbsencesPageDynamic extends StatefulWidget {
  const AbsencesPageDynamic({super.key});

  @override
  State<AbsencesPageDynamic> createState() => _AbsencesPageDynamicState();
}

class _AbsencesPageDynamicState extends State<AbsencesPageDynamic> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AttendanceController>();
      controller.loadAttendance();
      controller.loadSummary();
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
        title: const Text("Attendance & Absences", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<AttendanceController>(
        builder: (context, controller, child) {
          if (controller.state == AttendanceLoadingState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Loading attendance...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          if (controller.state == AttendanceLoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Error loading attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
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

          final summaries = controller.summaries;
          if (summaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No attendance records', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Calculate overall stats
          int totalPresent = summaries.fold(0, (sum, s) => sum + s.presentCount);
          int totalAbsent = summaries.fold(0, (sum, s) => sum + s.absentCount);
          int totalClasses = totalPresent + totalAbsent;
          double attendanceRate = totalClasses > 0 ? (totalPresent / totalClasses) * 100 : 0.0;

          // Debug logging for attendance data
          print('🔍 AbsencesPage: Attendance data loaded:');
          print('🔍 AbsencesPage: Total summaries = ${summaries.length}');
          print('🔍 AbsencesPage: Total classes = $totalClasses');
          print('🔍 AbsencesPage: Total present = $totalPresent');
          print('🔍 AbsencesPage: Total absent = $totalAbsent');
          print('🔍 AbsencesPage: Attendance rate = ${attendanceRate.toStringAsFixed(1)}%');
          
          // Log each course summary
          for (int i = 0; i < summaries.length; i++) {
            final summary = summaries[i];
            print('🔍 AbsencesPage: Course ${i + 1}: ${summary.courseName} (${summary.courseCode})');
            print('🔍 AbsencesPage:   - Total sessions: ${summary.totalSessions}');
            print('🔍 AbsencesPage:   - Present: ${summary.presentCount}');
            print('🔍 AbsencesPage:   - Absent: ${summary.absentCount}');
            print('🔍 AbsencesPage:   - Excused: ${summary.excusedCount}');
            print('🔍 AbsencesPage:   - Late: ${summary.lateCount}');
            print('🔍 AbsencesPage:   - Percentage: ${summary.attendancePercentage.toStringAsFixed(1)}%');
          }
          
          // Log what will be displayed
          print('🔍 AbsencesPage: Display values:');
          print('🔍 AbsencesPage: Overall stats - Classes: $totalClasses, Present: $totalPresent, Absent: $totalAbsent');
          print('🔍 AbsencesPage: Attendance rate display: ${attendanceRate.toStringAsFixed(1)}%');

          return SingleChildScrollView(
            child: Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Classes', '$totalClasses', Colors.blue),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatColumn('Present', '$totalPresent', Colors.green),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatColumn('Absent', '$totalAbsent', Colors.red),
                    ],
                  ),
                ),

                // Attendance Rate
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[900])),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: attendanceRate / 100,
                              minHeight: 20,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(attendanceRate >= 75 ? Colors.green : Colors.orange),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${attendanceRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: attendanceRate >= 75 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        attendanceRate >= 75 ? 'Good attendance! Keep it up.' : 'Warning: Attendance below 75%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Course-wise Attendance
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text('Course-wise Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900])),
                    ],
                  ),
                ),

                ...summaries.map((summary) => _buildCourseAttendance(
                      summary.courseName,
                      summary.courseCode,
                      summary.courseId,
                      summary.totalSessions,
                      summary.presentCount,
                      summary.absentCount,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCourseAttendance(String courseName, String courseCode, String courseId, int total, int present, int absent) {
    double rate = total > 0 ? (present / total) * 100 : 0.0;
    Color rateColor = rate >= 75 ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showCourseAttendanceDetails(courseName, courseCode, courseId, total, present, absent),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(courseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(courseCode, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: rateColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: rateColor),
                      ),
                      child: Text('${rate.toStringAsFixed(0)}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: rateColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAttendanceStat(Icons.check_circle, 'Present', present, Colors.green),
                    ),
                    Expanded(
                      child: _buildAttendanceStat(Icons.cancel, 'Absent', absent, Colors.red),
                    ),
                    Expanded(
                      child: _buildAttendanceStat(Icons.event, 'Total', total, Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('Tap to view details', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCourseAttendanceDetails(String courseName, String courseCode, String courseId, int total, int present, int absent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courseName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900])),
                    Text(courseCode, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 15),
                    // Summary cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard('Total Classes', '$total', Colors.blue, Icons.event),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDetailCard('Present', '$present', Colors.green, Icons.check_circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDetailCard('Absent', '$absent', Colors.red, Icons.cancel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Attendance records list
              Expanded(
                child: FutureBuilder(
                  future: context.read<AttendanceController>().attendanceService.getCourseAttendance(int.parse(courseId)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.red[900]));
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red[900]),
                            const SizedBox(height: 10),
                            Text('Error loading details', style: TextStyle(color: Colors.grey[600])),
                            Text('${snapshot.error}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      );
                    }
                    
                    final records = snapshot.data ?? [];
                    
                    // Log the attendance records from the bottom sheet
                    print('🔍 Bottom Sheet: Course $courseCode attendance records loaded: ${records.length} records');
                    print('🔍 Bottom Sheet: Full records data: $records');
                    for (int i = 0; i < records.length; i++) {
                      final record = records[i];
                      print('🔍 Bottom Sheet: Record ${i + 1} - Date: ${record.date.toString().substring(0, 10)} (${record.day}), Status: ${record.statusDisplay}, Notes: ${record.notes ?? 'None'}');
                    }
                    
                    if (records.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text('No attendance records yet', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _buildAttendanceRecordItem(
                          record.statusDisplay,
                          '${record.date.toString().substring(0, 10)} (${record.day})',
                          record.notes,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecordItem(String status, String date, String? notes) {
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'excused':
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          date,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: notes != null ? Text(notes, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            status.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceStat(IconData icon, String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          children: [
            Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}
