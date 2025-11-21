// ============================================================================
// ABSENCES PAGE - Student Attendance Tracking
// ============================================================================
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class AbsencesPage extends StatelessWidget {
  const AbsencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Attendance & Absences'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Card
            InfoCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Total Classes', '48', Colors.blue),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _buildStatColumn('Present', '42', Colors.green),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _buildStatColumn('Absent', '6', Colors.red),
                ],
              ),
            ),

            // Attendance Rate
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.875,
                          minHeight: 20,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '87.5%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Good attendance! Keep it up.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),

            // Course-wise Attendance
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Course-wise Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            _buildCourseAttendance('Data Structures', 'CS301', 12, 10, 2),
            _buildCourseAttendance('Database Management', 'CS302', 12, 11, 1),
            _buildCourseAttendance('Web Development', 'CS303', 12, 11, 1),
            _buildCourseAttendance('Software Engineering', 'CS304', 12, 10, 2),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseAttendance(String courseName, String courseCode, int total, int present, int absent) {
    final percentage = (present / total * 100).toStringAsFixed(0);
    final isLow = (present / total) < 0.75;

    return InfoCard(
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
                    Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      courseCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLow ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLow ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: present / total,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLow ? Colors.red : Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                    'Present: $present',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.cancel, size: 16, color: Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    'Absent: $absent',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

