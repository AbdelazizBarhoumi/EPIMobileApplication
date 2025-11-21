// ============================================================================
// GRADE MODEL - Represents a course grade with components (transcript view)
// ============================================================================

class Grade {
  final int courseId;
  final String courseCode;
  final String courseName;
  final int credits;
  final double? ccScore; // Continuous Control
  final double? dsScore; // Directed Study
  final double? examScore; // Final Exam
  final int? ccWeight;
  final int? dsWeight;
  final int? examWeight;
  final double? finalGrade;
  final String? letterGrade;
  final String? status;
  final int? yearTaken;
  final int? semesterTaken;

  Grade({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    this.ccScore,
    this.dsScore,
    this.examScore,
    this.ccWeight,
    this.dsWeight,
    this.examWeight,
    this.finalGrade,
    this.letterGrade,
    this.status,
    this.yearTaken,
    this.semesterTaken,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      courseId: json['course_id'] as int,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      credits: json['credits'] as int,
      ccScore: json['cc_score'] != null ? (json['cc_score'] as num).toDouble() : null,
      dsScore: json['ds_score'] != null ? (json['ds_score'] as num).toDouble() : null,
      examScore: json['exam_score'] != null ? (json['exam_score'] as num).toDouble() : null,
      ccWeight: json['cc_weight'] as int?,
      dsWeight: json['ds_weight'] as int?,
      examWeight: json['exam_weight'] as int?,
      finalGrade: json['final_grade'] != null ? (json['final_grade'] as num).toDouble() : null,
      letterGrade: json['letter_grade'] as String?,
      status: json['status'] as String?,
      yearTaken: json['year_taken'] as int?,
      semesterTaken: json['semester_taken'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_code': courseCode,
      'course_name': courseName,
      'credits': credits,
      'cc_score': ccScore,
      'ds_score': dsScore,
      'exam_score': examScore,
      'cc_weight': ccWeight,
      'ds_weight': dsWeight,
      'exam_weight': examWeight,
      'final_grade': finalGrade,
      'letter_grade': letterGrade,
      'status': status,
      'year_taken': yearTaken,
      'semester_taken': semesterTaken,
    };
  }

  bool get hasAllScores => ccScore != null && dsScore != null && examScore != null;
  bool get isCompleted => status == 'completed';
}

// Transcript Structure Models
class SemesterTranscript {
  final int semester;
  final List<Grade> courses;
  final int semesterCredits;

  SemesterTranscript({
    required this.semester,
    required this.courses,
    required this.semesterCredits,
  });

  factory SemesterTranscript.fromJson(Map<String, dynamic> json) {
    return SemesterTranscript(
      semester: json['semester'] as int,
      courses: (json['courses'] as List)
          .map((course) => Grade.fromJson(course as Map<String, dynamic>))
          .toList(),
      semesterCredits: json['semester_credits'] as int,
    );
  }
}

class YearTranscript {
  final int year;
  final List<SemesterTranscript> semesters;
  final double? yearGpa;

  YearTranscript({
    required this.year,
    required this.semesters,
    this.yearGpa,
  });

  factory YearTranscript.fromJson(Map<String, dynamic> json) {
    return YearTranscript(
      year: json['year'] as int,
      semesters: (json['semesters'] as List)
          .map((sem) => SemesterTranscript.fromJson(sem as Map<String, dynamic>))
          .toList(),
      yearGpa: json['year_gpa'] != null ? (json['year_gpa'] as num).toDouble() : null,
    );
  }
}

class Transcript {
  final int studentId;
  final String studentName;
  final String? majorName;
  final int currentYear;
  final List<YearTranscript> transcript;
  final double overallGpa;
  final int creditsTaken;
  final int creditsRemaining;

  Transcript({
    required this.studentId,
    required this.studentName,
    this.majorName,
    required this.currentYear,
    required this.transcript,
    required this.overallGpa,
    required this.creditsTaken,
    required this.creditsRemaining,
  });

  factory Transcript.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final student = data['student'] as Map<String, dynamic>;
    
    return Transcript(
      studentId: student['id'] as int,
      studentName: student['name'] as String,
      majorName: student['major'] as String?,
      currentYear: student['current_year'] as int,
      transcript: (data['transcript'] as List)
          .map((year) => YearTranscript.fromJson(year as Map<String, dynamic>))
          .toList(),
      overallGpa: (data['overall_gpa'] as num).toDouble(),
      creditsTaken: data['credits_taken'] as int,
      creditsRemaining: data['credits_remaining'] as int,
    );
  }
}
