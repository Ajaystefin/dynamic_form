import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_app_ref.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

/// Represents documents grouped by a specific year,
/// including document details and CA document information.
class DocYearDetail {
  /// Creates a [DocYearDetail] instance.
  DocYearDetail({
    required this.docYear,
    required this.docSubType,
    this.caDocTypeData,
    this.caLegacy,
  });

  /// Creates a [DocYearDetail] instance from a JSON map.
  factory DocYearDetail.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    final String rawYear = json["name"]?.toString() ?? "0";
    final int parsedYear = int.tryParse(rawYear) ?? 0;
    final List<dynamic> children = json["children"] as List<dynamic>? ?? [];
    final List<CaDocSubType> caData = children
        .where((e) => (e as Map<String, dynamic>)["type"] == "subType")
        .map(
          (e) => CaDocSubType.fromJson(
            e as Map<String, dynamic>,
            documentTypes,
            subTypes,
            subSubTypes,
            subSubSubTypes,
            languages,
          ),
        )
        .toList();

    return DocYearDetail(
      docYear: parsedYear,
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
      caDocTypeData: caData,
      caLegacy: children
          .where((e) => (e as Map<String, dynamic>)["type"] == "appRefNo")
          .map(
            (e) => CaDocAppRef.fromJson(
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
  int? docYear;

  /// Document subtype details.
  List<DocSubTypeDetail?>? docSubType;

  /// CA document subtype data.
  List<CaDocSubType>? caDocTypeData;

  /// Legacy CA document data grouped by application reference number.
  List<CaDocAppRef>? caLegacy;
}
