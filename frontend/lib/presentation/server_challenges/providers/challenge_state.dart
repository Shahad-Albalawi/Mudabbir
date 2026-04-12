import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';

// Base state for challenges list
sealed class ChallengeState {
  const ChallengeState();
}

class ChallengeInitial extends ChallengeState {
  const ChallengeInitial();
}

class ChallengeLoading extends ChallengeState {
  const ChallengeLoading();
}

class ChallengeLoaded extends ChallengeState {
  final List<ChallengeModel> challenges;

  const ChallengeLoaded(this.challenges);

  List<ChallengeModel> get activeChallenges =>
      challenges.where((c) => c.isActive).toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));

  List<ChallengeModel> get upcomingChallenges =>
      challenges.where((c) => c.isUpcoming).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  List<ChallengeModel> get completedChallenges =>
      challenges.where((c) => c.achieved).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<ChallengeModel> get expiredChallenges =>
      challenges.where((c) => c.isExpired).toList()
        ..sort((a, b) => b.endDate.compareTo(a.endDate));
}

class ChallengeError extends ChallengeState {
  final String message;

  const ChallengeError(this.message);
}

// State for single challenge operations
sealed class ChallengeDetailState {
  const ChallengeDetailState();
}

class ChallengeDetailInitial extends ChallengeDetailState {
  const ChallengeDetailInitial();
}

class ChallengeDetailLoading extends ChallengeDetailState {
  const ChallengeDetailLoading();
}

class ChallengeDetailLoaded extends ChallengeDetailState {
  final ChallengeModel challenge;

  const ChallengeDetailLoaded(this.challenge);
}

class ChallengeDetailError extends ChallengeDetailState {
  final String message;

  const ChallengeDetailError(this.message);
}

// State for challenge operations (create, update, delete)
sealed class ChallengeOperationState {
  const ChallengeOperationState();
}

class ChallengeOperationInitial extends ChallengeOperationState {
  const ChallengeOperationInitial();
}

class ChallengeOperationLoading extends ChallengeOperationState {
  const ChallengeOperationLoading();
}

class ChallengeOperationSuccess extends ChallengeOperationState {
  final String message;
  final ChallengeModel? challenge;

  const ChallengeOperationSuccess(this.message, {this.challenge});
}

class ChallengeOperationError extends ChallengeOperationState {
  final String message;

  const ChallengeOperationError(this.message);
}
