// ignore_for_file: file_names

class NotificationModel {
  final String id;
  final String icon;
  final String title;
  final String cta;
  final String image;
  final String type;
  final String target;
  final bool isRead;
  final bool isActive;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.cta,
    required this.image,
    required this.type,
    required this.target,
    required this.isRead,
    required this.isActive,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["_id"] ?? "",
      icon: json["icon"] ?? "",
      title: json["title"] ?? "",
      cta: json["cta"] ?? "",
      image: json["image"] ?? "",
      type: json["type"] ?? "",
      target: json["target"] ?? "",
      isRead: json["isRead"] ?? false,
      isActive: json["isActive"] ?? false,
      status: json["status"] ?? "",
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

