class BudgetProgressModel {
  final String id;
  final String category;
  final double monthlyLimit;
  final double actualSpent;
  final double remaining;
  final double percentageSpent;
  final String status; // "SAFE", "WARNING_80", "EXCEEDED"

  BudgetProgressModel({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.actualSpent,
    required this.remaining,
    required this.percentageSpent,
    required this.status,
  });

  bool get isExceeded => status == 'EXCEEDED';
  bool get isWarning => status == 'WARNING_80';

  factory BudgetProgressModel.fromJson(Map<String, dynamic> json) {
    return BudgetProgressModel(
      id: json['id']?.toString() ?? '',
      category: json['category'] ?? '',
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      actualSpent: (json['actualSpent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      percentageSpent: (json['percentageSpent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'SAFE',
    );
  }
}
