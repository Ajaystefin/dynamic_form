import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/app_ref_files.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";

/// Represents legacy document files grouped by cutoff period and year.
class LegacyFiles {
  /// Creates a [LegacyFiles] instance.
  LegacyFiles({
    this.cutoff,
    this.years,
    this.docType,
    this.apps,
  });

  /// Creates a [LegacyFiles] instance from a JSON map.
  factory LegacyFiles.fromJson(
    Map<String, dynamic> json,
    DocumentType? docTypeId,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    final attributes = json["attributes"] as Map<String, dynamic>?;

    final children = json["children"] as List<dynamic>? ?? [];

    return LegacyFiles(
      cutoff: attributes?["cutoff"]?.toString(),
      docType: docTypeId,
      apps: children
          .where((e) => (e as Map<String, dynamic>)["type"] == "appRefNo")
          .map(
            (e) => AppRefFiles.fromJson(
              e as Map<String, dynamic>,
              documentTypes,
              subTypes,
              subSubTypes,
              subSubSubTypes,
              languages,
            ),
          )
          .toList(),
      years: children
          .where((e) => (e as Map<String, dynamic>)["type"] == "year")
          .map(
            (e) => DocYearDetail.fromJson(
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

  /// Cutoff value used for grouping legacy files.
  final String? cutoff;

  /// Document type.
  final DocumentType? docType;

  /// Document records grouped by year.
  final List<DocYearDetail>? years;

  ///
  final dynamic apps;
}
