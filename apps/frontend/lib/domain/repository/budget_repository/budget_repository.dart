import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/service/getit_init.dart';

class BudgetRepository {
  Future<Either<Empty, List<Map<String, dynamic>>>> getBudgets() async {
    return getIt<DbHelper>().queryAllRows('budgets');
  }

  Future<int> removeBudget(int id) async {
    return await getIt<DbHelper>().delete('budgets', 'id=?', [id]);
  }

  Future<int> addBudget(Map<String, dynamic> data) async {
    return await getIt<DbHelper>().insert('budgets', data);
  }
}
