import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/rate_debouncer.dart";

void main() {
  group("RateDebouncer", () {
    test("collapses a burst of triggers into a single fetch", () async {
      final RateDebouncer debouncer =
          RateDebouncer(duration: const Duration(milliseconds: 20));
      addTearDown(debouncer.dispose);

      int calls = 0;
      Future<void> fetch(int _) async => calls++;

      unawaited(debouncer.run(fetch));
      unawaited(debouncer.run(fetch));
      await debouncer.run(fetch);

      expect(calls, 1);
    });

    test("completes superseded futures so callers are never stranded",
        () async {
      final RateDebouncer debouncer =
          RateDebouncer(duration: const Duration(milliseconds: 20));
      addTearDown(debouncer.dispose);

      bool firstCompleted = false;
      final Future<void> first = debouncer.run((_) async {});
      unawaited(first.then((_) => firstCompleted = true));

      await debouncer.run((_) async {});
      await first;
      await Future<void>.delayed(Duration.zero);

      expect(firstCompleted, isTrue);
    });

    test("drives the loading flag across a fetch", () async {
      final RateDebouncer debouncer =
          RateDebouncer(duration: const Duration(milliseconds: 20));
      addTearDown(debouncer.dispose);

      expect(debouncer.isLoading.value, isFalse);

      final Future<void> pending = debouncer.run((_) async {});
      expect(debouncer.isLoading.value, isTrue);

      await pending;
      expect(debouncer.isLoading.value, isFalse);
    });

    test("marks an earlier request id stale once a newer one is issued",
        () async {
      final RateDebouncer debouncer =
          RateDebouncer(duration: const Duration(milliseconds: 20));
      addTearDown(debouncer.dispose);

      final List<int> seen = <int>[];
      unawaited(debouncer.run((int id) async => seen.add(id)));
      await debouncer.run((int id) async => seen.add(id));

      expect(seen, hasLength(1));
      expect(debouncer.isCurrent(seen.single), isTrue);
      expect(debouncer.isCurrent(seen.single - 1), isFalse);
    });

    test("a disposed debouncer runs nothing and reports everything stale",
        () async {
      final RateDebouncer debouncer =
          RateDebouncer(duration: const Duration(milliseconds: 20));

      int calls = 0;
      debouncer.dispose();
      await debouncer.run((_) async => calls++);

      expect(calls, 0);
      expect(debouncer.isCurrent(0), isFalse);
    });

    test("dispose cancels a fetch that is still waiting out the debounce",
        () async {
      final RateDebouncer debouncer =
          RateDebouncer(duration: const Duration(milliseconds: 50));

      int calls = 0;
      unawaited(debouncer.run((_) async => calls++));
      debouncer.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 0);
    });
  });
}
