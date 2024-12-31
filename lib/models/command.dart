class Command {
  final int? id;
  final String title;
  final String? description;
  final String command;
  final int userId;
  final DateTime createdAt;

  Command({
    this.id,
    required this.title,
    this.description,
    required this.command,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'command': command,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Command fromMap(Map<String, dynamic> map) {
    return Command(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      command: map['command'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
} 