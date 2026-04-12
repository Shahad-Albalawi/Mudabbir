// lib/presentation/login/login_viewmodel.dart

import 'package:dartz/dartz.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/service/hive_service.dart';

class LoginState {
  final bool isLoading;
  final UserModel? user;
  final Failure? failure;

  const LoginState({this.isLoading = false, this.user, this.failure});

  LoginState copyWith({bool? isLoading, UserModel? user, Failure? failure}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      failure: failure,
    );
  }
}

final loginProvider = StateNotifierProvider<LoginViewModel, LoginState>(
  (_) => LoginViewModel(),
);

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel() : super(const LoginState());

  final UserRepository userRepository = getIt<UserRepository>();

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true);

    final result = await userRepository.login(email, password);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return Left(failure);
      },
      (userModel) async {
        // Initialize per-user database
        final userEmail = userModel.email!;
        final userName = userModel.name!;
        await getIt<HiveService>().setValue(HiveConstants.savedUserInfo, {
          'email': userEmail,
          'name': userName,
        });
        await LocalDatabase.instance.initForUser(userName);
        state = state.copyWith(isLoading: false, user: userModel);
        return Right(userModel);
      },
    );
  }
}
