/// Local transaction row used by expense tracking (income or expense).
class ExpenseTransaction {
  final int id;
  final double amount;
  final String date;
  final String type;
  final String? notes;
  final int accountId;
  final int categoryId;
  final String accountName;
  final String categoryName;
  final bool isRecurring;
  final String? recurrenceInterval;

  const ExpenseTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    this.notes,
    required this.accountId,
    required this.categoryId,
    required this.accountName,
    required this.categoryName,
    this.isRecurring = false,
    this.recurrenceInterval,
  });

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: (map['id'] as num).toInt(),
      amount: (map['amount'] as num).toDouble(),
      date: map['date']?.toString() ?? '',
      type: map['type']?.toString() ?? 'expense',
      notes: map['notes']?.toString(),
      accountId: (map['account_id'] as num).toInt(),
      categoryId: (map['category_id'] as num).toInt(),
      accountName: map['account_name']?.toString() ?? '',
      categoryName: map['category_name']?.toString() ?? '',
      isRecurring: map['is_recurring'] == true ||
          (map['is_recurring'] as num?)?.toInt() == 1,
      recurrenceInterval: map['recurrence_interval']?.toString(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'amount': amount,
      'date': date,
      'type': type,
      'notes': notes,
      'account_id': accountId,
      'category_id': categoryId,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_interval': recurrenceInterval,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'type': type,
      'notes': notes,
      'account_id': accountId,
      'category_id': categoryId,
      'account_name': accountName,
      'category_name': categoryName,
      'is_recurring': isRecurring,
      'recurrence_interval': recurrenceInterval,
    };
  }
}

/// Budget snapshot linked to a transaction date/account.
class BudgetSnapshot {
  final double budgetAmount;
  final double spentAmount;
  final double remaining;
  final bool isOverBudget;

  const BudgetSnapshot({
    required this.budgetAmount,
    required this.spentAmount,
    required this.remaining,
    required this.isOverBudget,
  });
}

/// Result of a write operation with optional budget feedback.
class ExpenseWriteResult {
  final int transactionId;
  final BudgetSnapshot? budgetSnapshot;
  final String? budgetMessage;

  const ExpenseWriteResult({
    required this.transactionId,
    this.budgetSnapshot,
    this.budgetMessage,
  });
}
