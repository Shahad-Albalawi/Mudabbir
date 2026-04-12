import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/service/getit_init.dart';

class ChallengesRepository {
  Future<Either<Empty, List<Map<String, dynamic>>>> getChallenges() async {
    return getIt<DbHelper>().queryAllRows('challenges');
  }

  Future<int> removeChallenge(int id) async {
    return await getIt<DbHelper>().delete('challenges', 'id=?', [id]);
  }

  Future<int> addChallenge(Map<String, dynamic> data) async {
    return await getIt<DbHelper>().insert('challenges', data);
  }

  Future<int> updateChallengeStatus(int challengeId, String newStatus) async {
    return await getIt<DbHelper>().update(
      'challenges',
      {'status': newStatus},
      'id=?',
      [challengeId],
    );
  }
}
