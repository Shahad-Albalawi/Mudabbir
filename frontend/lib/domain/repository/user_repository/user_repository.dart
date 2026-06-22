import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/domain/services/repository_guard.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/api_service.dart';

class UserRepository {
  final ApiService apiService;
  UserRepository(this.apiService);

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) {
    return guardRepository(
      () => apiService.login(email, password).then(
        (either) => either.fold(
          (failure) => throw RepositoryException(failure.message),
          (user) => user,
        ),
      ),
      fallbackMessage: AppStrings.loginGenericError,
    );
  }

  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) {
    return guardRepository(
      () => apiService.register(
        name,
        email,
        password,
        passwordConfirmation,
      ).then(
        (either) => either.fold(
          (failure) => throw RepositoryException(failure.message),
          (user) => user,
        ),
      ),
      fallbackMessage: AppStrings.registerCatchError,
    );
  }
}
