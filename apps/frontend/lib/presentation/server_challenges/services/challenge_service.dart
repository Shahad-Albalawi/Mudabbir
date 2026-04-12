import 'package:dio/dio.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/presentation/server_challenges/utils/dio_client.dart';

class ChallengeService {
  final DioClient _dioClient;

  ChallengeService(this._dioClient);

  // Get all challenges
  Future<List<ChallengeModel>> getChallenges() async {
    devLog('[Challenge API] GET /challenges - starting');
    try {
      final response = await _dioClient.dio.get('/challenges');
      devLog(
        '[Challenge API] GET /challenges - status: ${response.statusCode}',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => ChallengeModel.fromJson(json)).toList();
      }

      devLog(
        '[Challenge API] GET /challenges - unexpected response: ${response.data}',
      );
      throw ApiException(message: 'Failed to load challenges');
    } on DioException catch (e) {
      devLog(
        '[Challenge API] GET /challenges - DioException: ${e.type} ${e.message} status: ${e.response?.statusCode}',
      );
      throw ApiException.fromDioError(e);
    } catch (e, stack) {
      devLog('[Challenge API] GET /challenges - Error: $e\n$stack');
      rethrow;
    }
  }

  // Get single challenge
  Future<ChallengeModel> getChallenge(int id) async {
    try {
      final response = await _dioClient.dio.get('/challenges/$id');

      if (response.data['success'] == true) {
        return ChallengeModel.fromJson(response.data['data']);
      }

      throw ApiException(message: 'Failed to load challenge');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Create challenge
  Future<ChallengeModel> createChallenge({
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/challenges',
        data: {
          'name': name,
          'amount': amount,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.data['success'] == true) {
        return ChallengeModel.fromJson(response.data['data']);
      }

      throw ApiException(message: 'Failed to create challenge');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Update challenge
  Future<ChallengeModel> updateChallenge({
    required int id,
    String? name,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (amount != null) data['amount'] = amount;
      if (startDate != null) {
        data['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        data['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dioClient.dio.put('/challenges/$id', data: data);

      if (response.data['success'] == true) {
        return ChallengeModel.fromJson(response.data['data']);
      }

      throw ApiException(message: 'Failed to update challenge');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Delete challenge
  Future<void> deleteChallenge(int id) async {
    try {
      final response = await _dioClient.dio.delete('/challenges/$id');

      if (response.data['success'] != true) {
        throw ApiException(message: 'Failed to delete challenge');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Invite user to challenge
  Future<ChallengeModel> inviteUser({
    required int challengeId,
    required String email,
  }) async {
    final sanitizedEmail = email.trim();
    if (sanitizedEmail.isEmpty) {
      throw ApiException(
        message: 'Email is required to send an invitation.',
        statusCode: 422,
      );
    }

    if (!_isValidEmail(sanitizedEmail)) {
      throw ApiException(
        message: 'Please enter a valid email address.',
        statusCode: 422,
      );
    }

    final endpoints = [
      '/challenges/$challengeId/invite',
      '/challenges/$challengeId/invitations',
    ];

    DioException? lastDioError;

    for (final endpoint in endpoints) {
      devLog('[Challenge API] POST $endpoint invite for $sanitizedEmail');
      try {
        final response = await _dioClient.dio.post(
          endpoint,
          data: {'email': sanitizedEmail},
        );

        final challenge = _parseInviteResponse(response.data);
        if (challenge != null) {
          return challenge;
        }

        throw ApiException(
          message:
              'Unexpected server response while sending the invitation.',
          statusCode: response.statusCode,
        );
      } on DioException catch (e) {
        lastDioError = e;
        final code = e.response?.statusCode;
        // Keep trying fallback endpoint only for "possibly wrong route" cases.
        if (code == 404 || code == 405) {
          continue;
        }
        throw ApiException.fromDioError(e);
      }
    }

    if (lastDioError != null) {
      throw ApiException.fromDioError(lastDioError);
    }

    throw ApiException(message: 'Failed to invite user');
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  ChallengeModel? _parseInviteResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    // Common Laravel shape: { success: true, data: {...challenge...} }
    if (data['success'] == true && data['data'] is Map<String, dynamic>) {
      return ChallengeModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    // Some backends may return challenge directly.
    if (data['id'] != null &&
        data['name'] != null &&
        data['participants'] != null) {
      return ChallengeModel.fromJson(data);
    }

    return null;
  }

  // Remove participant
  Future<ChallengeModel> removeParticipant({
    required int challengeId,
    required int userId,
  }) async {
    try {
      final response = await _dioClient.dio.delete(
        '/challenges/$challengeId/participants/$userId',
      );

      if (response.data['success'] == true) {
        return ChallengeModel.fromJson(response.data['data']);
      }

      throw ApiException(message: 'Failed to remove participant');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Toggle challenge status
  Future<ChallengeModel> toggleStatus(int challengeId) async {
    try {
      final response = await _dioClient.dio.patch(
        '/challenges/$challengeId/status',
      );

      if (response.data['success'] == true) {
        return ChallengeModel.fromJson(response.data['data']);
      }

      throw ApiException(message: 'Failed to update status');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // NEW: Accept or reject invitation
  Future<ChallengeModel> respondToInvitation({
    required int challengeId,
    required String status, // 'accepted' or 'rejected'
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/challenges/$challengeId/respond',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return ChallengeModel.fromJson(response.data['data']);
      }

      throw ApiException(message: 'Failed to respond to invitation');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // NEW: Get pending invitations
  Future<List<ChallengeModel>> getPendingInvitations() async {
    try {
      final response = await _dioClient.dio.get(
        '/challenges/invitations/pending',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => ChallengeModel.fromJson(json)).toList();
      }

      throw ApiException(message: 'Failed to load pending invitations');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
