import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/service/getit_init.dart';

class PostRepository {
  Future<Either<Empty, List<Map<String, dynamic>>>> getPosts() async {
    return getIt<DbHelper>().queryAllRows('posts');
  }
}
