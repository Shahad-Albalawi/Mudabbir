import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/services/financial_aggregator.dart';
import 'package:mudabbir/domain/services/repository_guard.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

class HomeRepository {
  HomeRepository({required DbHelper db})
      : _aggregator = FinancialAggregator(db: db);

  final FinancialAggregator _aggregator;

  Future<double> getTotalIncome({String? startDate, String? endDate}) async {
    final result = await guardRepository(
      () => _aggregator.sumByType('income', startDate: startDate, endDate: endDate),
      fallbackMessage: AppStrings.snackErrorTitle,
    );
    return result.fold((_) => 0, (value) => value);
  }

  Future<double> getTotalExpense({String? startDate, String? endDate}) async {
    final result = await guardRepository(
      () => _aggregator.sumByType('expense', startDate: startDate, endDate: endDate),
      fallbackMessage: AppStrings.snackErrorTitle,
    );
    return result.fold((_) => 0, (value) => value);
  }
}
