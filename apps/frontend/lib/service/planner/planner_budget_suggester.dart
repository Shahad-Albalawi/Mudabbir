import 'package:mudabbir/domain/repository/planner_repository/planner_repository.dart';

/// Rule-based “AI” split: blend historical averages with 50/30/20 style buckets.
class PlannerBudgetSuggester {
  PlannerBudgetSuggester(this._repo);

  final PlannerRepository _repo;

  static const _essentials = {'طعام', 'نقل', 'فواتير', 'صحة', 'Rent', 'Food', 'Transport'};
  static const _wants = {'تسوق', 'ترفيه', 'اخرى', 'Shopping', 'Entertainment', 'Other'};

  static double _bucketWeight(String name, {required double need, required double want}) {
    final n = name.trim();
    if (_essentials.contains(n)) return need;
    if (_wants.contains(n)) return want;
    return (need + want) / 2;
  }

  /// Returns suggested monthly limit per category id.
  Future<Map<int, double>> suggestForMonth({
    required DateTime now,
    required double monthlyIncome,
  }) async {
    final cats = await _repo.getExpenseCategories();
    if (cats.isEmpty || monthlyIncome <= 0) return {};

    final hist = await _repo.averageExpenseByCategoryLastMonths(now, 3);
    var histTotal = hist.values.fold(0.0, (a, b) => a + b);
    if (histTotal <= 0) histTotal = 0;

    final budgetPool = monthlyIncome * 0.9;
    final n = cats.length;
    var sumW = 0.0;
    for (final c in cats) {
      final name = c['name']?.toString() ?? '';
      sumW += _bucketWeight(name, need: 0.5, want: 0.3);
    }
    if (sumW <= 0) sumW = 1;

    final out = <int, double>{};
    for (final c in cats) {
      final id = c['id'] as int;
      final name = c['name']?.toString() ?? '';
      final avg = hist[id] ?? 0;
      final share = histTotal > 0 ? avg / histTotal : 1.0 / n;
      final historicalPart = budgetPool * share;

      final w = _bucketWeight(name, need: 0.5, want: 0.3);
      final rulePart = budgetPool * (w / sumW);

      out[id] = (0.5 * historicalPart + 0.5 * rulePart).clamp(0, budgetPool);
    }
    return out;
  }
}
