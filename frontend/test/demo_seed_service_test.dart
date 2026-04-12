import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/service/debug/demo_seed_service.dart';

void main() {
  group('DemoSeedService', () {
    test('shouldSeedCounts is true only when all empty', () {
      expect(
        DemoSeedService.shouldSeedCounts(
          transactionCount: 0,
          goalCount: 0,
          budgetCount: 0,
        ),
        isTrue,
      );
      expect(
        DemoSeedService.shouldSeedCounts(
          transactionCount: 1,
          goalCount: 0,
          budgetCount: 0,
        ),
        isFalse,
      );
      expect(
        DemoSeedService.shouldSeedCounts(
          transactionCount: 0,
          goalCount: 1,
          budgetCount: 0,
        ),
        isFalse,
      );
      expect(
        DemoSeedService.shouldSeedCounts(
          transactionCount: 0,
          goalCount: 0,
          budgetCount: 1,
        ),
        isFalse,
      );
    });
  });
}
