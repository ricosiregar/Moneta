class TransactionModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String? walletId;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final DateTime date;
  final String? note;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  const TransactionModel({
    required this.id,
    required this.userId,
    this.categoryId,
    this.walletId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Join dengan categories jika ada
    final category = json['categories'] as Map<String, dynamic>?;

    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      walletId: json['wallet_id'] as String?,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String).toLocal(),
      note: json['note'] as String?,
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
    );
  }
}
