import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/utils/current_server_user_id.dart';

/// Resolves the logged-in participant in a challenge (not the creator proxy).
abstract final class ChallengeCurrentUser {
  static ParticipantModel? participantIn(ChallengeModel challenge) {
    final userId = tryCurrentServerUserId();
    if (userId != null) {
      for (final p in challenge.participants) {
        if (p.id == userId) return p;
      }
    }

    final email = tryCurrentServerUserEmail()?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      for (final p in challenge.participants) {
        if (p.email.trim().toLowerCase() == email) return p;
      }
    }

    return null;
  }
}
