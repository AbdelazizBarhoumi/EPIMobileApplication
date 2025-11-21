// ============================================================================
// YEAR SCHEDULE PAGE - Annual Academic Calendar
// ============================================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearSchedulePage extends StatefulWidget {
  const YearSchedulePage({super.key});

  @override
  State<YearSchedulePage> createState() => _YearSchedulePageState();
}

class _YearSchedulePageState extends State<YearSchedulePage> {
  int _selectedSemester = 0; // 0 = Fall, 1 = Spring, 2 = Summer

  final List<Map<String, dynamic>> _semesters = [
    {
      'name': 'Fall 2024',
      'season': 'Fall',
      'year': '2024',
      'startDate': DateTime(2024, 9, 1),
      'endDate': DateTime(2024, 12, 20),
      'status': 'Active',
      'color': Colors.orange,
      'weeks': 15,
      'credits': 18,
      'courses': 5,
    },
    {
      'name': 'Spring 2025',
      'season': 'Spring',
      'year': '2025',
      'startDate': DateTime(2025, 2, 1),
      'endDate': DateTime(2025, 5, 30),
      'status': 'Upcoming',
      'color': Colors.green,
      'weeks': 15,
      'credits': 15,
      'courses': 4,
    },
    {
      'name': 'Summer 2025',
      'season': 'Summer',
      'year': '2025',
      'startDate': DateTime(2025, 6, 15),
      'endDate': DateTime(2025, 8, 15),
      'status': 'Upcoming',
      'color': Colors.blue,
      'weeks': 8,
      'credits': 6,
      'courses': 2,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _semesterEvents = {
    'Fall 2024': [
      {
        'title': 'Classes Begin',
        'date': DateTime(2024, 9, 1),
        'type': 'academic',
        'icon': Icons.school,
      },
      {
        'title': 'Add/Drop Deadline',
        'date': DateTime(2024, 9, 15),
        'type': 'deadline',
        'icon': Icons.edit,
      },
      {
        'title': 'Midterm Exams',
        'date': DateTime(2024, 10, 20),
        'type': 'exam',
        'icon': Icons.assignment,
      },
      {
        'title': 'Registration for Spring',
        'date': DateTime(2024, 11, 1),
        'type': 'registration',
        'icon': Icons.app_registration,
      },
      {
        'title': 'Thanksgiving Break',
        'date': DateTime(2024, 11, 28),
        'type': 'holiday',
        'icon': Icons.celebration,
      },
      {
        'title': 'Final Exams',
        'date': DateTime(2024, 12, 10),
        'type': 'exam',
        'icon': Icons.description,
      },
      {
        'title': 'Semester Ends',
        'date': DateTime(2024, 12, 20),
        'type': 'academic',
        'icon': Icons.check_circle,
      },
    ],
    'Spring 2025': [
      {
        'title': 'Classes Begin',
        'date': DateTime(2025, 2, 1),
        'type': 'academic',
        'icon': Icons.school,
      },
      {
        'title': 'Add/Drop Deadline',
        'date': DateTime(2025, 2, 15),
        'type': 'deadline',
        'icon': Icons.edit,
      },
      {
        'title': 'Spring Break',
        'date': DateTime(2025, 3, 15),
        'type': 'holiday',
        'icon': Icons.beach_access,
      },
      {
        'title': 'Midterm Exams',
        'date': DateTime(2025, 3, 25),
        'type': 'exam',
        'icon': Icons.assignment,
      },
      {
        'title': 'Registration for Fall',
        'date': DateTime(2025, 4, 1),
        'type': 'registration',
        'icon': Icons.app_registration,
      },
      {
        'title': 'Final Exams',
        'date': DateTime(2025, 5, 15),
        'type': 'exam',
        'icon': Icons.description,
      },
      {
        'title': 'Commencement Ceremony',
        'date': DateTime(2025, 5, 25),
        'type': 'event',
        'icon': Icons.school_outlined,
      },
      {
        'title': 'Semester Ends',
        'date': DateTime(2025, 5, 30),
        'type': 'academic',
        'icon': Icons.check_circle,
      },
    ],
    'Summer 2025': [
      {
        'title': 'Classes Begin',
        'date': DateTime(2025, 6, 15),
        'type': 'academic',
        'icon': Icons.school,
      },
      {
        'title': 'Add/Drop Deadline',
        'date': DateTime(2025, 6, 20),
        'type': 'deadline',
        'icon': Icons.edit,
      },
      {
        'title': 'Independence Day',
        'date': DateTime(2025, 7, 4),
        'type': 'holiday',
        'icon': Icons.celebration,
      },
      {
        'title': 'Final Exams',
        'date': DateTime(2025, 8, 10),
        'type': 'exam',
        'icon': Icons.description,
      },
      {
        'title': 'Semester Ends',
        'date': DateTime(2025, 8, 15),
        'type': 'academic',
        'icon': Icons.check_circle,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentSemester = _semesters[_selectedSemester];
    final events = _semesterEvents[currentSemester['name']] ?? [];

    return Scaffold(
      // ========================================================================
      // APP BAR
      // ========================================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Academic Year Schedule",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading schedule...')),
              );
            },
          ),
        ],
      ),

      // ========================================================================
      // BODY
      // ========================================================================
      body: Column(
        children: [
          // --------------------------------------------------------------------
          // Academic Year Overview Header
          // --------------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[900],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Academic Year 2024-2025",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _buildYearStatChip(
                        icon: Icons.calendar_month,
                        label: "3 Semesters",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildYearStatChip(
                        icon: Icons.credit_score,
                        label: "39 Credits",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildYearStatChip(
                        icon: Icons.school,
                        label: "11 Courses",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --------------------------------------------------------------------
          // Semester Tabs
          // --------------------------------------------------------------------
          Container(
            height: 70,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _semesters.length,
              itemBuilder: (context, index) {
                final semester = _semesters[index];
                final isSelected = index == _selectedSemester;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSemester = index;
                    });
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                semester['color'].withOpacity(0.7),
                                semester['color'],
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? semester['color']
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          semester['season'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        Text(
                          semester['year'],
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --------------------------------------------------------------------
          // Semester Details Card
          // --------------------------------------------------------------------
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentSemester['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: currentSemester['color'],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentSemester['status'] == 'Active'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentSemester['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: "Duration",
                      value:
                          "${DateFormat('MMM d').format(currentSemester['startDate'])} - ${DateFormat('MMM d').format(currentSemester['endDate'])}",
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox(
                      icon: Icons.access_time,
                      value: "${currentSemester['weeks']}",
                      label: "Weeks",
                      color: Colors.blue,
                    ),
                    _buildStatBox(
                      icon: Icons.credit_score,
                      value: "${currentSemester['credits']}",
                      label: "Credits",
                      color: Colors.green,
                    ),
                    _buildStatBox(
                      icon: Icons.school,
                      value: "${currentSemester['courses']}",
                      label: "Courses",
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --------------------------------------------------------------------
          // Important Dates Section
          // --------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Important Dates",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
                Text(
                  "${events.length} Events",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // --------------------------------------------------------------------
          // Events Timeline
          // --------------------------------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventItem(event, index == events.length - 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  Widget _buildYearStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event, bool isLast) {
    Color eventColor;
    switch (event['type']) {
      case 'exam':
        eventColor = Colors.red;
        break;
      case 'deadline':
        eventColor = Colors.orange;
        break;
      case 'holiday':
        eventColor = Colors.green;
        break;
      case 'registration':
        eventColor = Colors.purple;
        break;
      case 'event':
        eventColor = Colors.blue;
        break;
      default:
        eventColor = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: eventColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: eventColor, width: 2),
              ),
              child: Icon(event['icon'], color: eventColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Event details
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(event['date']),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: eventColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['type'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: eventColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}
