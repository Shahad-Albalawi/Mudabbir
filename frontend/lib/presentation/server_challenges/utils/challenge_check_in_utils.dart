import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';

/// Shared check-in helpers for challenge streak UI.
abstract final class ChallengeCheckInUtils {
  ChallengeCheckInUtils._();

  static bool isCheckedInToday(ParticipantModel? participant) {
    if (participant?.lastCheckIn == null) return false;
    final today = DateTime.now().toIso8601String().split('T').first;
    return participant!.lastCheckIn == today;
  }

  static bool canCheckIn(ChallengeModel challenge, ParticipantModel? me) {
    if (!challenge.isActive || me == null || !me.isAccepted) return false;
    return !isCheckedInToday(me);
  }
}
