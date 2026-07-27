import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

/// Represents documents grouped by a specific year,
/// including document details and CA document information.
class AppRefFiles {
  /// Creates a [AppRefFiles] instance.
  AppRefFiles({
    required this.appRefNo,
    required this.docSubType,
  });

  /// Creates a [AppRefFiles] instance from a JSON map.
  factory AppRefFiles.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    final String appRefNo = json["name"]?.toString() ?? "0";
    final List<dynamic> children = json["children"] as List<dynamic>? ?? [];

    return AppRefFiles(
      appRefNo: appRefNo,
      docSubType: children
          .where((e) => (e as Map<String, dynamic>)["type"] == "file")
          .map(
            (e) => DocSubTypeDetail.fromJson(
              e as Map<String, dynamic>,
              documentTypes,
              subTypes,
              subSubTypes,
              subSubSubTypes,
              languages,
            ),
          )
          .toList(),
    );
  }

  /// Document year.
  String? appRefNo;

  /// Document subtype details.
  List<DocSubTypeDetail?>? docSubType;
}
