import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";

class DocumentDetail {
  DocumentDetail({
    required this.type,
    required this.docYears,
    this.documentType,
    this.docTypeId,
    this.name,
    this.legacyFiles,
    this.documents,
  });

  factory DocumentDetail.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    // - Safely extract attributes
    final attributes = json["attributes"] as Map<String, dynamic>?;

    // - Compute docTypeId safely (nullable)
    final rawDocType = attributes?["docType"];
    final docTypeId = rawDocType is int
        ? Utils.getDocumentTypeById(rawDocType)
        : rawDocType != null
            ? Utils.getDocumentTypeById(
                int.tryParse(rawDocType.toString()) ?? 0,
              )
            : null;

    // - Compute documentType from name (fallback to Reference if not found)
    final docType = documentTypes?.firstWhere(
      (type) => type.id == int.tryParse(json["name"] ?? ""),
      orElse: Reference.new,
    );

    // - Children list
    final children = json["children"] as List<dynamic>? ?? [];

    return DocumentDetail(
      type: json["type"]?.toString(),
      name: docType?.name,
      docTypeId: docTypeId, // - Will be null if not found
      docYears: children
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
      legacyFiles: children
          .where((e) => (e as Map<String, dynamic>)["type"] == "legacy")
          .map(
            (e) => LegacyFiles.fromJson(
              e as Map<String, dynamic>,
              docTypeId,
              documentTypes,
              subTypes,
              subSubTypes,
              subSubSubTypes,
              languages,
            ),
          )
          .toList(),
      documents: children
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
      documentType: docType,
    );
  }
  String? type;
  String? name;
  List<DocYearDetail>? docYears;
  DocumentType? docTypeId; // ✅ Keep nullable
  List<LegacyFiles>? legacyFiles;
  List<DocSubTypeDetail?>? documents;
  Reference? documentType;
}
