// ============================================================================
// COURSES PAGE - All Enrolled Courses with Details
// ============================================================================
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // Mock data for all courses
  final List<Map<String, dynamic>> _allCourses = [
    {
      'code': 'CS301',
      'name': 'Data Structures & Algorithms',
      'instructor': 'Dr. Ahmed Ben Ali',
      'credits': 4,
      'color': Colors.blue,
      'cc': 85.0,
      'ds': 90.0,
      'exam': 88.0,
      'schedule': 'Mon, Wed 10:00-11:30',
      'room': 'Room A-101',
    },
    {
      'code': 'CS302',
      'name': 'Database Systems',
      'instructor': 'Prof. Sarah Mahmoud',
      'credits': 3,
      'color': Colors.purple,
      'cc': 92.0,
      'ds': 88.0,
      'exam': 90.0,
      'schedule': 'Tue, Thu 14:00-15:30',
      'room': 'Room B-203',
    },
    {
      'code': 'CS303',
      'name': 'Operating Systems',
      'instructor': 'Dr. Mohamed Ali',
      'credits': 4,
      'color': Colors.orange,
      'cc': 78.0,
      'ds': 85.0,
      'exam': 82.0,
      'schedule': 'Mon, Wed 14:00-15:30',
      'room': 'Room C-105',
    },
    {
      'code': 'CS304',
      'name': 'Software Engineering',
      'instructor': 'Dr. Fatima Hassan',
      'credits': 3,
      'color': Colors.teal,
      'cc': 88.0,
      'ds': 92.0,
      'exam': 87.0,
      'schedule': 'Tue, Thu 10:00-11:30',
      'room': 'Room A-204',
    },
    {
      'code': 'CS305',
      'name': 'Computer Networks',
      'instructor': 'Prof. Karim Mansour',
      'credits': 4,
      'color': Colors.indigo,
      'cc': 90.0,
      'ds': 87.0,
      'exam': 91.0,
      'schedule': 'Wed, Fri 08:00-09:30',
      'room': 'Room B-301',
    },
    {
      'code': 'CS306',
      'name': 'Web Development',
      'instructor': 'Dr. Leila Trabelsi',
      'credits': 3,
      'color': Colors.pink,
      'cc': 95.0,
      'ds': 93.0,
      'exam': 94.0,
      'schedule': 'Mon, Wed 08:00-09:30',
      'room': 'Room D-102',
    },
    {
      'code': 'CS307',
      'name': 'Artificial Intelligence',
      'instructor': 'Dr. Youssef Ben Said',
      'credits': 4,
      'color': Colors.cyan,
      'cc': 82.0,
      'ds': 86.0,
      'exam': 84.0,
      'schedule': 'Tue, Thu 12:00-13:30',
      'room': 'Room A-303',
    },
    {
      'code': 'CS308',
      'name': 'Mobile Application Development',
      'instructor': 'Prof. Amina Khelifi',
      'credits': 3,
      'color': Colors.deepOrange,
      'cc': 89.0,
      'ds': 91.0,
      'exam': 88.0,
      'schedule': 'Mon, Fri 10:00-11:30',
      'room': 'Room C-201',
    },
    {
      'code': 'CS309',
      'name': 'Computer Graphics',
      'instructor': 'Dr. Hamza Dridi',
      'credits': 3,
      'color': Colors.lime,
      'cc': 87.0,
      'ds': 84.0,
      'exam': 86.0,
      'schedule': 'Wed, Fri 14:00-15:30',
      'room': 'Room B-105',
    },
    {
      'code': 'CS310',
      'name': 'Cybersecurity',
      'instructor': 'Prof. Mariem Bouaziz',
      'credits': 4,
      'color': Colors.red,
      'cc': 91.0,
      'ds': 89.0,
      'exam': 92.0,
      'schedule': 'Tue, Thu 08:00-09:30',
      'room': 'Room A-405',
    },
    {
      'code': 'CS311',
      'name': 'Cloud Computing',
      'instructor': 'Dr. Tarek Jomaa',
      'credits': 3,
      'color': Colors.blueGrey,
      'cc': 86.0,
      'ds': 88.0,
      'exam': 85.0,
      'schedule': 'Mon, Wed 12:00-13:30',
      'room': 'Room D-204',
    },
    {
      'code': 'CS312',
      'name': 'Machine Learning',
      'instructor': 'Dr. Nadia Zaouali',
      'credits': 4,
      'color': Colors.deepPurple,
      'cc': 84.0,
      'ds': 87.0,
      'exam': 83.0,
      'schedule': 'Tue, Fri 10:00-11:30',
      'room': 'Room C-302',
    },
    {
      'code': 'CS313',
      'name': 'Blockchain Technology',
      'instructor': 'Prof. Rami Gharbi',
      'credits': 3,
      'color': Colors.amber,
      'cc': 88.0,
      'ds': 90.0,
      'exam': 89.0,
      'schedule': 'Wed, Fri 12:00-13:30',
      'room': 'Room B-404',
    },
    {
      'code': 'CS314',
      'name': 'IoT Systems',
      'instructor': 'Dr. Sonia Mejri',
      'credits': 3,
      'color': Colors.green,
      'cc': 90.0,
      'ds': 92.0,
      'exam': 91.0,
      'schedule': 'Mon, Thu 14:00-15:30',
      'room': 'Room A-202',
    },
    {
      'code': 'CS315',
      'name': 'DevOps & Automation',
      'instructor': 'Dr. Bilel Kacem',
      'credits': 4,
      'color': Colors.brown,
      'cc': 87.0,
      'ds': 85.0,
      'exam': 88.0,
      'schedule': 'Tue, Thu 16:00-17:30',
      'room': 'Room C-403',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalCredits = _allCourses.fold<int>(0, (sum, course) => sum + (course['credits'] as int));

    double totalGradePoints = 0.0;
    for (var course in _allCourses) {
      double grade = (course['cc'] * 0.3 + course['ds'] * 0.3 + course['exam'] * 0.4);
      totalGradePoints += grade * course['credits'];
    }
    double avgGrade = totalGradePoints / totalCredits;

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
          "My Courses",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search
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
          // Semester Summary Header
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
                  "Fall 2024 - Semester 5",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.school,
                      value: "${_allCourses.length}",
                      label: "Courses",
                    ),
                    _buildSummaryItem(
                      icon: Icons.credit_score,
                      value: "$totalCredits",
                      label: "Credits",
                    ),
                    _buildSummaryItem(
                      icon: Icons.trending_up,
                      value: "${avgGrade.toStringAsFixed(1)}%",
                      label: "Avg Grade",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // --------------------------------------------------------------------
          // Courses List
          // --------------------------------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allCourses.length,
              itemBuilder: (context, index) {
                final course = _allCourses[index];
                return _buildCourseCard(course);
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
  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final double totalGrade = (course['cc'] * 0.3 + course['ds'] * 0.3 + course['exam'] * 0.4);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showCourseDetails(course),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: course['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        course['code'].substring(2),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: course['color'],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['code'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: course['color'],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course['instructor'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: course['color'].withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      "${course['credits']} CR",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: course['color'],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Grade Breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Overall Grade",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          "${totalGrade.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(totalGrade),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 8,
                      percent: totalGrade / 100,
                      backgroundColor: Colors.grey[300],
                      progressColor: _getGradeColor(totalGrade),
                      barRadius: const Radius.circular(10),
                    ),
                    const SizedBox(height: 12),
                    // Component Scores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGradeComponent(
                          label: "CC",
                          percentage: 30,
                          score: course['cc'],
                          color: Colors.blue,
                        ),
                        _buildGradeComponent(
                          label: "DS",
                          percentage: 30,
                          score: course['ds'],
                          color: Colors.orange,
                        ),
                        _buildGradeComponent(
                          label: "Exam",
                          percentage: 40,
                          score: course['exam'],
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Schedule Info
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    course['schedule'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.room, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    course['room'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildGradeComponent({
    required String label,
    required int percentage,
    required double score,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${score.toStringAsFixed(0)}%",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          "($percentage%)",
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.orange;
    return Colors.red;
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    final double totalGrade = (course['cc'] * 0.3 + course['ds'] * 0.3 + course['exam'] * 0.4);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Course Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: course['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.book,
                          color: course['color'],
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['code'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: course['color'],
                              ),
                            ),
                            Text(
                              course['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              course['instructor'],
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
                  // Overall Grade Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getGradeColor(totalGrade).withOpacity(0.7),
                          _getGradeColor(totalGrade),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Overall Grade",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${totalGrade.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getLetterGrade(totalGrade),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Grade Components
                  Text(
                    "Grade Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailedGradeComponent(
                    label: "CC (Continuous Control)",
                    score: course['cc'],
                    weight: 30,
                    color: Colors.blue,
                    description: "Quizzes, assignments, and class participation",
                  ),
                  const SizedBox(height: 12),
                  _buildDetailedGradeComponent(
                    label: "DS (Devoir Surveillé)",
                    score: course['ds'],
                    weight: 30,
                    color: Colors.orange,
                    description: "Midterm examination",
                  ),
                  const SizedBox(height: 12),
                  _buildDetailedGradeComponent(
                    label: "Final Exam",
                    score: course['exam'],
                    weight: 40,
                    color: Colors.red,
                    description: "Final examination",
                  ),
                  const SizedBox(height: 24),
                  // Course Details
                  _buildDetailRow(
                    icon: Icons.credit_score,
                    label: "Credits",
                    value: "${course['credits']} Credits",
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: "Schedule",
                    value: course['schedule'],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.room,
                    label: "Room",
                    value: course['room'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedGradeComponent({
    required String label,
    required double score,
    required int weight,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${score.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    "Weight: $weight%",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: score / 100,
            backgroundColor: Colors.grey[300],
            progressColor: color,
            barRadius: const Radius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
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

  String _getLetterGrade(double grade) {
    if (grade >= 90) return 'A';
    if (grade >= 85) return 'A-';
    if (grade >= 80) return 'B+';
    if (grade >= 75) return 'B';
    if (grade >= 70) return 'B-';
    if (grade >= 65) return 'C+';
    if (grade >= 60) return 'C';
    return 'F';
  }
}