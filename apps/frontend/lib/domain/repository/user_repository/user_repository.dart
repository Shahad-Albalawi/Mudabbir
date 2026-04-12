import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/service/api_service.dart';

class UserRepository {
  final ApiService apiService;
  UserRepository(this.apiService);

  // login
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    return await apiService.login(email, password);
  }

  // login
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    return await apiService.register(
      name,
      email,
      password,
      passwordConfirmation,
    );
  }
}
