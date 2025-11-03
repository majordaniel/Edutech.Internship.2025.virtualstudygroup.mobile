class StudyGroup {
  final int id;
  final String groupName;
  final int courseId;
  final int createdBy;
  final String description;
  final String createdAt;
  final String updatedAt;
  final bool isRestricted;

  StudyGroup({
    required this.id,
    required this.groupName,
    required this.courseId,
    required this.createdBy,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.isRestricted,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'],
      groupName: json['group_name'],
      courseId: json['course_id'],
      createdBy: json['created_by'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isRestricted: json['is_restricted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': groupName,
      'course_id': courseId,
      'created_by': createdBy,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_restricted': isRestricted,
    };
  }
}
