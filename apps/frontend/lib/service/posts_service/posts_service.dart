import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/empty.dart';
import 'package:mudabbir/domain/repository/post_repository/posts_repository.dart';
import 'package:mudabbir/service/getit_init.dart';

class PostService {
  Future<Either<Empty, List<Map<String, dynamic>>>> getPosts() async {
    return await getIt<PostRepository>().getPosts();
  }
}
