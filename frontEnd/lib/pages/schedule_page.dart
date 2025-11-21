// ============================================================================
// SCHEDULE PAGE - Class Schedule Display
// ============================================================================
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/course.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String selectedDay = 'Monday';
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    final courses = <Course>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Schedule'),
      body: Column(
        children: [
          // Week Day Selector
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day == selectedDay;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDay = day;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.substring(0, 3),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${10 + index}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : AppColors.grey,
                          ),
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTimeSlot('08:00 - 09:30', 'Web Development', 'Prof. Mohamed Trabelsi', 'C-302', Colors.blue),
                _buildTimeSlot('10:00 - 12:00', 'Data Structures', 'Dr. Ahmed Ben Ali', 'A-201', Colors.purple),
                _buildTimeSlot('14:00 - 15:30', 'Free Time', '', '', Colors.grey, isEmpty: true),
                _buildTimeSlot('15:00 - 17:00', 'Software Engineering', 'Dr. Leila Jebali', 'A-103', Colors.orange),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Export schedule
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('Export', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTimeSlot(String time, String title, String instructor, String room, Color color, {bool isEmpty = false}) {
    return InfoCard(
      margin: const EdgeInsets.only(bottom: 15),
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
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                if (!isEmpty) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: AppColors.grey),
                      const SizedBox(width: 5),
                      Text(
                        instructor,
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.room, size: 14, color: AppColors.grey),
                      const SizedBox(width: 5),
                      Text(
                        room,
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (!isEmpty)
            Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }
}

