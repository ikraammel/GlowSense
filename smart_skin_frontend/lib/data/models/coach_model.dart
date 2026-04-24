class CoachMessageModel {
  final int? id;
  final String role;
  final String content;
  final String? sessionId;
  final String? sentAt;
  CoachMessageModel({this.id, required this.role, required this.content, this.sessionId, this.sentAt});
  factory CoachMessageModel.fromJson(Map<String, dynamic> json) => CoachMessageModel(
    id: json['id'], role: json['role'] ?? 'user',
    content: json['content'] ?? '', sessionId: json['sessionId'], sentAt: json['sentAt'],
  );
  bool get isUser => role == 'user';
}
