import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

class CaDocSubType {
  CaDocSubType({
    required this.docSubTypeId,
    required this.docSubType,
    this.caSubTypeName,
  });

  factory CaDocSubType.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    final String id = json["name"]?.toString() ?? "0";
    final int parsedYear = int.tryParse(id) ?? 0;
    final List<dynamic> children = json["children"] as List<dynamic>? ?? [];

    return CaDocSubType(
      docSubTypeId: parsedYear,
      caSubTypeName: subTypes!
          .firstWhere(
            (ref) => ref.id == parsedYear,
            orElse: Reference.new,
          )
          .name,
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
  int? docSubTypeId;
  String? caSubTypeName;
  List<DocSubTypeDetail>? docSubType;
}
