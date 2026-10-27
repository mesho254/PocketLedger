class SavingsContributionModel {
  final String id;
  final double amount;
  final DateTime contributionDate;
  final String? note;
  final DateTime? createdAt;

  SavingsContributionModel({
    required this.id,
    required this.amount,
    required this.contributionDate,
    this.note,
    this.createdAt,
  });

  factory SavingsContributionModel.fromJson(Map<String, dynamic> json) {
    return SavingsContributionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      contributionDate: json['contributionDate'] != null
          ? DateTime.parse(json['contributionDate'].toString())
          : DateTime.now(),
      note: json['note'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String status;
  final double percentageCompleted;
  final DateTime? createdAt;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.status,
    required this.percentageCompleted,
    this.createdAt,
  });

  bool get isCompleted => status == 'COMPLETED';

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'].toString())
          : null,
      status: json['status'] ?? 'IN_PROGRESS',
      percentageCompleted: (json['percentageCompleted'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
