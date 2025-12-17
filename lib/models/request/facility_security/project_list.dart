class ProjectListResponse {
  final List<String> responseData;
  const ProjectListResponse(this.responseData);

  factory ProjectListResponse.fromMap(Map<String, dynamic> map) =>
      ProjectListResponse(
        (map['responseData'] as List?)?.whereType<String>().toList() ??
            const [],
      );
}

class BorrowersMap {
  final List<String> responseData;
  const BorrowersMap(this.responseData);

  factory BorrowersMap.fromMap(Map<String, dynamic> map) => BorrowersMap(
        (map['responseData'] as List?)?.whereType<String>().toList() ??
            const [],
      );
}
