import 'package:mudabbir/presentation/counter/counter_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterView extends ConsumerWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterProvider);
    final counerViewModel = ref.read(counterProvider.notifier);
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                counerViewModel.decrement();
              },
              child: Text('-'),
            ),
            Text(
              counterState.counter.toString(),
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                counerViewModel.increment();
              },
              child: Text('+'),
            ),
          ],
        ),
      ),
    );
  }
}
