class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? createdAt;
  NotificationModel({required this.id, required this.title, required this.message,
    required this.type, required this.isRead, this.createdAt});
  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'], title: json['title'] ?? '', message: json['message'] ?? '',
    type: json['type'] ?? 'SYSTEM', isRead: json['isRead'] ?? false, createdAt: json['createdAt'],
  );
}
