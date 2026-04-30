class ProjectListResponse {
  const ProjectListResponse(this.responseData);

  factory ProjectListResponse.fromMap(Map<String, dynamic> map) =>
      ProjectListResponse(
        (map["responseData"] as List?)?.whereType<String>().toList() ??
            const [],
      );
  final List<String> responseData;
}

class BorrowersMap {
  const BorrowersMap(this.responseData);

  factory BorrowersMap.fromMap(Map<String, dynamic> map) => BorrowersMap(
        (map["responseData"] as List?)?.whereType<String>().toList() ??
            const [],
      );
  final List<String> responseData;
}
