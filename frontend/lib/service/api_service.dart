import 'package:dartz/dartz.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/network/request_helper.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

/// Laravel Sanctum often returns `token` as `{ plainTextToken: "..." }`.
String _plainTokenFromAuthJson(dynamic tokenField) {
  if (tokenField == null) {
    throw FormatException('Missing token in auth response');
  }
  if (tokenField is String) {
    return tokenField;
  }
  if (tokenField is Map) {
    final plain = tokenField['plainTextToken'];
    if (plain is String) {
      return plain;
    }
  }
  throw FormatException('Unexpected token shape in auth response');
}

class ApiService {
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    return _authRequest(
      url: '${ApiConstants.baseUrl}/api/login',
      body: {'email': email, 'password': password},
    );
  }

  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    return _authRequest(
      url: '${ApiConstants.baseUrl}/api/register',
      body: {
        'email': email,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<Either<Failure, UserModel>> _authRequest({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final result = await requestData<Map<String, dynamic>>(
      method: HttpMethod.POST,
      body: body,
      url: url,
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );

    return await result.fold<Future<Either<Failure, UserModel>>>(
      (failure) async => Left(failure),
      (json) async {
        try {
          final user = UserModel.fromJson(json['user']);
          final token = _plainTokenFromAuthJson(json['token']);
          await storeTokenAndUser(user, token);
          return Right(user);
        } catch (e) {
          return Left(UnknownFailure(e.toString()));
        }
      },
    );
  }

  Future<void> storeTokenAndUser(UserModel user, String token) async {
    final hive = getIt<HiveService>();
    await getIt<AuthTokenSecureStore>().writeToken(token);
    await hive.deleteValue(HiveConstants.savedToken);

    await hive.setValue(HiveConstants.savedUserInfo, {
      'id': user.id,
      'email': user.email,
      'name': user.name,
    });
  }
}
