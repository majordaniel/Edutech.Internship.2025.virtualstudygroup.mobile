class Course {
  final int id;
  final String courseName;
  final String courseCode;
  final String courseDescription;
  final int creditUnits;
  final String semester;
  final String level;
  final String department;
  final String createdAt;
  final String updatedAt;

  Course({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.courseDescription,
    required this.creditUnits,
    required this.semester,
    required this.level,
    required this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    print('🔧 Parsing course JSON: $json');

    // Handle Credit_units as both String and int
    int parseCreditUnits(dynamic creditUnits) {
      if (creditUnits is int) return creditUnits;
      if (creditUnits is String) {
        return int.tryParse(creditUnits) ?? 0;
      }
      return 0;
    }

    return Course(
      id: json['id'] as int? ?? 0,
      courseName: json['course_name']?.toString() ?? 'Unknown Course',
      courseCode: json['course_code']?.toString() ?? 'N/A',
      courseDescription: json['course_description']?.toString() ?? '',
      creditUnits: parseCreditUnits(json['Credit_units']),
      semester: json['semester']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  String get displayName => '$courseCode - $courseName';

  @override
  String toString() => displayName;
}
