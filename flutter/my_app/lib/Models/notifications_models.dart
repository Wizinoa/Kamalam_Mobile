// ignore_for_file: file_names

class NotificationModel {
  final String id;
  final String icon;
  final String title;
  final String cta;
  final String image;
  final String description;
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
    required this.description,
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
    description: json["description"] ?? "",
    target: json["target"] ?? "",
    isRead: json["isRead"] ?? false,
    isActive: json["isActive"] ?? false,
    status: json["status"] ?? "",
    startDate: json["startDate"] != null 
        ? DateTime.parse(json["startDate"]) 
        : DateTime.now(),
    endDate: json["endDate"] != null 
        ? DateTime.parse(json["endDate"]) 
        : DateTime.now(),
    createdAt: json["createdAt"] != null 
        ? DateTime.parse(json["createdAt"]) 
        : DateTime.now(),
    updatedAt: json["updatedAt"] != null 
        ? DateTime.parse(json["updatedAt"]) 
        : DateTime.now(),
  );
}
}

