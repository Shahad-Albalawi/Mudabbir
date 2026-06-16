import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';

/// Result of a repository read with cache/offline metadata.
class ChallengeListSyncResult {
  final List<ChallengeModel> challenges;
  final bool fromCache;
  final bool isOffline;

  const ChallengeListSyncResult({
    required this.challenges,
    this.fromCache = false,
    this.isOffline = false,
  });
}

class ChallengeSyncResult {
  final ChallengeModel challenge;
  final bool fromCache;
  final bool isOffline;

  const ChallengeSyncResult({
    required this.challenge,
    this.fromCache = false,
    this.isOffline = false,
  });
}

class ChallengeProgressResult {
  final double currentProgress;
  final ChallengeModel? challenge;
  final bool syncedToServer;
  final bool queuedOffline;

  const ChallengeProgressResult({
    required this.currentProgress,
    this.challenge,
    this.syncedToServer = true,
    this.queuedOffline = false,
  });
}
