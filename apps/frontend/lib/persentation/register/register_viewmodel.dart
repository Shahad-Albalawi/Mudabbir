// lib/persentation/register/register_viewmodel.dart

import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterState {
  final bool isLoading;
  final UserModel? user;
  final Failure? failure;

  const RegisterState({this.isLoading = false, this.user, this.failure});

  RegisterState copyWith({bool? isLoading, UserModel? user, Failure? failure}) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      failure: failure,
    );
  }
}

final registerProvider =
    StateNotifierProvider<RegisterViewModel, RegisterState>(
      (_) => RegisterViewModel(),
    );

class RegisterViewModel extends StateNotifier<RegisterState> {
  RegisterViewModel() : super(const RegisterState());

  final UserRepository userRepository = getIt<UserRepository>();

  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    state = state.copyWith(isLoading: true);

    final result = await userRepository.register(
      name,
      email,
      password,
      passwordConfirmation,
    );

    await Future.delayed(const Duration(seconds: 2));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return Left(failure);
      },
      (userModel) async {
        // Initialize per-user database after successful registration
        final userEmail = userModel.email!;
        final userName = userModel.name!;
        await LocalDatabase.instance.initForUser(userName);

        state = state.copyWith(isLoading: false, user: userModel);
        return Right(userModel);
      },
    );
  }
}
