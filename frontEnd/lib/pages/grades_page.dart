// ============================================================================
// GRADES PAGE - Enhanced Academic Performance Display
// ============================================================================
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  String _selectedSemester = 'Fall 2024';

  // Mock data with CC, DS, Exam components
  final List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS301',
      'name': 'Data Structures & Algorithms',
      'instructor': 'Dr. Ahmed Ben Ali',
      'credits': 4,
      'color': Colors.blue,
      'cc': 85.0,
      'ds': 90.0,
      'exam': 88.0,
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
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate overall GPA
    double totalGrade = 0;
    for (var course in _courses) {
      totalGrade += (course['cc'] * 0.3 + course['ds'] * 0.3 + course['exam'] * 0.4);
    }
    double avgGrade = totalGrade / _courses.length;
    double gpa = (avgGrade / 100) * 4.0;

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
          "My Grades",
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
                const SnackBar(content: Text('Downloading transcript...')),
              );
            },
          ),
        ],
      ),

      // ========================================================================
      // BODY
      // ========================================================================
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --------------------------------------------------------------------
            // GPA Summary Header
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
                    "Academic Performance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGPACircle('Current GPA', gpa, Colors.amber[800]!),
                      _buildGPACircle('Semester GPA', 3.85, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.school,
                          value: "${_courses.length}",
                          label: "Courses",
                        ),
                        _buildStatItem(
                          icon: Icons.trending_up,
                          value: "${avgGrade.toStringAsFixed(1)}%",
                          label: "Average",
                        ),
                        _buildStatItem(
                          icon: Icons.emoji_events,
                          value: _getLetterGrade(avgGrade),
                          label: "Grade",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------------------
            // Semester Selection
            // --------------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Semester Grades",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSemester,
                      underline: Container(),
                      items: ['Fall 2024', 'Spring 2024', 'Fall 2023']
                          .map((semester) => DropdownMenuItem(
                                value: semester,
                                child: Text(
                                  semester,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[900],
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------------------
            // Grading System Info
            // --------------------------------------------------------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Grading Formula",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        Text(
                          "CC (30%) + DS (30%) + Exam (40%)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------------------
            // Courses List
            // --------------------------------------------------------------------
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return _buildCourseGradeCard(course);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  Widget _buildGPACircle(String label, double gpa, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50,
          lineWidth: 10,
          percent: gpa / 4.0,
          center: Text(
            gpa.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          progressColor: color,
          backgroundColor: Colors.white.withOpacity(0.3),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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
    );
  }

  Widget _buildCourseGradeCard(Map<String, dynamic> course) {
    final double totalGrade = (course['cc'] * 0.3 + course['ds'] * 0.3 + course['exam'] * 0.4);
    final Color gradeColor = _getGradeColor(totalGrade);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showDetailedGrades(course),
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: course['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        course['code'].substring(2),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: course['color'],
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
                          course['code'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: course['color'],
                          ),
                        ),
                        Text(
                          course['name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          course['instructor'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: gradeColor, width: 2),
                        ),
                        child: Text(
                          "${totalGrade.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLetterGrade(totalGrade),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grade Components Row
              Row(
                children: [
                  Expanded(
                    child: _buildGradeComponent(
                      label: "CC",
                      percentage: 30,
                      score: course['cc'],
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGradeComponent(
                      label: "DS",
                      percentage: 30,
                      score: course['ds'],
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGradeComponent(
                      label: "Exam",
                      percentage: 40,
                      score: course['exam'],
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 8,
                percent: totalGrade / 100,
                backgroundColor: Colors.grey[300],
                progressColor: gradeColor,
                barRadius: const Radius.circular(10),
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.orange;
    return Colors.red;
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

  void _showDetailedGrades(Map<String, dynamic> course) {
    final double totalGrade = (course['cc'] * 0.3 + course['ds'] * 0.3 + course['exam'] * 0.4);
    final Color gradeColor = _getGradeColor(totalGrade);

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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Course Title
                  Text(
                    course['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  Text(
                    "${course['code']} • ${course['instructor']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overall Grade Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradeColor.withOpacity(0.7),
                          gradeColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Final Grade",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${totalGrade.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getLetterGrade(totalGrade),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${course['credits']} Credits",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grade Breakdown Title
                  Text(
                    "Grade Breakdown",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CC Component
                  _buildDetailedComponent(
                    title: "CC (Continuous Control)",
                    description: "Quizzes, assignments, and class participation",
                    score: course['cc'],
                    weight: 30,
                    color: Colors.blue,
                    maxScore: 100,
                  ),
                  const SizedBox(height: 16),

                  // DS Component
                  _buildDetailedComponent(
                    title: "DS (Devoir Surveillé)",
                    description: "Midterm examination",
                    score: course['ds'],
                    weight: 30,
                    color: Colors.orange,
                    maxScore: 100,
                  ),
                  const SizedBox(height: 16),

                  // Exam Component
                  _buildDetailedComponent(
                    title: "Final Exam",
                    description: "Final examination",
                    score: course['exam'],
                    weight: 40,
                    color: Colors.red,
                    maxScore: 100,
                  ),
                  const SizedBox(height: 24),

                  // Calculation Breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Calculation",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCalculationRow(
                          "CC:",
                          "${course['cc']}% × 30% = ${(course['cc'] * 0.3).toStringAsFixed(1)}%",
                          Colors.blue,
                        ),
                        _buildCalculationRow(
                          "DS:",
                          "${course['ds']}% × 30% = ${(course['ds'] * 0.3).toStringAsFixed(1)}%",
                          Colors.orange,
                        ),
                        _buildCalculationRow(
                          "Exam:",
                          "${course['exam']}% × 40% = ${(course['exam'] * 0.4).toStringAsFixed(1)}%",
                          Colors.red,
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${totalGrade.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: gradeColor,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedComponent({
    required String title,
    required String description,
    required double score,
    required int weight,
    required Color color,
    required double maxScore,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${score.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    "Weight: $weight%",
                    style: TextStyle(
                      fontSize: 11,
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
            lineHeight: 12,
            percent: score / maxScore,
            backgroundColor: Colors.grey[300],
            progressColor: color,
            barRadius: const Radius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contributes: ${(score * weight / 100).toStringAsFixed(1)}% to final grade",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

