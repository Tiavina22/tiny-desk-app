class Code {
  final int? id;
  final String title;
  final String? description;
  final String code;
  final int userId;
  final DateTime createdAt;

  Code({
    this.id,
    required this.title,
    this.description,
    required this.code,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Code fromMap(Map<String, dynamic> map) {
    return Code(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      code: map['code'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
} 