import "package:flutter_bloc/flutter_bloc.dart";

/// Safe Cubit
///
/// A Cubit implementation that prevents state emissions
/// after the cubit has been closed.
abstract class SafeCubit<State> extends Cubit<State> {
  /// Creates a safe cubit with the specified initial state.
  SafeCubit(super.initialState);

  /// Emits a new state if the cubit is not closed.
  @override
  void emit(State state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
