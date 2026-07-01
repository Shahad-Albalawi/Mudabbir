import 'package:dartz/dartz.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/constants/test_support.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/features/auth/models/auth_exception.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

/// Login, register, and logout — token persisted in [AuthTokenSecureStore].
class AuthService {
  AuthService({
    UserRepository? userRepository,
    AuthTokenSecureStore? secureStore,
    AuthNotifier? authNotifier,
    HiveService? hiveService,
  })  : _userRepository = userRepository ?? getIt<UserRepository>(),
        _secureStore = secureStore ?? getIt<AuthTokenSecureStore>(),
        _authNotifier = authNotifier ?? getIt<AuthNotifier>(),
        _hiveService = hiveService ?? getIt<HiveService>();

  final UserRepository _userRepository;
  final AuthTokenSecureStore _secureStore;
  final AuthNotifier _authNotifier;
  final HiveService _hiveService;

  Future<UserModel> login(String email, String password) async {
    final result = await _userRepository.login(email.trim(), password);
    return _unwrap(result);
  }

  Future<UserModel> register(
    String name,
    String email,
    String password, {
    String? passwordConfirmation,
  }) async {
    final result = await _userRepository.register(
      name.trim(),
      email.trim(),
      password,
      passwordConfirmation ?? password,
    );
    return _unwrap(result);
  }

  Future<void> logout() => _authNotifier.didLogout();

  Future<UserModel> _unwrap(Either<Failure, UserModel> result) async {
    return await result.fold(
      (Failure failure) async => throw AuthException(failure),
      (UserModel user) async {
        final token = await _secureStore.readToken();
        if (token == null || token.isEmpty) {
          throw const AuthException(
            UnknownFailure('تعذر حفظ جلسة الدخول'),
          );
        }

        await _authNotifier.didLogin(
          {'name': user.name, 'email': user.email, 'id': user.id},
          token,
        );

        final userName = user.name ?? '';
        await _hiveService.setValue(HiveConstants.savedUserInfo, {
          'email': user.email,
          'name': userName,
          'id': user.id,
        });
        if (!TestSupport.skipDatabaseSideEffects && userName.isNotEmpty) {
          await LocalDatabase.instance.initForUser(userName);
        }

        return user;
      },
    );
  }
}
