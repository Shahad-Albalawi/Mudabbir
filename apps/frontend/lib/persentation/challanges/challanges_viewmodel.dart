import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/domain/repository/challanges_repository/challanges_repository.dart';
import 'package:mudabbir/service/getit_init.dart';

// State class
class ChallengeState {
  final bool isLoading;
  final List<Map<String, dynamic>> challenges;
  final String? error;
  final isDelete;
  final isAdd;
  final isUpdate;

  ChallengeState({
    this.isLoading = false,
    this.challenges = const [],
    this.error,
    this.isDelete = false,
    this.isAdd = false,
    this.isUpdate = false,
  });

  ChallengeState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? challenges,
    String? error,
    bool? isDelete,
    bool? isAdd,
    bool? isUpdate,
  }) {
    return ChallengeState(
      isLoading: isLoading ?? this.isLoading,
      challenges: challenges ?? this.challenges,
      error: error,
      isDelete: isDelete,
      isAdd: isAdd,
      isUpdate: isUpdate,
    );
  }
}

// ViewModel as StateNotifier
class ChallengeViewmodel extends StateNotifier<ChallengeState> {
  final ChallengesRepository _challengesRepository =
      getIt<ChallengesRepository>();

  ChallengeViewmodel() : super(ChallengeState());

  // Get all challenges
  Future<void> getAllChallenges() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _challengesRepository.getChallenges();

    result.fold(
      (l) {
        debugPrint(l.message);
        state = state.copyWith(isLoading: false, error: l.message);
      },
      (r) {
        debugPrint('Challenges: $r');
        if (r.isEmpty) {
          state = state.copyWith(isLoading: false, challenges: []);
        } else {
          final typedChallenges = r
              .map((challenge) => Map<String, dynamic>.from(challenge))
              .toList();
          state = state.copyWith(isLoading: false, challenges: typedChallenges);
        }
      },
    );
  }

  // Add new challenge
  addNewChallenge(Map<String, dynamic> data) async {
    await _challengesRepository.addChallenge(data);
    state = state.copyWith(isAdd: true, challenges: state.challenges);
  }

  // Delete challenge
  deleteChallenge(int id) async {
    final result = await _challengesRepository.removeChallenge(id);
    if (result == 1) {
      final updatedChallenges = state.challenges
          .where((challenge) => challenge['id'] != id)
          .toList();
      state = state.copyWith(challenges: updatedChallenges, isDelete: true);
    }
  }

  // Update challenge status
  Future<void> updateChallengeStatus(int challengeId, String newStatus) async {
    try {
      final challengeIndex = state.challenges.indexWhere(
        (challenge) => challenge['id'] == challengeId,
      );
      if (challengeIndex == -1) return;

      final currentChallenge = state.challenges[challengeIndex];

      final result = await _challengesRepository.updateChallengeStatus(
        challengeId,
        newStatus,
      );

      if (result > 0) {
        final updatedChallenges = List<Map<String, dynamic>>.from(
          state.challenges.map(
            (challenge) => Map<String, dynamic>.from(challenge),
          ),
        );
        updatedChallenges[challengeIndex] = Map<String, dynamic>.from({
          ...currentChallenge,
          'status': newStatus,
        });

        state = state.copyWith(challenges: updatedChallenges, isUpdate: true);
      }
    } catch (e) {
      state = state.copyWith(error: 'فشل في تحديث التحدي');
      debugPrint('Error updating challenge: $e');
    }
  }
}

final challengeViewmodelProvider =
    StateNotifierProvider.autoDispose<ChallengeViewmodel, ChallengeState>((
      ref,
    ) {
      return ChallengeViewmodel()..getAllChallenges();
    });
