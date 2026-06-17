import 'package:mudabbir/domain/services/financial_aggregator.dart';

class HomeRepository {
  final FinancialAggregator _aggregator = FinancialAggregator();

  Future<double> getTotalIncome({String? startDate, String? endDate}) =>
      _aggregator.sumByType('income', startDate: startDate, endDate: endDate);

  Future<double> getTotalExpense({String? startDate, String? endDate}) =>
      _aggregator.sumByType('expense', startDate: startDate, endDate: endDate);
}
