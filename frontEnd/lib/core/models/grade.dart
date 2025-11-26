// ============================================================================
// GRADE MODEL - Represents a course grade with components (transcript view)
// ============================================================================

class Grade {
  final int? courseId;
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
    this.courseId,
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
      courseId: json['course_id'] != null ? json['course_id'] as int : null,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      credits: json['credits'] is int ? json['credits'] : int.parse(json['credits'].toString()),
      ccScore: json['cc_score'] != null ? (json['cc_score'] is num ? json['cc_score'].toDouble() : double.tryParse(json['cc_score'].toString())) : null,
      dsScore: json['ds_score'] != null ? (json['ds_score'] is num ? json['ds_score'].toDouble() : double.tryParse(json['ds_score'].toString())) : null,
      examScore: json['exam_score'] != null ? (json['exam_score'] is num ? json['exam_score'].toDouble() : double.tryParse(json['exam_score'].toString())) : null,
      ccWeight: json['cc_weight'] != null ? (json['cc_weight'] is int ? json['cc_weight'] : int.tryParse(json['cc_weight'].toString())) : null,
      dsWeight: json['ds_weight'] != null ? (json['ds_weight'] is int ? json['ds_weight'] : int.tryParse(json['ds_weight'].toString())) : null,
      examWeight: json['exam_weight'] != null ? (json['exam_weight'] is int ? json['exam_weight'] : int.tryParse(json['exam_weight'].toString())) : null,
      finalGrade: json['final_grade'] != null ? (json['final_grade'] is num ? json['final_grade'].toDouble() : double.tryParse(json['final_grade'].toString())) : null,
      letterGrade: json['letter_grade'] as String?,
      status: json['status'] as String?,
      yearTaken: json['year_taken'] != null ? (json['year_taken'] is int ? json['year_taken'] : int.tryParse(json['year_taken'].toString())) : null,
      semesterTaken: json['semester_taken'] != null ? (json['semester_taken'] is int ? json['semester_taken'] : int.tryParse(json['semester_taken'].toString())) : null,
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
      semester: json['semester'] is int ? json['semester'] : int.parse(json['semester'].toString()),
      courses: (json['courses'] as List)
          .map((course) => Grade.fromJson(course as Map<String, dynamic>))
          .toList(),
      semesterCredits: json['semester_credits'] is int ? json['semester_credits'] : int.parse(json['semester_credits'].toString()),
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
      year: json['year'] is int ? json['year'] : int.parse(json['year'].toString()),
      semesters: (json['semesters'] as List)
          .map((sem) => SemesterTranscript.fromJson(sem as Map<String, dynamic>))
          .toList(),
      yearGpa: json['year_gpa'] != null ? (json['year_gpa'] is num ? json['year_gpa'].toDouble() : double.tryParse(json['year_gpa'].toString())) : null,
    );
  }
}

class Transcript {
  final int studentId;
  final String studentName;
  final String? majorName;
  final int currentYear;
  final List<YearTranscript> transcript;
  final double? overallGpa;
  final int? creditsTaken;
  final int? creditsRemaining;

  Transcript({
    required this.studentId,
    required this.studentName,
    this.majorName,
    required this.currentYear,
    required this.transcript,
    this.overallGpa,
    this.creditsTaken,
    this.creditsRemaining,
  });

  factory Transcript.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final student = data['student'] as Map<String, dynamic>;
    
    return Transcript(
      studentId: student['id'] is int ? student['id'] : int.parse(student['id'].toString()),
      studentName: student['name'] as String,
      majorName: student['major'] as String?,
      currentYear: student['current_year'] is int ? student['current_year'] : int.parse(student['current_year'].toString()),
      transcript: (data['transcript'] as List)
          .map((year) => YearTranscript.fromJson(year as Map<String, dynamic>))
          .toList(),
      overallGpa: data['overall_gpa'] != null ? (data['overall_gpa'] is num ? data['overall_gpa'].toDouble() : double.tryParse(data['overall_gpa'].toString())) : null,
      creditsTaken: data['credits_taken'] != null ? (data['credits_taken'] is int ? data['credits_taken'] : int.tryParse(data['credits_taken'].toString())) : null,
      creditsRemaining: data['credits_remaining'] != null ? (data['credits_remaining'] is int ? data['credits_remaining'] : int.tryParse(data['credits_remaining'].toString())) : null,
    );
  }
}
