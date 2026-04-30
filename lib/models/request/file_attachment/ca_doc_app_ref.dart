import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_category.dart";

class CaDocAppRef {
  CaDocAppRef({required this.caDocCategory, this.appRefNo});

  factory CaDocAppRef.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    final List<dynamic> children = json["children"] as List<dynamic>? ?? [];

    return CaDocAppRef(
      appRefNo: json["name"],
      caDocCategory: children
          .where((e) => (e as Map<String, dynamic>)["type"] == "category")
          .map(
            (e) => CaDocCategory.fromJson(
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
  String? appRefNo;
  List<CaDocCategory>? caDocCategory;
}
