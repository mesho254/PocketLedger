class CategoryBreakdownModel {
  final String category;
  final double amount;
  final double percentage;

  CategoryBreakdownModel({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      category: json['category'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MonthlySummaryModel {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRatePercentage;
  final List<CategoryBreakdownModel> categoryBreakdown;

  MonthlySummaryModel({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRatePercentage,
    required this.categoryBreakdown,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    final list = json['categoryBreakdown'] as List? ?? [];
    return MonthlySummaryModel(
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netSavings: (json['netSavings'] as num?)?.toDouble() ?? 0.0,
      savingsRatePercentage: (json['savingsRatePercentage'] as num?)?.toDouble() ?? 0.0,
      categoryBreakdown: list.map((e) => CategoryBreakdownModel.fromJson(e)).toList(),
    );
  }
}
