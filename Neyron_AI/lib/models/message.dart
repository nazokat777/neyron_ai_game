enum MessageRole { user, professor }

class Message {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isFromProfessor => role == MessageRole.professor;

  Map<String, dynamic> toJson() => {
        'text': text,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    final raw = json['role'] as String;
    // Backwards-compat: oldingi versiyalardagi 'boboAql' yozuvi
    final normalized = raw == 'boboAql' ? 'professor' : raw;
    return Message(
      text: json['text'] as String,
      role: MessageRole.values.firstWhere((e) => e.name == normalized),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
