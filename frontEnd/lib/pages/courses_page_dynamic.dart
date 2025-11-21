// ============================================================================
// COURSES PAGE - Dynamic API Integration
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/controllers/course_controller.dart';
import '../core/models/course.dart';

class CoursesPageDynamic extends StatefulWidget {
  const CoursesPageDynamic({super.key});

  @override
  State<CoursesPageDynamic> createState() => _CoursesPageDynamicState();
}

class _CoursesPageDynamicState extends State<CoursesPageDynamic> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseController>().loadStudentCourses();
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
          "My Courses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<CourseController>(
        builder: (context, controller, child) {
          // Loading state
          if (controller.state == CourseLoadingState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Loading courses...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Error state
          if (controller.state == CourseLoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Error loading courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
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
          final courses = controller.courses;
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No courses enrolled', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Calculate stats
          final totalCredits = courses.fold<int>(0, (sum, course) => sum + course.credits);
          double totalGradePoints = 0.0;
          int coursesWithGrades = 0;
          for (var course in courses) {
            if (course.finalGrade != null) {
              totalGradePoints += course.finalGrade! * course.credits;
              coursesWithGrades++;
            }
          }
          final avgGrade = coursesWithGrades > 0 ? totalGradePoints / totalCredits : 0.0;

          return Column(
            children: [
              // Semester Summary Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Text("Current Semester", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryItem(icon: Icons.school, value: "${courses.length}", label: "Courses"),
                        _buildSummaryItem(icon: Icons.credit_score, value: "$totalCredits", label: "Credits"),
                        _buildSummaryItem(icon: Icons.trending_up, value: avgGrade > 0 ? "${avgGrade.toStringAsFixed(1)}%" : "N/A", label: "Avg Grade"),
                      ],
                    ),
                  ],
                ),
              ),
              // Courses List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) => _buildCourseCard(courses[index], index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, int index) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.indigo, Colors.pink, Colors.cyan, Colors.deepOrange, Colors.lime, Colors.red, Colors.blueGrey, Colors.deepPurple, Colors.amber, Colors.green, Colors.brown];
    final color = colors[index % colors.length];
    final totalGrade = course.finalGrade ?? 0.0;
    final gradeColor = _getGradeColor(totalGrade);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showCourseDetails(course, color),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        course.courseCode.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 3),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.courseCode, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                        const SizedBox(height: 4),
                        Text(course.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("${course.credits} Credits", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (course.finalGrade != null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: gradeColor, width: 2),
                          ),
                          child: Text("${totalGrade.toStringAsFixed(1)}%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: gradeColor)),
                        ),
                        const SizedBox(height: 4),
                        Text(course.letterGrade ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: gradeColor)),
                      ],
                    ),
                ],
              ),
              if (course.hasAllScores) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildGradeComponent("CC", course.ccWeight ?? 30, course.ccScore ?? 0, Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGradeComponent("DS", course.dsWeight ?? 20, course.dsScore ?? 0, Colors.orange)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGradeComponent("Exam", course.examWeight ?? 40, course.examScore ?? 0, Colors.red)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeComponent(String label, int weight, double score, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text("${score.toStringAsFixed(0)}%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text("($weight%)", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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

  void _showCourseDetails(Course course, Color color) {
    final totalGrade = course.finalGrade ?? 0.0;
    final gradeColor = _getGradeColor(totalGrade);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(course.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[900])),
                  Text("${course.courseCode} • ${course.credits} Credits", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  if (course.finalGrade != null) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [gradeColor.withOpacity(0.7), gradeColor]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text("Final Grade", style: TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text("${totalGrade.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
                          Text(course.letterGrade ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    if (course.hasAllScores) ...[
                      const SizedBox(height: 24),
                      Text("Grade Breakdown", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900])),
                      const SizedBox(height: 16),
                      _buildDetailedComponent("CC (Continuous Control)", course.ccScore ?? 0, course.ccWeight, Colors.blue),
                      const SizedBox(height: 16),
                      _buildDetailedComponent("DS (Devoir Surveillé)", course.dsScore ?? 0, course.dsWeight, Colors.orange),
                      const SizedBox(height: 16),
                      _buildDetailedComponent("Final Exam", course.examScore ?? 0, course.examWeight, Colors.red),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text("Grades not available yet", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
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

  Widget _buildDetailedComponent(String title, double score, int weight, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${score.toStringAsFixed(0)}%", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              Text("Weight: $weight%", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text("Contributes: ${(score * weight / 100).toStringAsFixed(1)}%", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
