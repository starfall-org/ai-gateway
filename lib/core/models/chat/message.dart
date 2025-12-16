enum ChatRole { user, model, system, tool }

class Message {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final List<String> attachments;

  Message({
    required this.id,
    required this.role,
    this.content = '',
    DateTime? timestamp,
    this.attachments = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: ChatRole.values.firstWhere((e) => e.name == json['role']),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
