import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/presentation/server_challenges/services/challenge_service.dart';
import 'package:mudabbir/presentation/server_challenges/utils/dio_client.dart';

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Challenge Service Provider
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChallengeService(dioClient);
});

// Challenges List Provider
final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, ChallengeState>((ref) {
      final service = ref.watch(challengeServiceProvider);
      return ChallengesNotifier(service);
    });

class ChallengesNotifier extends StateNotifier<ChallengeState> {
  final ChallengeService _service;

  ChallengesNotifier(this._service) : super(const ChallengeInitial());

  Future<void> loadChallenges() async {
    state = const ChallengeLoading();
    try {
      final challenges = await _service.getChallenges();
      state = ChallengeLoaded(challenges);
    } on ApiException catch (e) {
      state = ChallengeError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeError(ServerChallengeStrings.unexpectedErrorLater);
    }
  }

  Future<void> refreshChallenges() async {
    try {
      final challenges = await _service.getChallenges();
      state = ChallengeLoaded(challenges);
    } on ApiException catch (e) {
      state = ChallengeError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeError(ServerChallengeStrings.unexpectedErrorLater);
    }
  }

  void addChallenge(ChallengeModel challenge) {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      state = ChallengeLoaded([challenge, ...currentState.challenges]);
    }
  }

  void updateChallenge(ChallengeModel updatedChallenge) {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      final challenges = currentState.challenges.map((challenge) {
        return challenge.id == updatedChallenge.id
            ? updatedChallenge
            : challenge;
      }).toList();
      state = ChallengeLoaded(challenges);
    }
  }

  void removeChallenge(int challengeId) {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      final challenges = currentState.challenges
          .where((challenge) => challenge.id != challengeId)
          .toList();
      state = ChallengeLoaded(challenges);
    }
  }
}

// Challenge Detail Provider
final challengeDetailProvider =
    StateNotifierProvider.family<
      ChallengeDetailNotifier,
      ChallengeDetailState,
      int
    >((ref, challengeId) {
      final service = ref.watch(challengeServiceProvider);
      return ChallengeDetailNotifier(service, challengeId);
    });

class ChallengeDetailNotifier extends StateNotifier<ChallengeDetailState> {
  final ChallengeService _service;
  final int _challengeId;

  ChallengeDetailNotifier(this._service, this._challengeId)
    : super(const ChallengeDetailInitial());

  Future<void> loadChallenge() async {
    state = const ChallengeDetailLoading();
    try {
      final challenge = await _service.getChallenge(_challengeId);
      state = ChallengeDetailLoaded(challenge);
    } on ApiException catch (e) {
      state = ChallengeDetailError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeDetailError(
        ServerChallengeStrings.unexpectedErrorLater,
      );
    }
  }

  void updateLocalChallenge(ChallengeModel challenge) {
    state = ChallengeDetailLoaded(challenge);
  }
}

// Challenge Operations Provider (create, update, delete)
final challengeOperationProvider =
    StateNotifierProvider<ChallengeOperationNotifier, ChallengeOperationState>((
      ref,
    ) {
      final service = ref.watch(challengeServiceProvider);
      final challengesNotifier = ref.watch(challengesProvider.notifier);
      return ChallengeOperationNotifier(service, challengesNotifier);
    });

class ChallengeOperationNotifier
    extends StateNotifier<ChallengeOperationState> {
  final ChallengeService _service;
  final ChallengesNotifier _challengesNotifier;

  ChallengeOperationNotifier(this._service, this._challengesNotifier)
    : super(const ChallengeOperationInitial());

  Future<void> createChallenge({
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _service.createChallenge(
        name: name,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
      );
      _challengesNotifier.addChallenge(challenge);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.challengeCreatedSuccess,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedErrorLater,
      );
    }
  }

  Future<void> updateChallenge({
    required int id,
    String? name,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _service.updateChallenge(
        id: id,
        name: name,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
      );
      _challengesNotifier.updateChallenge(challenge);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.challengeUpdatedSuccess,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedErrorLater,
      );
    }
  }

  Future<void> deleteChallenge(int id) async {
    state = const ChallengeOperationLoading();
    try {
      await _service.deleteChallenge(id);
      _challengesNotifier.removeChallenge(id);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.challengeDeletedSuccess,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedError,
      );
    }
  }

  Future<void> inviteUser({
    required int challengeId,
    required String email,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _service.inviteUser(
        challengeId: challengeId,
        email: email,
      );
      _challengesNotifier.updateChallenge(challenge);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.userInvitedSuccess,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedErrorLater,
      );
    }
  }

  Future<void> removeParticipant({
    required int challengeId,
    required int userId,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _service.removeParticipant(
        challengeId: challengeId,
        userId: userId,
      );
      _challengesNotifier.updateChallenge(challenge);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.participantRemovedSuccess,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedError,
      );
    }
  }

  Future<void> toggleStatus(int challengeId) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _service.toggleStatus(challengeId);
      _challengesNotifier.updateChallenge(challenge);
      state = ChallengeOperationSuccess(
        challenge.achieved
            ? ServerChallengeStrings.challengeMarkedAchieved
            : ServerChallengeStrings.challengeMarkedNotAchieved,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedError,
      );
    }
  }

  // NEW: Accept or reject invitation
  Future<void> respondToInvitation({
    required int challengeId,
    required bool accept,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _service.respondToInvitation(
        challengeId: challengeId,
        status: accept ? 'accepted' : 'rejected',
      );
      _challengesNotifier.updateChallenge(challenge);
      state = ChallengeOperationSuccess(
        accept
            ? ServerChallengeStrings.invitationAccepted
            : ServerChallengeStrings.invitationRejected,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(
        ServerChallengeStrings.unexpectedError,
      );
    }
  }

  void reset() {
    state = const ChallengeOperationInitial();
  }
}

// NEW: Pending invitations provider
final pendingInvitationsProvider =
    StateNotifierProvider<PendingInvitationsNotifier, ChallengeState>((ref) {
      final service = ref.watch(challengeServiceProvider);
      return PendingInvitationsNotifier(service);
    });

class PendingInvitationsNotifier extends StateNotifier<ChallengeState> {
  final ChallengeService _service;

  PendingInvitationsNotifier(this._service) : super(const ChallengeInitial());

  Future<void> loadPendingInvitations() async {
    state = const ChallengeLoading();
    try {
      final challenges = await _service.getPendingInvitations();
      state = ChallengeLoaded(challenges);
    } on ApiException catch (e) {
      state = ChallengeError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeError(
        ServerChallengeStrings.unexpectedError,
      );
    }
  }

  void removeInvitation(int challengeId) {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      final challenges = currentState.challenges
          .where((challenge) => challenge.id != challengeId)
          .toList();
      state = ChallengeLoaded(challenges);
    }
  }
}
