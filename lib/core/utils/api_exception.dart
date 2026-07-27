/// API Exception
///
/// Represents an API-related error.
class ApiException implements Exception {
  /// Creates an API exception with the specified message.
  ApiException(this.message);

  /// Error message.
  final String message;

  /// Returns the error message.
  @override
  String toString() => message;
}
