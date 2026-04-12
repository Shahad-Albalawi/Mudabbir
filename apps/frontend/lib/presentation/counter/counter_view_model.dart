import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';

class CounterState {
  int counter;
  CounterState({this.counter = 0});

  CounterState copyWith({int? counter}) {
    return CounterState(counter: counter ?? this.counter);
  }
}

final counterProvider = StateNotifierProvider<CounterViewModel, CounterState>(
  (_) => CounterViewModel(),
);

class CounterViewModel extends StateNotifier<CounterState> {
  CounterViewModel() : super(CounterState()) {
    _loadCounter();
  }

  _loadCounter() async {
    final saved =
        await getIt<HiveService>().getValue(HiveConstants.savedCounter) ?? 0;
    state = state.copyWith(counter: saved);
  }

  final hiveServie = getIt<HiveService>();

  Future<void> increment() async {
    state = state.copyWith(counter: state.counter + 1);
    await hiveServie.setValue(HiveConstants.savedCounter, state.counter);
  }

  Future<int> get currentCounter async =>
      await hiveServie.getValue(HiveConstants.savedCounter);

  void decrement() async {
    state = state.copyWith(counter: state.counter - 1);
    await hiveServie.setValue(HiveConstants.savedCounter, state.counter);
  }
}
