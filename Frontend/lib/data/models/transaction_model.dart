class TransactionModel {
  final String id;
  final double amount;
  final String type; // INCOME or EXPENSE
  final String category;
  final DateTime transactionDate;
  final String? description;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    this.description,
    this.createdAt,
  });

  bool get isIncome => type == 'INCOME';
  bool get isExpense => type == 'EXPENSE';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'EXPENSE',
      category: json['category'] ?? 'OTHER',
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'].toString())
          : DateTime.now(),
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type,
        'category': category,
        'transactionDate':
            "${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}",
        if (description != null) 'description': description,
      };
}
