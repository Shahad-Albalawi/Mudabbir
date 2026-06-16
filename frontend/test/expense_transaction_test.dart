import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';

void main() {
  test('ExpenseTransaction maps sqlite row', () {
    final tx = ExpenseTransaction.fromMap({
      'id': 3,
      'amount': 150.5,
      'date': '2026-05-10',
      'type': 'expense',
      'notes': 'غداء',
      'account_id': 1,
      'category_id': 2,
      'account_name': 'النقدية',
      'category_name': 'طعام',
      'is_recurring': 1,
      'recurrence_interval': 'monthly',
    });

    expect(tx.id, 3);
    expect(tx.amount, 150.5);
    expect(tx.isRecurring, isTrue);
    expect(tx.recurrenceInterval, 'monthly');
    expect(tx.toInsertMap()['is_recurring'], 1);
  });
}
