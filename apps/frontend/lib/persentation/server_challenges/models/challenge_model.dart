import 'package:mudabbir/persentation/server_challenges/models/user_model.dart';

class ChallengeModel {
  final int id;
  final String name;
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
}

// NEW: Participant model with status, target, and achievement
class ParticipantModel extends UserModel {
  final String status; // pending, accepted, rejected
  final double? targetAmount;
  final bool achieved;

  ParticipantModel({
    required super.id,
    required super.name,
    required super.email,
    required this.status,
    this.targetAmount,
    required this.achieved,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      targetAmount: json['target_amount'] != null
          ? double.parse(json['target_amount'].toString())
          : null,
      achieved: json['achieved'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'status': status,
      'target_amount': targetAmount,
      'achieved': achieved,
    };
  }

  ParticipantModel copyWith({
    int? id,
    String? name,
    String? email,
    String? status,
    double? targetAmount,
    bool? achieved,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      targetAmount: targetAmount ?? this.targetAmount,
      achieved: achieved ?? this.achieved,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
