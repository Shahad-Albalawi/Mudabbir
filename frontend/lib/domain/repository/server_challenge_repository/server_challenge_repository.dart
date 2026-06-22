import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/domain/models/challenge_sync_result.dart';
import 'package:mudabbir/domain/services/repository_guard.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/presentation/server_challenges/services/challenge_service.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/current_server_user_id.dart';

/// Offline-first sync between Laravel challenges API and Hive cache.
class ServerChallengeRepository {
  final ChallengeService _remote;
  final ChallengeHiveCache _cache;

  ServerChallengeRepository({
    ChallengeService? remote,
    ChallengeHiveCache? cache,
  })  : _remote = remote ?? getIt<ChallengeService>(),
        _cache = cache ?? getIt<ChallengeHiveCache>();

  Future<ChallengeListSyncResult> getChallenges() {
    return guardSyncedOperation(() async {
      final cached = _cache.getChallengesList();

      try {
        final remote = await _remote.getChallenges();
        await _cache.saveChallengesList(
          remote.map((c) => c.toJson()).toList(),
        );
        await flushPendingProgress();
        return ChallengeListSyncResult(challenges: remote);
      } on ApiException catch (e) {
        if (e.isNetworkError && cached != null) {
          return ChallengeListSyncResult(
            challenges: cached.map(ChallengeModel.fromJson).toList(),
            fromCache: true,
            isOffline: true,
          );
        }
        rethrow;
      }
    }, fallbackMessage: ServerChallengeStrings.loadFailed);
  }

  Future<ChallengeSyncResult> getChallenge(int id) {
    return guardSyncedOperation(() async {
      final cachedMap = _cache.getChallenge(id);

      try {
        final remote = await _remote.getChallenge(id);
        await _cache.upsertChallenge(remote.toJson());
        return ChallengeSyncResult(challenge: remote);
      } on ApiException catch (e) {
        if (e.isNetworkError && cachedMap != null) {
          return ChallengeSyncResult(
            challenge: ChallengeModel.fromJson(cachedMap),
            fromCache: true,
            isOffline: true,
          );
        }
        rethrow;
      }
    }, fallbackMessage: ServerChallengeStrings.loadFailed);
  }

  Future<ChallengeProgressResult> addProgress({
    required int challengeId,
    required double amount,
  }) {
    return guardSyncedOperation(() async {
      final userId = requireCurrentServerUserId();
      final localBefore = progressForChallenge(challengeId);
      final optimistic = localBefore + amount;
      await _cache.setLocalProgress(challengeId, optimistic);

      try {
        final challenge = await _remote.recordProgress(
          challengeId: challengeId,
          amount: amount,
        );
        await _cache.upsertChallenge(challenge.toJson());
        final progress = _progressFromChallenge(challenge, userId);
        await _cache.setLocalProgress(challengeId, progress);
        return ChallengeProgressResult(
          currentProgress: progress,
          challenge: challenge,
          syncedToServer: true,
        );
      } on ApiException catch (e) {
        if (e.isNetworkError) {
          await _cache.queuePendingProgress(
            challengeId: challengeId,
            amount: amount,
            userId: userId,
          );
          return ChallengeProgressResult(
            currentProgress: optimistic,
            syncedToServer: false,
            queuedOffline: true,
          );
        }
        await _cache.setLocalProgress(challengeId, localBefore);
        rethrow;
      }
    }, fallbackMessage: ServerChallengeStrings.syncFailed);
  }

  double progressForChallenge(int challengeId) {
    final userId = tryCurrentServerUserId();
    final cached = _cache.getChallenge(challengeId);
    if (cached != null && userId != null) {
      final fromServer = _progressFromMap(cached, userId);
      if (fromServer > 0) return fromServer;
    }
    return _cache.getLocalProgress(challengeId);
  }

  Future<void> flushPendingProgress() async {
    final ops = _cache.getPendingProgressOps();
    if (ops.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final op in ops) {
      final userId = op['user_id'];
      if (userId is! int && userId is! num) {
        continue;
      }
      final resolvedUserId = userId is int ? userId : userId.toInt();
      try {
        final challenge = await _remote.recordProgress(
          challengeId: op['challenge_id'] as int,
          amount: (op['amount'] as num).toDouble(),
        );
        await _cache.upsertChallenge(challenge.toJson());
        final progress = _progressFromChallenge(challenge, resolvedUserId);
        await _cache.setLocalProgress(op['challenge_id'] as int, progress);
      } on ApiException catch (e) {
        if (e.isNetworkError) {
          remaining.add(op);
        }
      }
    }
    await _cache.setPendingProgressOps(remaining);
  }

  // Pass-through operations (always require network; update cache on success).
  Future<ChallengeModel> createChallenge({
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final c = await _remote.createChallenge(
      name: name,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
    );
    await _cache.upsertChallenge(c.toJson());
    return c;
  }

  Future<ChallengeModel> createFromTemplate(String templateId) async {
    final c = await _remote.createFromTemplate(templateId);
    await _cache.upsertChallenge(c.toJson());
    return c;
  }

  Future<ChallengeCheckInResult> checkIn({
    required int challengeId,
  }) async {
    final result = await _remote.checkIn(
      challengeId: challengeId,
    );
    await _cache.upsertChallenge(result.challenge.toJson());
    return result;
  }

  Future<List<ChallengeTemplateModel>> getTemplates() =>
      _remote.getTemplates();

  Future<ChallengeLeaderboardModel> getLeaderboard(int challengeId) =>
      _remote.getLeaderboard(challengeId);

  Future<ChallengeModel> inviteUser({
    required int challengeId,
    required String email,
  }) async {
    final c = await _remote.inviteUser(challengeId: challengeId, email: email);
    await _cache.upsertChallenge(c.toJson());
    return c;
  }

  Future<ChallengeModel> removeParticipant({
    required int challengeId,
    required int userId,
  }) async {
    final c = await _remote.removeParticipant(
      challengeId: challengeId,
      userId: userId,
    );
    await _cache.upsertChallenge(c.toJson());
    return c;
  }

  Future<ChallengeModel> toggleStatus(int challengeId) async {
    final c = await _remote.toggleStatus(challengeId);
    await _cache.upsertChallenge(c.toJson());
    return c;
  }

  Future<ChallengeModel> respondToInvitation({
    required int challengeId,
    required bool accept,
  }) async {
    final c = await _remote.respondToInvitation(
      challengeId: challengeId,
      status: accept ? 'accepted' : 'rejected',
    );
    await _cache.upsertChallenge(c.toJson());
    return c;
  }

  Future<void> deleteChallenge(int id) async {
    await _remote.deleteChallenge(id);
    final list = _cache.getChallengesList();
    if (list != null) {
      list.removeWhere((c) => c['id'] == id);
      await _cache.saveChallengesList(list);
    }
  }

  Future<List<ChallengeModel>> getPendingInvitations() async {
    try {
      return await _remote.getPendingInvitations();
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        final cached = _cache.getChallengesList() ?? [];
        return cached
            .map(ChallengeModel.fromJson)
            .where((c) => c.pendingParticipants.isNotEmpty)
            .toList();
      }
      rethrow;
    }
  }

  double _progressFromChallenge(ChallengeModel challenge, int userId) {
    return _progressFromMap(challenge.toJson(), userId);
  }

  double _progressFromMap(Map<String, dynamic> map, int userId) {
    final participants = map['participants'];
    if (participants is! List) return 0;
    for (final raw in participants) {
      if (raw is! Map) continue;
      if (raw['id'] == userId) {
        return (raw['current_progress'] as num?)?.toDouble() ?? 0;
      }
    }
    return 0;
  }
}
