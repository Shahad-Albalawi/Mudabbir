import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/domain/services/sync_policies.dart';
import 'package:mudabbir/presentation/resources/goal_strings.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class GoalWriteResult {
  final SavingsGoal goal;
  final bool newlyCompleted;

  const GoalWriteResult({
    required this.goal,
    this.newlyCompleted = false,
  });
}

/// CRUD, contributions, and image persistence for savings goals.
class GoalsRepository {
  final DbHelper _db = getIt<DbHelper>();

  Future<Either<Failure, List<SavingsGoal>>> getGoals() async {
    try {
      final goalsResult = await _db.queryAllRows('goals');
      return await goalsResult.fold(
        (_) async => const Right([]),
        (rows) async {
          final goals = <SavingsGoal>[];
          for (final row in rows) {
            final contributions = await _contributionsForGoal(row['id'] as int);
            goals.add(
              SavingsGoal.fromMap(
                Map<String, dynamic>.from(row),
                contributions: contributions,
              ),
            );
          }
          goals.sort((a, b) => b.endDate.compareTo(a.endDate));
          return Right(goals);
        },
      );
    } catch (_) {
      return Left(UnknownFailure(GoalStrings.updateFailed));
    }
  }

  Future<Either<Failure, SavingsGoal>> createGoal({
    required String name,
    required double target,
    required double currentAmount,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? imageSourcePath,
  }) async {
    try {
      if (name.trim().isEmpty || target <= 0) {
        return Left(ValidationFailure(GoalStrings.nameRequired));
      }

      String? storedImagePath;
      if (imageSourcePath != null && imageSourcePath.isNotEmpty) {
        storedImagePath = await _persistImage(imageSourcePath);
      }

      final id = await _db.insert('goals', {
        'name': name.trim(),
        'target': target,
        'current_amount': currentAmount.clamp(0, target),
        'type': type,
        'start_date': _isoDate(startDate),
        'end_date': _isoDate(endDate),
        'image_path': storedImagePath,
        'is_completed': currentAmount >= target ? 1 : 0,
        'completed_at':
            currentAmount >= target ? DateTime.now().toIso8601String() : null,
      });

      if (currentAmount > 0) {
        await _db.insert('goal_contributions', {
          'goal_id': id,
          'amount': currentAmount,
          'contributed_at': DateTime.now().toIso8601String(),
          'note': null,
        });
      }

      final goalEither = await getGoalById(id);
      return goalEither.fold(Left.new, Right.new);
    } catch (_) {
      return Left(UnknownFailure(GoalStrings.createFailed));
    }
  }

  Future<Either<Failure, GoalWriteResult>> addContribution({
    required int goalId,
    required double amount,
    String? note,
  }) async {
    try {
      if (amount <= 0) {
        return Left(ValidationFailure(GoalStrings.invalidAmount));
      }

      final goalEither = await getGoalById(goalId);
      return goalEither.fold(Left.new, (goal) async {
        if (goal.isCompleted) {
          return Left(ValidationFailure(GoalStrings.updateFailed));
        }

        final newAmount = (goal.currentAmount + amount).clamp(0, goal.target);
        final reached = newAmount >= goal.target;

        await _db.insert('goal_contributions', {
          'goal_id': goalId,
          'amount': amount,
          'contributed_at': DateTime.now().toIso8601String(),
          'note': note,
        });

        await _db.update(
          'goals',
          {
            'current_amount': newAmount,
            'is_completed': reached ? 1 : 0,
            'completed_at': reached ? DateTime.now().toIso8601String() : null,
          },
          'id = ?',
          [goalId],
        );

        final updatedEither = await getGoalById(goalId);
        return updatedEither.fold(
          Left.new,
          (updated) => Right(
            GoalWriteResult(
              goal: updated,
              newlyCompleted: reached && !goal.isCompleted,
            ),
          ),
        );
      });
    } catch (_) {
      return Left(UnknownFailure(GoalStrings.updateFailed));
    }
  }

  Future<Either<Failure, bool>> deleteGoal(int id) async {
    try {
      final deleted = await _db.delete('goals', 'id = ?', [id]);
      return Right(deleted > 0);
    } catch (_) {
      return Left(UnknownFailure(GoalStrings.updateFailed));
    }
  }

  Future<Either<Failure, SavingsGoal>> getGoalById(int id) async {
    final result = await _db.queryRow('goals', 'id = ?', [id]);
    return await result.fold(
      (_) async => Left(UnknownFailure(GoalStrings.updateFailed)),
      (rows) => _mapGoalRow(rows.first, id),
    );
  }

  Future<Either<Failure, SavingsGoal>> _mapGoalRow(
    Map<String, dynamic> row,
    int id,
  ) async {
    final contributions = await _contributionsForGoal(id);
    return Right(
      SavingsGoal.fromMap(
        Map<String, dynamic>.from(row),
        contributions: contributions,
      ),
    );
  }

  Future<List<GoalContributionRecord>> _contributionsForGoal(int goalId) async {
    final result = await _db.complexQuery(
      table: 'goal_contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'contributed_at ASC',
    );
    return result.fold(
      (_) => <GoalContributionRecord>[],
      (rows) => rows.map(GoalContributionRecord.fromMap).toList(),
    );
  }

  Future<String?> _persistImage(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) return null;

    final docs = await getApplicationDocumentsDirectory();
    final goalsDir = Directory(p.join(docs.path, 'goal_images'));
    if (!await goalsDir.exists()) {
      await goalsDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath);
    final fileName = 'goal_${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(goalsDir.path, fileName));
    await source.copy(dest.path);
    return dest.path;
  }

  String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // Legacy helpers kept for backward compatibility.
  Future<Either<Empty, List<Map<String, dynamic>>>> getGoalsRaw() async {
    return _db.queryAllRows('goals');
  }

  Future<int> removeGoal(int id) async {
    return _db.delete('goals', 'id=?', [id]);
  }

  Future<int> addGoal(Map<String, dynamic> data) async {
    return _db.insert('goals', data);
  }

  Future<int> updateGoalAmount(int goalId, double newCurrentAmount) async {
    return _db.update(
      'goals',
      {'current_amount': newCurrentAmount},
      'id=?',
      [goalId],
    );
  }

  /// Merges server goals (and contributions) into local SQLite.
  Future<void> mergeServerGoals(List<SavingsGoal> goals) async {
    for (final goal in goals) {
      await _db.insertOrReplace('goals', {
        'id': goal.id,
        'name': goal.name,
        'target': goal.target,
        'current_amount': goal.currentAmount,
        'type': goal.type,
        'start_date': _isoDate(goal.startDate),
        'end_date': _isoDate(goal.endDate),
        'image_path': goal.imagePath,
        'is_completed': goal.isCompleted ? 1 : 0,
        'completed_at': goal.completedAt?.toIso8601String(),
      });

      await _db.delete('goal_contributions', 'goal_id = ?', [goal.id]);
      for (final c in goal.contributions) {
        await _db.insertOrReplace('goal_contributions', {
          'id': c.id,
          'goal_id': c.goalId,
          'amount': c.amount,
          'contributed_at': c.contributedAt.toIso8601String(),
          'note': c.note,
        });
      }
    }
  }

  Future<void> replaceLocalGoalId(int localId, SavingsGoal serverGoal) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete(
        'goal_contributions',
        where: 'goal_id = ?',
        whereArgs: [localId],
      );
      await txn.delete(
        'goals',
        where: 'id = ?',
        whereArgs: [localId],
      );
      await txn.insert(
        'goals',
        {
          'id': serverGoal.id,
          'name': serverGoal.name,
          'target': serverGoal.target,
          'current_amount': serverGoal.currentAmount,
          'type': serverGoal.type,
          'start_date': _isoDate(serverGoal.startDate),
          'end_date': _isoDate(serverGoal.endDate),
          'image_path': serverGoal.imagePath,
          'is_completed': serverGoal.isCompleted ? 1 : 0,
          'completed_at': serverGoal.completedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final c in serverGoal.contributions) {
        await txn.insert(
          'goal_contributions',
          {
            'id': c.id,
            'goal_id': c.goalId,
            'amount': c.amount,
            'contributed_at': c.contributedAt.toIso8601String(),
            'note': c.note,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> pruneExceptServerIds(
    Set<int> serverIds,
    Set<int> protectedIds,
  ) async {
    final rowsResult = await _db.queryAllRows('goals');
    await rowsResult.fold((_) async {}, (rows) async {
      final localIds = rows.map((r) => (r['id'] as num).toInt());
      final toRemove = idsToPrune(
        localIds: localIds,
        serverIds: serverIds,
        protectedIds: protectedIds,
      );
      for (final id in toRemove) {
        await _db.delete('goal_contributions', 'goal_id = ?', [id]);
        await _db.delete('goals', 'id = ?', [id]);
      }
    });
  }

  Future<List<int>> listGoalIds() async {
    final rowsResult = await _db.queryAllRows('goals');
    return rowsResult.fold(
      (_) => <int>[],
      (rows) => rows.map((r) => (r['id'] as num).toInt()).toList(),
    );
  }
}
