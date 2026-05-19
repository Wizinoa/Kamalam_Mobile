class TermsModel {
  final String id;
  final String type;
  final String title;
  final String content;
  final int displayOrder;
  final String status;
  final String createdAt;
  final String updatedAt;

  const TermsModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.displayOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'title': title,
        'content': content,
        'display_order': displayOrder,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}