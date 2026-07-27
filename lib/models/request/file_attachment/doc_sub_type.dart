import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

/// Represents a document subtype detail and its associated
/// document metadata.
class DocSubTypeDetail {
  /// Creates a [DocSubTypeDetail] instance.
  DocSubTypeDetail({
    this.name,
    this.data,
  });

  /// Creates a [DocSubTypeDetail] instance from a JSON map.
  factory DocSubTypeDetail.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    return DocSubTypeDetail(
      name: json["name"]?.toString(),
      data: json["attributes"] != null
          ? DocSubTypeData.fromJson(
              json["attributes"] as Map<String, dynamic>,
              documentTypes,
              subTypes,
              subSubTypes,
              subSubSubTypes,
              languages,
            )
          : null,
    );
  }

  /// Document subtype name.
  String? name;

  /// Document subtype data.
  DocSubTypeData? data;
}
