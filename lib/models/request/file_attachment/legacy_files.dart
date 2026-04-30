import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";

class LegacyFiles {
  LegacyFiles({this.cutoff, this.years, this.docType});

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
  final String? cutoff;
  final DocumentType? docType;
  final List<DocYearDetail>? years;
}
