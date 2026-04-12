import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/service/getit_init.dart';

class GoalsRepository {
  Future<Either<Empty, List<Map<String, dynamic>>>> getGoals() async {
    return getIt<DbHelper>().queryAllRows('goals');
  }

  Future<int> removeGoal(int id) async {
    return await getIt<DbHelper>().delete('goals', 'id=?', [id]);
  }

  Future<int> addGoal(Map<String, dynamic> data) async {
    return await getIt<DbHelper>().insert('goals', data);
  }

  // New method to update goal's current amount
  Future<int> updateGoalAmount(int goalId, double newCurrentAmount) async {
    return await getIt<DbHelper>().update(
      'goals',
      {'current_amount': newCurrentAmount},
      'id=?',
      [goalId],
    );
  }
}
