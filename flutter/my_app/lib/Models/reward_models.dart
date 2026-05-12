class RewardModel {

  final int id;
  final String type;
  final double amount;
  final DateTime date;
  final String description;

  RewardModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory RewardModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return RewardModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(
        json['date'],
      ),
      description: json['description'] ?? '',
    );
  }
}