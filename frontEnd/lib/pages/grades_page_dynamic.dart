// ============================================================================
// GRADES PAGE - Dynamic API Integration
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../core/controllers/grade_controller.dart';
import '../core/controllers/student_controller.dart';
import '../core/models/grade.dart';

class GradesPageDynamic extends StatefulWidget {
  const GradesPageDynamic({super.key});

  @override
  State<GradesPageDynamic> createState() => _GradesPageDynamicState();
}

class _GradesPageDynamicState extends State<GradesPageDynamic> {
  int _selectedYear = 1;
  int? _selectedSemester; // null means show all semesters

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    debugPrint('GradesPageDynamic: _loadData called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('GradesPageDynamic: addPostFrameCallback executing');
      final studentController = context.read<StudentController>();
      final gradeController = context.read<GradeController>();
      
      if (studentController.student != null) {
        debugPrint('GradesPageDynamic: Student found, loading transcript for ID: ${studentController.student!.id}');
        gradeController.loadTranscript(studentController.student!.id);
      } else {
        debugPrint('GradesPageDynamic: No student found, loading profile first');
        studentController.loadProfile().then((_) {
          if (studentController.student != null) {
            debugPrint('GradesPageDynamic: Profile loaded, loading transcript for ID: ${studentController.student!.id}');
            gradeController.loadTranscript(studentController.student!.id);
          } else {
            debugPrint('GradesPageDynamic: Profile load failed, no student data');
          }
        });
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
          "My Grades",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<GradeController>(
        builder: (context, controller, child) {
          debugPrint('GradesPageDynamic: Consumer builder called, state: ${controller.state}');
          debugPrint('GradesPageDynamic: Transcript data: ${controller.transcript}');
          if (controller.transcript != null) {
            debugPrint('GradesPageDynamic: Transcript years: ${controller.transcript!.transcript.map((yt) => yt.year)}');
            controller.transcript!.transcript.forEach((yearTranscript) {
              debugPrint('GradesPageDynamic: Year ${yearTranscript.year} has ${yearTranscript.semesters.length} semesters, GPA: ${yearTranscript.yearGpa}');
              yearTranscript.semesters.forEach((semester) {
                debugPrint('GradesPageDynamic: Semester ${semester.semester} has ${semester.courses.length} courses');
                semester.courses.forEach((course) {
                  debugPrint('GradesPageDynamic: Course - ${course.courseName} (${course.courseCode}): ${course.letterGrade}');
                });
              });
            });
          }

          // Loading state
          if (controller.state == GradeLoadingState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text('Loading transcript...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Error state
          if (controller.state == GradeLoadingState.error) {
            debugPrint('GradesPageDynamic: Showing error state, error: ${controller.errorMessage}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[900]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading grades',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // No data
          final transcript = controller.transcript;
          if (transcript == null) {
            debugPrint('GradesPageDynamic: Transcript is null, showing no grades message');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No grades available', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          // Loaded state
          return _buildTranscriptView(transcript);
        },
      ),
    );
  }

  Widget _buildTranscriptView(Transcript transcript) {
    debugPrint('GradesPageDynamic: _buildTranscriptView called for selected year: $_selectedYear');
    final availableYears = transcript.transcript.map((yt) => yt.year).toList();
    debugPrint('GradesPageDynamic: Available years: $availableYears');
    if (availableYears.isNotEmpty && !availableYears.contains(_selectedYear)) {
      _selectedYear = availableYears.first;
      debugPrint('GradesPageDynamic: Updated selected year to: $_selectedYear');
    }

    final selectedYearTranscript = transcript.transcript.firstWhere(
      (yt) => yt.year == _selectedYear,
      orElse: () => YearTranscript(year: _selectedYear, semesters: []),
    );
    debugPrint('GradesPageDynamic: Selected year transcript has ${selectedYearTranscript.semesters.length} semesters');

    return SingleChildScrollView(
      child: Column(
        children: [
          // GPA Summary Header
          _buildGPAHeader(transcript),
          
          // Year Selection
          _buildYearSelector(availableYears),
          
          // Semester Selection
          _buildSemesterSelector(selectedYearTranscript.semesters),
          
          // Grading Info
          _buildGradingInfo(),
          
          // Semesters
          if (selectedYearTranscript.semesters.isEmpty)
            _buildNoGradesMessage()
          else
            ..._getFilteredSemesters(selectedYearTranscript.semesters).map((sem) => _buildSemesterSection(sem)),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGPAHeader(Transcript transcript) {
    final currentYearGpa = transcript.transcript
        .firstWhere((yt) => yt.year == _selectedYear, orElse: () => YearTranscript(year: _selectedYear, semesters: []))
        .yearGpa ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text(
            "Academic Performance",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGPACircle('Overall GPA', transcript.overallGpa ?? 0.0, Colors.amber[800]!),
              _buildGPACircle('Year $_selectedYear GPA', currentYearGpa, Colors.green),
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
                  value: "${transcript.creditsTaken ?? 0}",
                  label: "Credits",
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: "${transcript.creditsRemaining ?? 0}",
                  label: "Remaining",
                ),
                _buildStatItem(
                  icon: Icons.emoji_events,
                  value: transcript.currentYear.toString(),
                  label: "Year",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(List<int> years) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Year $_selectedYear Grades",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: DropdownButton<int>(
              value: _selectedYear,
              underline: Container(),
              items: years.map((year) => DropdownMenuItem(
                value: year,
                child: Text('Year $year', style: TextStyle(fontSize: 14, color: Colors.red[900])),
              )).toList(),
              onChanged: (value) {
                debugPrint('GradesPageDynamic: Year changed to $value');
                setState(() {
                  _selectedYear = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingInfo() {
    return Container(
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
                Text("Grading Formula", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                Text("CC (Weight%) + DS (Weight%) + Exam (Weight%)", style: TextStyle(fontSize: 12, color: Colors.blue[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterSelector(List<SemesterTranscript> semesters) {
    if (semesters.isEmpty) return Container();

    final availableSemesters = semesters.map((s) => s.semester).toSet().toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Filter by Semester",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[900]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: DropdownButton<int?>(
              value: _selectedSemester,
              underline: Container(),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Semesters', style: TextStyle(fontSize: 14, color: Colors.red[900])),
                ),
                ...availableSemesters.map((semester) => DropdownMenuItem<int?>(
                  value: semester,
                  child: Text('Semester $semester', style: TextStyle(fontSize: 14, color: Colors.red[900])),
                )),
              ],
              onChanged: (value) {
                debugPrint('GradesPageDynamic: Semester changed to $value');
                setState(() {
                  _selectedSemester = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<SemesterTranscript> _getFilteredSemesters(List<SemesterTranscript> semesters) {
    if (_selectedSemester == null) {
      return semesters; // Show all semesters
    }
    return semesters.where((s) => s.semester == _selectedSemester).toList();
  }

  Widget _buildSemesterSection(SemesterTranscript semester) {
    debugPrint('GradesPageDynamic: Building semester ${semester.semester} with ${semester.courses.length} courses');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Semester ${semester.semester} (${semester.semesterCredits} Credits)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[800]),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: semester.courses.length,
          itemBuilder: (context, index) => _buildCourseGradeCard(semester.courses[index]),
        ),
      ],
    );
  }

  Widget _buildCourseGradeCard(Grade grade) {
    debugPrint('GradesPageDynamic: Building course card for ${grade.courseName} (${grade.courseCode}): ${grade.letterGrade}');
    final totalGrade = grade.finalGrade ?? 0.0;
    final gradeColor = _getGradeColor(totalGrade);
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.indigo];
    final color = colors[(grade.courseId ?? grade.courseCode.hashCode) % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showDetailedGrades(grade),
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        grade.courseCode.replaceAll(RegExp(r'[^0-9]'), ''),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(grade.courseCode, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                        Text(grade.courseName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("${grade.credits} Credits", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                        child: Text("${totalGrade.toStringAsFixed(1)}%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: gradeColor)),
                      ),
                      const SizedBox(height: 4),
                      Text(grade.letterGrade ?? 'N/A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: gradeColor)),
                    ],
                  ),
                ],
              ),
              if (grade.hasAllScores) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildGradeComponent("CC", grade.ccWeight ?? 30, grade.ccScore ?? 0, Colors.blue)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGradeComponent("DS", grade.dsWeight ?? 20, grade.dsScore ?? 0, Colors.orange)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGradeComponent("Exam", grade.examWeight ?? 40, grade.examScore ?? 0, Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8,
                  percent: totalGrade / 100,
                  backgroundColor: Colors.grey[300],
                  progressColor: gradeColor,
                  barRadius: const Radius.circular(10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeComponent(String label, int percentage, double score, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text("${score.toStringAsFixed(0)}%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text("($percentage%)", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGPACircle(String label, double gpa, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50,
          lineWidth: 10,
          percent: (gpa / 4.0).clamp(0.0, 1.0),
          center: Text(gpa.toStringAsFixed(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          progressColor: color,
          backgroundColor: Colors.white.withOpacity(0.3),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildNoGradesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No grades for this year yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.orange;
    return Colors.red;
  }

  void _showDetailedGrades(Grade grade) {
    debugPrint('GradesPageDynamic: Showing detailed grades for ${grade.courseName} (${grade.courseCode})');
    final totalGrade = grade.finalGrade ?? 0.0;
    final gradeColor = _getGradeColor(totalGrade);

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
                  Text(grade.courseName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[900])),
                  Text("${grade.courseCode} • ${grade.credits} Credits", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  if (grade.yearTaken != null && grade.semesterTaken != null)
                    Text("Year ${grade.yearTaken}, Semester ${grade.semesterTaken}", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  if (grade.status != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: grade.status == 'completed' ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        grade.status!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: grade.status == 'completed' ? Colors.green[800] : Colors.orange[800],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
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
                        Text(grade.letterGrade ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text("${grade.credits} Credits", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  if (grade.hasAllScores) ...[
                    const SizedBox(height: 24),
                    Text("Grade Breakdown", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900])),
                    const SizedBox(height: 16),
                    _buildDetailedComponent("CC (Continuous Control)", grade.ccScore ?? 0, grade.ccWeight ?? 30, Colors.blue),
                    const SizedBox(height: 16),
                    _buildDetailedComponent("DS (Devoir Surveillé)", grade.dsScore ?? 0, grade.dsWeight ?? 20, Colors.orange),
                    const SizedBox(height: 16),
                    _buildDetailedComponent("Final Exam", grade.examScore ?? 0, grade.examWeight ?? 40, Colors.red),
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
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${score.toStringAsFixed(0)}%", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                  Text("Weight: $weight%", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 12,
            percent: score / 100,
            backgroundColor: Colors.grey[300],
            progressColor: color,
            barRadius: const Radius.circular(10),
          ),
          const SizedBox(height: 8),
          Text("Contributes: ${(score * weight / 100).toStringAsFixed(1)}% to final grade", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
