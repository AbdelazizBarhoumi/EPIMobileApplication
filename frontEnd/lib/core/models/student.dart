// ============================================================================
// STUDENT MODEL - Data Structure
// ============================================================================

/// Major/Program data model
class Major {
  final int id;
  final String code;
  final String name;
  final String department;
  final int durationYears;
  final int totalCreditsRequired;
  final String? degreeType;

  Major({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.durationYears,
    required this.totalCreditsRequired,
    this.degreeType,
  });

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      durationYears: json['duration_years'] as int,
      totalCreditsRequired: json['total_credits_required'] as int,
      degreeType: json['degree_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'department': department,
      'duration_years': durationYears,
      'total_credits_required': totalCreditsRequired,
      'degree_type': degreeType,
    };
  }
}

/// Student data model
class Student {
  final int id;
  final String studentId;
  final String name;
  final String email;
  final int? majorId;
  final Major? major;
  final int yearLevel;
  final String? academicYear;
  final String? classLevel;
  final double? gpa;
  final int? creditsTaken;
  final int? totalCredits;
  final double? tuitionFees;
  final String? avatarUrl;

  Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    this.majorId,
    this.major,
    required this.yearLevel,
    this.academicYear,
    this.classLevel,
    this.gpa,
    this.creditsTaken,
    this.totalCredits,
    this.tuitionFees,
    this.avatarUrl,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    print('🔍 Student.fromJson: Parsing student data...');
    print('🔍 Student.fromJson: id = ${json['id']} (${json['id'].runtimeType})');
    print('🔍 Student.fromJson: year_level = ${json['year_level']} (${json['year_level'].runtimeType})');
    print('🔍 Student.fromJson: credits_taken = ${json['credits_taken']} (${json['credits_taken']?.runtimeType})');
    print('🔍 Student.fromJson: total_credits = ${json['total_credits']} (${json['total_credits']?.runtimeType})');
    
    return Student(
      id: json['id'] as int,
      studentId: json['student_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      majorId: json['major_id'] as int?,
      major: json['major'] != null ? Major.fromJson(json['major'] as Map<String, dynamic>) : null,
      yearLevel: json['year_level'] as int,
      academicYear: json['academic_year'] as String?,
      classLevel: json['class'] as String?,
      gpa: json['gpa'] != null ? (json['gpa'] is String ? double.tryParse(json['gpa']) : (json['gpa'] as num).toDouble()) : null,
      creditsTaken: json['credits_taken'] != null ? (json['credits_taken'] is int ? json['credits_taken'] : int.tryParse(json['credits_taken'].toString())) : null,
      totalCredits: json['total_credits'] != null ? (json['total_credits'] is int ? json['total_credits'] : int.tryParse(json['total_credits'].toString())) : null,
      tuitionFees: json['tuition_fees'] != null ? (json['tuition_fees'] is String ? double.tryParse(json['tuition_fees']) : (json['tuition_fees'] as num).toDouble()) : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'email': email,
      'major_id': majorId,
      'major': major?.toJson(),
      'year_level': yearLevel,
      'academic_year': academicYear,
      'class': classLevel,
      'gpa': gpa,
      'credits_taken': creditsTaken,
      'total_credits': totalCredits,
      'tuition_fees': tuitionFees,
      'avatar_url': avatarUrl,
    };
  }

  String get majorName => major?.name ?? 'Unknown Major';
  String get majorCode => major?.code ?? 'N/A';
  int get creditsRemaining => (totalCredits ?? 0) - (creditsTaken ?? 0);
}
