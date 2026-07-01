import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/user_model.dart';
import 'package:mudabbir/utils/challenge_current_user.dart';

/// Lifecycle state for a social savings challenge.
enum ChallengeStatus { active, upcoming, completed, expired }

/// Invitation / membership state for a participant.
enum ParticipantStatus { accepted, pending, rejected }

class ChallengeModel {
  final int id;
  final String name;
  final String? description;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool achieved;
  final int creatorId;
  final UserModel creator;
  final List<ParticipantModel> participants;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChallengeModel({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.achieved,
    required this.creatorId,
    required this.creator,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: double.parse(json['amount'].toString()),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      achieved: json['achieved'] as bool,
      creatorId: json['creator_id'] as int,
      creator: UserModel.fromJson(json['creator'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'achieved': achieved,
      'creator_id': creatorId,
      'creator': creator.toJson(),
      'participants': participants.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChallengeModel copyWith({
    int? id,
    String? name,
    String? description,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    bool? achieved,
    int? creatorId,
    UserModel? creator,
    List<ParticipantModel>? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      achieved: achieved ?? this.achieved,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !achieved;
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate) && !achieved;
  }

  int get daysRemaining {
    if (achieved || DateTime.now().isAfter(endDate)) {
      return 0;
    }
    return endDate.difference(DateTime.now()).inDays;
  }

  int get totalDays {
    return endDate.difference(startDate).inDays;
  }

  double get progress {
    if (achieved) return 1.0;
    if (DateTime.now().isBefore(startDate)) return 0.0;
    if (DateTime.now().isAfter(endDate)) return 1.0;

    final elapsed = DateTime.now().difference(startDate).inDays;
    final total = endDate.difference(startDate).inDays;
    return total > 0 ? elapsed / total : 0.0;
  }

  // Get only accepted participants
  List<ParticipantModel> get acceptedParticipants {
    return participants.where((p) => p.status == 'accepted').toList();
  }

  // Get only pending participants
  List<ParticipantModel> get pendingParticipants {
    return participants.where((p) => p.status == 'pending').toList();
  }

  // Check if all accepted participants achieved
  bool get allAcceptedAchieved {
    final accepted = acceptedParticipants;
    if (accepted.isEmpty) return false;
    return accepted.every((p) => p.achieved);
  }

  /// API alias + domain naming.
  String get idString => id.toString();

  double get targetAmount => amount;

  ChallengeStatus get status {
    if (achieved) return ChallengeStatus.completed;
    if (isUpcoming) return ChallengeStatus.upcoming;
    if (isExpired) return ChallengeStatus.expired;
    if (isActive) return ChallengeStatus.active;
    return ChallengeStatus.expired;
  }

  /// Average savings progress across accepted participants.
  double get currentProgress {
    final accepted = acceptedParticipants;
    if (accepted.isEmpty) return 0;
    final total = accepted.fold<double>(0, (sum, p) => sum + p.currentProgress);
    return total / accepted.length;
  }

  /// Union of participant badge ids (e.g. streak_7, streak_30).
  List<String> get badges {
    final set = <String>{};
    for (final p in acceptedParticipants) {
      set.addAll(p.badges);
    }
    return set.toList();
  }

  /// Progress % for list cards — savings progress or streak pace, whichever is higher.
  int get displayProgressPercent {
    final me = ChallengeCurrentUser.participantIn(this);
    if (me != null && amount > 0) {
      return (me.currentProgress / amount * 100).round().clamp(0, 100);
    }
    return (progress * 100).round().clamp(0, 100);
  }

  /// Progress shown on active challenge cards (updates after daily log / check-in).
  int get activeLogProgressPercent {
    final me = ChallengeCurrentUser.participantIn(this);
    final savings = displayProgressPercent;
    if (me != null && totalDays > 0) {
      final streakPercent =
          (me.streakDays / totalDays * 100).round().clamp(0, 100);
      return savings > streakPercent ? savings : streakPercent;
    }
    return savings;
  }

  /// Subtitle for active cards — streak when present, else participant count.
  String? activeCardSubtitle() {
    final me = ChallengeCurrentUser.participantIn(this);
    if (me != null && me.streakDays > 0) {
      return ServerChallengeStrings.streakFire(me.streakDays);
    }
    final count = acceptedParticipants.length;
    if (count > 0) {
      return ServerChallengeStrings.participantCount(count);
    }
    return null;
  }
}

// NEW: Participant model with status, target, streak, and badges
class ParticipantModel extends UserModel {
  final String status; // pending, accepted, rejected
  final double? targetAmount;
  final bool achieved;
  final double currentProgress;
  final int streakDays;
  final int longestStreak;
  final String? lastCheckIn;
  final List<String> badges;

  ParticipantModel({
    required super.id,
    required super.name,
    required super.email,
    required this.status,
    this.targetAmount,
    required this.achieved,
    this.currentProgress = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastCheckIn,
    this.badges = const [],
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final rawBadges = json['badges'];
    return ParticipantModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      targetAmount: json['target_amount'] != null
          ? double.parse(json['target_amount'].toString())
          : null,
      achieved: json['achieved'] as bool? ?? false,
      currentProgress: (json['current_progress'] as num?)?.toDouble() ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCheckIn: json['last_check_in'] as String?,
      badges: rawBadges is List
          ? rawBadges.map((e) => e.toString()).toList()
          : const [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'status': status,
      'target_amount': targetAmount,
      'achieved': achieved,
      'current_progress': currentProgress,
      'streak_days': streakDays,
      'longest_streak': longestStreak,
      'last_check_in': lastCheckIn,
      'badges': badges,
    };
  }

  @override
  ParticipantModel copyWith({
    int? id,
    String? name,
    String? email,
    String? status,
    double? targetAmount,
    bool? achieved,
    double? currentProgress,
    int? streakDays,
    int? longestStreak,
    String? lastCheckIn,
    List<String>? badges,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      targetAmount: targetAmount ?? this.targetAmount,
      achieved: achieved ?? this.achieved,
      currentProgress: currentProgress ?? this.currentProgress,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      badges: badges ?? this.badges,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  String get userId => id.toString();

  double get progress => currentProgress;

  ParticipantStatus get participantStatus {
    switch (status) {
      case 'accepted':
        return ParticipantStatus.accepted;
      case 'pending':
        return ParticipantStatus.pending;
      default:
        return ParticipantStatus.rejected;
    }
  }

  bool get hasStreak7Badge => badges.contains('streak_7');
  bool get hasStreak30Badge => badges.contains('streak_30');
}

class ChallengeTemplateModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double amount;
  final int durationDays;
  final String icon;

  const ChallengeTemplateModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.amount,
    required this.durationDays,
    required this.icon,
  });

  factory ChallengeTemplateModel.fromJson(Map<String, dynamic> json) {
    return ChallengeTemplateModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      descriptionAr: json['description_ar'] as String,
      descriptionEn: json['description_en'] as String,
      amount: double.parse(json['amount'].toString()),
      durationDays: json['duration_days'] as int,
      icon: json['icon'] as String? ?? 'flag',
    );
  }

  String get localizedName =>
      ServerChallengeStrings.isArabic ? nameAr : nameEn;

  String get localizedDescription =>
      ServerChallengeStrings.isArabic ? descriptionAr : descriptionEn;
}

class LeaderboardEntryModel {
  final int userId;
  final String name;
  final String email;
  final int streakDays;
  final int longestStreak;
  final double currentProgress;
  final List<String> badges;
  final bool achieved;
  final int score;
  final int rank;

  const LeaderboardEntryModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.streakDays,
    required this.longestStreak,
    this.currentProgress = 0,
    required this.badges,
    required this.achieved,
    required this.score,
    required this.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    final rawBadges = json['badges'];
    return LeaderboardEntryModel(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      streakDays: json['streak_days'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      currentProgress: (json['current_progress'] as num?)?.toDouble() ?? 0,
      badges: rawBadges is List
          ? rawBadges.map((e) => e.toString()).toList()
          : const [],
      achieved: json['achieved'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }
}

class ChallengeLeaderboardModel {
  final int challengeId;
  final List<LeaderboardEntryModel> entries;

  const ChallengeLeaderboardModel({
    required this.challengeId,
    required this.entries,
  });

  factory ChallengeLeaderboardModel.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'] as List<dynamic>? ?? [];
    return ChallengeLeaderboardModel(
      challengeId: json['challenge_id'] as int,
      entries: raw
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChallengeCheckInResult {
  final ChallengeModel challenge;
  final bool alreadyCheckedIn;
  final List<String> newBadges;

  const ChallengeCheckInResult({
    required this.challenge,
    this.alreadyCheckedIn = false,
    this.newBadges = const [],
  });
}
