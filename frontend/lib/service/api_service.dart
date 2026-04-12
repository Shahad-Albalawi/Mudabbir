import 'package:dartz/dartz.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/network/request_helper.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

/// Laravel Sanctum often returns `token` as `{ plainTextToken: "..." }`;
/// some APIs return a plain string. Register already used `plainTextToken`;
/// login must do the same or Hive stores a Map and [didLogin] breaks.
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
    return await requestData(
      method: HttpMethod.POST,
      body: {'email': email, 'password': password},
      url: '${ApiConstants.baseUrl}/api/login',
      parser: (json) {
        final userJson = json['user'];
        final user = UserModel.fromJson(userJson);

        storeTokenAndUser(user, _plainTokenFromAuthJson(json['token']));
        return user;
      },
    );
  }

  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    return await requestData(
      method: HttpMethod.POST,
      body: {
        'email': email,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      url: '${ApiConstants.baseUrl}/api/register',
      parser: (json) {
        final userJson = json['user'];
        final user = UserModel.fromJson(userJson);

        storeTokenAndUser(user, _plainTokenFromAuthJson(json['token']));
        return user;
      },
    );
  }

  Future<void> storeTokenAndUser(UserModel user, String token) async {
    final hive = getIt<HiveService>();
    await hive.setValue(HiveConstants.savedToken, token);
    await getIt<AuthTokenSecureStore>().writeToken(token);

    // Save user info for HomePage green-dot
    await hive.setValue(HiveConstants.savedUserInfo, {
      'email': user.email,
      'name': user.name,
    });
  }
}
