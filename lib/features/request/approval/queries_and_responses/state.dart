import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for queries and responses.
/// 
/// Holds information related to the loading status during the
/// processing of queries and responses.
class QueriesAndResponsesState {
  /// Creates an instance of [QueriesAndResponsesState].
  /// 
  /// Requires the current [loaderStatus].
  const QueriesAndResponsesState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the queries and responses process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  QueriesAndResponsesState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return QueriesAndResponsesState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
