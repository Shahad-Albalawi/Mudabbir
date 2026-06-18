import 'package:dio/dio.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/presentation/server_challenges/utils/dio_client.dart';

/// REST client for savings goals.
class GoalApiService {
  final DioClient _dioClient;

  GoalApiService(this._dioClient);

  Future<List<SavingsGoal>> getGoals() async {
    try {
      final response = await _dioClient.dio.get('/goals');
      if (response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => _goalFromApi(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      throw ApiException(message: 'Failed to load goals');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SavingsGoal> createGoal(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.post('/goals', data: payload);
      if (response.data['success'] == true) {
        return _goalFromApi(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to create goal');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SavingsGoal> updateGoal(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.put('/goals/$id', data: payload);
      final body = response.data;
      if (response.statusCode == 409 && body is Map<String, dynamic>) {
        throw ApiException(
          message: body['message'] as String? ?? 'Sync conflict',
          statusCode: 409,
          conflictData: body['data'],
        );
      }
      if (body is Map && body['success'] == true) {
        return _goalFromApi(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to update goal');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SavingsGoal> addContribution({
    required int goalId,
    required double amount,
    String? note,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/goals/$goalId/contributions',
        data: {
          'amount': amount,
          if (note != null) 'note': note,
        },
      );
      if (response.data['success'] == true) {
        return _goalFromApi(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to add contribution');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      final response = await _dioClient.dio.delete('/goals/$id');
      if (response.data['success'] == true) return;
      throw ApiException(message: 'Failed to delete goal');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  SavingsGoal _goalFromApi(Map<String, dynamic> map) {
    final contributions = <GoalContributionRecord>[];
    final rawContribs = map['contributions'];
    if (rawContribs is List) {
      for (final raw in rawContribs) {
        if (raw is! Map) continue;
        final c = Map<String, dynamic>.from(raw);
        contributions.add(
          GoalContributionRecord(
            id: (c['id'] as num).toInt(),
            goalId: (c['goal_id'] as num).toInt(),
            amount: (c['amount'] as num).toDouble(),
            contributedAt: DateTime.parse(c['contributed_at'] as String),
            note: c['note'] as String?,
          ),
        );
      }
    }

    final apiMap = Map<String, dynamic>.from(map);
    apiMap['is_completed'] =
        map['is_completed'] == true ? 1 : (map['is_completed'] as int? ?? 0);

    return SavingsGoal.fromMap(apiMap, contributions: contributions);
  }
}
