import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/service/api_service.dart';

class UserRepository {
  final ApiService apiService;
  UserRepository(this.apiService);

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) {
    return apiService.login(email, password);
  }

  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) {
    return apiService.register(
      name,
      email,
      password,
      passwordConfirmation,
    );
  }
}
