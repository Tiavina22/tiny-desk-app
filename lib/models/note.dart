class Note {
  final int? id;
  final String title;
  final String? description;
  final String note;
  final int userId;
  final DateTime createdAt;

  Note({
    this.id,
    required this.title,
    this.description,
    required this.note,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'note': note,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      note: map['note'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
} 