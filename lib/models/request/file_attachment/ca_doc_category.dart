import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

class CaDocCategory {
  CaDocCategory({required this.docSubType, this.categoryName});

  factory CaDocCategory.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    final List<dynamic> children = json["children"] as List<dynamic>? ?? [];

    return CaDocCategory(
      categoryName: json["name"],
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
  String? categoryName;
  List<DocSubTypeDetail>? docSubType;
}
