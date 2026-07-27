import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/document_data.dart";

/// Represents a file detail node containing document groups.
class FileDetail {
  /// Creates a [FileDetail] instance.
  FileDetail({
    required this.type,
    required this.documents,
    this.name,
  });

  /// Creates a [FileDetail] instance from a JSON map.
  FileDetail.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    type = json["type"] as String?;
    name = json["name"] as String?;
    documents = (json["children"] as List<dynamic>?)
            ?.map(
              (e) => DocumentDetail.fromJson(
                e as Map<String, dynamic>,
                documentTypes,
                subTypes,
                subSubTypes,
                subSubSubTypes,
                languages,
              ),
            )
            .toList() ??
        [];
  }

  /// File node type.
  String? type;

  /// File node name.
  String? name;

  /// Document details.
  List<DocumentDetail>? documents;
}
