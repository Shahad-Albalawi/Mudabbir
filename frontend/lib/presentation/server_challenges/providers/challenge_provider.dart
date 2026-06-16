import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/models/challenge_sync_result.dart';
import 'package:mudabbir/domain/repository/server_challenge_repository/server_challenge_repository.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception.dart';
import 'package:mudabbir/presentation/server_challenges/services/challenge_service.dart';
import 'package:mudabbir/presentation/server_challenges/utils/dio_client.dart';
import 'package:mudabbir/service/getit_init.dart';

// Dio Client Provider (kept for Riverpod consumers that still reference it)
final dioClientProvider = Provider<DioClient>((ref) {
  return getIt<DioClient>();
});

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return getIt<ChallengeService>();
});

final serverChallengeRepositoryProvider = Provider<ServerChallengeRepository>(
  (ref) => getIt<ServerChallengeRepository>(),
);

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, ChallengeState>((ref) {
  return ChallengesNotifier(ref.watch(serverChallengeRepositoryProvider));
});

class ChallengesNotifier extends StateNotifier<ChallengeState> {
  final ServerChallengeRepository _repository;

  ChallengesNotifier(this._repository) : super(const ChallengeInitial());

  Future<void> loadChallenges() async {
    state = const ChallengeLoading();
    try {
      final result = await _repository.getChallenges();
      state = ChallengeLoaded(
        result.challenges,
        fromCache: result.fromCache,
        isOffline: result.isOffline,
      );
    } on ApiException catch (e) {
      state = ChallengeError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeError(ServerChallengeStrings.unexpectedErrorLater);
    }
  }

  Future<void> refreshChallenges() async => loadChallenges();

  void addChallenge(ChallengeModel challenge) {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      state = ChallengeLoaded(
        [challenge, ...currentState.challenges],
        isOffline: currentState.isOffline,
      );
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
      state = ChallengeLoaded(
        challenges,
        isOffline: currentState.isOffline,
      );
    }
  }

  void removeChallenge(int challengeId) {
    if (state is ChallengeLoaded) {
      final currentState = state as ChallengeLoaded;
      final challenges = currentState.challenges
          .where((challenge) => challenge.id != challengeId)
          .toList();
      state = ChallengeLoaded(
        challenges,
        isOffline: currentState.isOffline,
      );
    }
  }
}

final challengeDetailProvider =
    StateNotifierProvider.family<
      ChallengeDetailNotifier,
      ChallengeDetailState,
      int
    >((ref, challengeId) {
      final repository = ref.watch(serverChallengeRepositoryProvider);
      return ChallengeDetailNotifier(repository, challengeId);
    });

class ChallengeDetailNotifier extends StateNotifier<ChallengeDetailState> {
  final ServerChallengeRepository _repository;
  final int _challengeId;

  ChallengeDetailNotifier(this._repository, this._challengeId)
    : super(const ChallengeDetailInitial());

  Future<void> loadChallenge() async {
    state = const ChallengeDetailLoading();
    try {
      final result = await _repository.getChallenge(_challengeId);
      state = ChallengeDetailLoaded(
        result.challenge,
        fromCache: result.fromCache,
        isOffline: result.isOffline,
      );
    } on ApiException catch (e) {
      state = ChallengeDetailError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeDetailError(ServerChallengeStrings.unexpectedErrorLater);
    }
  }

  void updateLocalChallenge(ChallengeModel challenge) {
    state = ChallengeDetailLoaded(challenge);
  }
}

final challengeOperationProvider =
    StateNotifierProvider<ChallengeOperationNotifier, ChallengeOperationState>((
      ref,
    ) {
      final repository = ref.watch(serverChallengeRepositoryProvider);
      final challengesNotifier = ref.watch(challengesProvider.notifier);
      return ChallengeOperationNotifier(repository, challengesNotifier);
    });

class ChallengeOperationNotifier
    extends StateNotifier<ChallengeOperationState> {
  final ServerChallengeRepository _repository;
  final ChallengesNotifier _challengesNotifier;

  ChallengeOperationNotifier(this._repository, this._challengesNotifier)
    : super(const ChallengeOperationInitial());

  Future<void> createChallenge({
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _repository.createChallenge(
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
      final challenge = await getIt<ChallengeService>().updateChallenge(
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
      await _repository.deleteChallenge(id);
      _challengesNotifier.removeChallenge(id);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.challengeDeletedSuccess,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
    }
  }

  Future<void> inviteUser({
    required int challengeId,
    required String email,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _repository.inviteUser(
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
      final challenge = await _repository.removeParticipant(
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
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
    }
  }

  Future<void> toggleStatus(int challengeId) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _repository.toggleStatus(challengeId);
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
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
    }
  }

  Future<void> respondToInvitation({
    required int challengeId,
    required bool accept,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _repository.respondToInvitation(
        challengeId: challengeId,
        accept: accept,
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
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
    }
  }

  Future<void> checkIn({
    required int challengeId,
    int userId = 1,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final result = await _repository.checkIn(
        challengeId: challengeId,
        userId: userId,
      );
      _challengesNotifier.updateChallenge(result.challenge);

      var message = result.alreadyCheckedIn
          ? ServerChallengeStrings.alreadyCheckedIn
          : ServerChallengeStrings.checkInSuccess;

      if (result.newBadges.contains('streak_30')) {
        message = ServerChallengeStrings.badge30Earned;
      } else if (result.newBadges.contains('streak_7')) {
        message = ServerChallengeStrings.badge7Earned;
      }

      state = ChallengeOperationSuccess(message, challenge: result.challenge);
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
    }
  }

  Future<ChallengeProgressResult?> addProgress({
    required int challengeId,
    required double amount,
    int userId = 1,
  }) async {
    state = const ChallengeOperationLoading();
    try {
      final result = await _repository.addProgress(
        challengeId: challengeId,
        amount: amount,
        userId: userId,
      );
      if (result.challenge != null) {
        _challengesNotifier.updateChallenge(result.challenge!);
      }
      final message = result.queuedOffline
          ? ServerChallengeStrings.progressQueuedOffline
          : ServerChallengeStrings.progressSaved;
      state = ChallengeOperationSuccess(message, challenge: result.challenge);
      return result;
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
      return null;
    } catch (e) {
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
      return null;
    }
  }

  Future<void> createFromTemplate(String templateId) async {
    state = const ChallengeOperationLoading();
    try {
      final challenge = await _repository.createFromTemplate(templateId);
      _challengesNotifier.addChallenge(challenge);
      state = ChallengeOperationSuccess(
        ServerChallengeStrings.templateCreated,
        challenge: challenge,
      );
    } on ApiException catch (e) {
      state = ChallengeOperationError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeOperationError(ServerChallengeStrings.unexpectedError);
    }
  }

  void reset() {
    state = const ChallengeOperationInitial();
  }
}

final pendingInvitationsProvider =
    StateNotifierProvider<PendingInvitationsNotifier, ChallengeState>((ref) {
      final repository = ref.watch(serverChallengeRepositoryProvider);
      return PendingInvitationsNotifier(repository);
    });

class PendingInvitationsNotifier extends StateNotifier<ChallengeState> {
  final ServerChallengeRepository _repository;

  PendingInvitationsNotifier(this._repository) : super(const ChallengeInitial());

  Future<void> loadPendingInvitations() async {
    state = const ChallengeLoading();
    try {
      final challenges = await _repository.getPendingInvitations();
      state = ChallengeLoaded(challenges);
    } on ApiException catch (e) {
      state = ChallengeError(e.getValidationMessage());
    } catch (e) {
      state = ChallengeError(ServerChallengeStrings.unexpectedError);
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

final challengeTemplatesProvider =
    FutureProvider<List<ChallengeTemplateModel>>((ref) async {
  final repository = ref.watch(serverChallengeRepositoryProvider);
  return repository.getTemplates();
});

final challengeLeaderboardProvider = FutureProvider.family<
    ChallengeLeaderboardModel, int>((ref, challengeId) async {
  final repository = ref.watch(serverChallengeRepositoryProvider);
  return repository.getLeaderboard(challengeId);
});

final challengeProgressProvider = Provider<ServerChallengeRepository>(
  (ref) => ref.watch(serverChallengeRepositoryProvider),
);
