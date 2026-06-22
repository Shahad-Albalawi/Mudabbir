/// Monthly spending limit synced with the Laravel API.
class BudgetRecord {
  final int id;
  final double amount;
  final String startDate;
  final String endDate;
  final int accountId;
  final String? updatedAt;

  const BudgetRecord({
    required this.id,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.accountId,
    this.updatedAt,
  });

  factory BudgetRecord.fromMap(Map<String, dynamic> map) {
    return BudgetRecord(
      id: (map['id'] as num).toInt(),
      amount: (map['amount'] as num).toDouble(),
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      accountId: (map['account_id'] as num).toInt(),
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'start_date': startDate,
        'end_date': endDate,
        'account_id': accountId,
        if (updatedAt != null) 'updated_at': updatedAt,
      };

  Map<String, dynamic> toInsertMap() => {
        'amount': amount,
        'start_date': startDate,
        'end_date': endDate,
        'account_id': accountId,
        if (updatedAt != null) 'updated_at': updatedAt,
      };
}
