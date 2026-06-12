class AiMessage {
  final String id;
  final String text;
  final String sender; // "user" or "aurora"
  final DateTime timestamp;
  final bool isVoice;

  AiMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isVoice = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'isVoice': isVoice,
    };
  }

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      sender: json['sender'] ?? 'aurora',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isVoice: json['isVoice'] ?? false,
    );
  }
}
