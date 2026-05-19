class FaqModel {
  final String id;
  final String type;
  final String title;
  final String content;
  final int displayOrder;
  final String status;
  final String redirectUrl;
  final String createdAt;
  final String updatedAt;

  const FaqModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.displayOrder,
    required this.status,
    required this.redirectUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      status: json['status'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}