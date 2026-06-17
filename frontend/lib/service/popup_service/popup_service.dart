import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mudabbir/service/popup_service/budget_popup.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/transaction_popup.dart';

/// Central entry for add/edit popups (expense, income, budget, goal).
class PopupService {
  final _transactionPopup = GetIt.I<TransactionPopup>();
  final _budgetPopup = GetIt.I<BudgetPopup>();
  final _goalPopup = GetIt.I<GoalPopup>();

  Future<void> showAddIncomePopup(BuildContext context) async {
    await _transactionPopup.show(context, type: 'income');
  }

  Future<void> showAddExpensePopup(BuildContext context) async {
    await _transactionPopup.show(context, type: 'expense');
  }

  Future<void> showAddBudgetPopup(BuildContext context, WidgetRef ref) async {
    await _budgetPopup.show(context, ref);
  }

  Future<void> showAddGoalPopup(BuildContext context, WidgetRef ref) async {
    await _goalPopup.show(context, ref);
  }
}
