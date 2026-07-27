import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_category.dart";

/// Represents CA document information grouped by application
/// reference number.
class CaDocAppRef {
  /// Creates a [CaDocAppRef] instance.
  CaDocAppRef({
    required this.caDocCategory,
    this.appRefNo,
  });

  /// Creates a [CaDocAppRef] instance from a JSON map.
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

  /// Application reference number.
  String? appRefNo;

  /// CA document categories.
  List<CaDocCategory>? caDocCategory;
}
