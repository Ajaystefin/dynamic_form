import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart';

class CaDocSubType {
  int? docSubTypeId;
  String? caSubTypeName;
  List<DocSubTypeDetail>? docSubType;

  CaDocSubType(
      {required this.docSubTypeId,
      this.caSubTypeName,
      required this.docSubType});

  factory CaDocSubType.fromJson(
      Map<String, dynamic> json,
      List<Reference>? documentTypes,
      List<Reference>? subTypes,
      List<Reference>? subSubTypes,
      List<Reference>? subSubSubTypes,
      List<Reference>? languages) {
    String id = json['name']?.toString() ?? '0';
    int parsedYear = int.tryParse(id) ?? 0;
    List<dynamic>? children = json['children'] as List<dynamic>? ?? [];

    return CaDocSubType(
        docSubTypeId: parsedYear,
        caSubTypeName: subTypes!
            .firstWhere(
              (ref) => ref.id == parsedYear,
              orElse: () => Reference(),
            )
            .name,
        docSubType: children
            .where((e) => (e as Map<String, dynamic>)['type'] == 'file')
            .map((e) => DocSubTypeDetail.fromJson(
                e as Map<String, dynamic>,
                documentTypes!,
                subTypes,
                subSubTypes!,
                subSubSubTypes!,
                languages!))
            .toList());
  }
}
