/// Base class representing a response that contains a list of strings.
class BaseStringListResponse {
  /// Creates a response with the given [responseData].
  const BaseStringListResponse(this.responseData);

  /// The list of string values returned in the response.
  final List<String> responseData;

  /// Extracts a list of strings from the given [map].
  ///
  /// Looks for the key `responseData` and returns a filtered list of strings.
  /// If the key is missing or not a valid list, an empty list is returned.
  static List<String> parse(Map<String, dynamic> map) {
    return (map["responseData"] as List?)
            ?.whereType<String>()
            .toList() ??
        const [];
  }
}

/// Response model representing a list of projects.
class ProjectListResponse extends BaseStringListResponse {
  /// Creates an instance using the provided [responseData].
  ProjectListResponse(super.responseData);

  /// Creates a [ProjectListResponse] from a map.
  factory ProjectListResponse.fromMap(Map<String, dynamic> map) {
    return ProjectListResponse(BaseStringListResponse.parse(map));
  }
}

/// Response model representing borrower-related data.
class BorrowersMap extends BaseStringListResponse {
  /// Creates an instance using the provided [responseData].
  BorrowersMap(super.responseData);

  /// Creates a [BorrowersMap] from a map.
  factory BorrowersMap.fromMap(Map<String, dynamic> map) {
    return BorrowersMap(BaseStringListResponse.parse(map));
  }
}
