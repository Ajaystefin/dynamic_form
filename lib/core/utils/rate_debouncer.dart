import "dart:async";

import "package:flutter/foundation.dart";

/// Collapses rapid exchange-rate triggers into a single fetch, and exposes a
/// loading flag for the AED field's spinner.
///
/// One instance per currency field. Typing in an amount field fires a rate
/// lookup on every keystroke; without this, each keystroke is an API call and a
/// slow response for a currency the user has already moved on from can land
/// last and overwrite the current converted value.
///
/// Ported from the same mechanism in the dynamic form's `CurrencyDropdown`
/// (`_debouncedGetCurrencyRates`), which this deliberately mirrors rather than
/// re-inventing.
class RateDebouncer {
  /// Creates a [RateDebouncer].
  RateDebouncer({this.duration = const Duration(milliseconds: 300)});

  /// How long to wait after the last trigger before running the fetch.
  final Duration duration;

  /// True while a fetch is pending (debouncing) or in flight.
  ///
  /// Handed straight to `ConvertedAmountField.isLoadingListenable`.
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Timer? _timer;
  Completer<void>? _completer;
  int _requestId = 0;
  bool _disposed = false;

  /// Whether [requestId] is still the most recently issued request.
  ///
  /// A fetch whose id has been superseded must not write its result anywhere.
  bool isCurrent(int requestId) => !_disposed && requestId == _requestId;

  /// Schedules [fetch], cancelling any fetch still waiting out the debounce.
  ///
  /// The returned future completes when this fetch finishes — or immediately if
  /// a later call supersedes it, so a caller's trailing work is never stranded.
  Future<void> run(Future<void> Function(int requestId) fetch) {
    if (_disposed) {
      return Future<void>.value();
    }

    _timer?.cancel();
    _releasePending();

    final Completer<void> completer = Completer<void>();
    final int requestId = ++_requestId;
    _completer = completer;
    isLoading.value = true;

    _timer = Timer(duration, () async {
      try {
        await fetch(requestId);
      } finally {
        if (isCurrent(requestId)) {
          isLoading.value = false;
        }
        if (identical(_completer, completer)) {
          _completer = null;
        }
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    return completer.future;
  }

  /// Completes the pending future, if any, without running its fetch.
  void _releasePending() {
    final Completer<void>? pending = _completer;
    _completer = null;

    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }

  /// Cancels any scheduled fetch and releases the loading notifier.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _timer?.cancel();
    _releasePending();
    isLoading.dispose();
  }
}
