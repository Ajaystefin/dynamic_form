import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/ca_doc_sub_type.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart';

class DocYearDetail {
  int? docYear;
  List<DocSubTypeDetail?>? docSubType;
  List<CaDocSubType>? caDocTypeData;

  DocYearDetail(
      {required this.docYear, required this.docSubType, this.caDocTypeData});

  factory DocYearDetail.fromJson(
      Map<String, dynamic> json,
      List<Reference>? documentTypes,
      List<Reference>? subTypes,
      List<Reference>? subSubTypes,
      List<Reference>? subSubSubTypes,
      List<Reference>? languages) {
    String rawYear = json['name']?.toString() ?? '0';
    int parsedYear = int.tryParse(rawYear) ?? 0;
    List<dynamic> children = json['children'] as List<dynamic>? ?? [];
    List<CaDocSubType> caData = children
        .where((e) => (e as Map<String, dynamic>)['type'] == 'subType')
        .map((e) => CaDocSubType.fromJson(
            e as Map<String, dynamic>,
            documentTypes!,
            subTypes!,
            subSubTypes!,
            subSubSubTypes!,
            languages!))
        .toList();

    return DocYearDetail(
      docYear: parsedYear,
      docSubType: children
          .where((e) => (e as Map<String, dynamic>)['type'] == 'file')
          .map((e) => DocSubTypeDetail.fromJson(
              e as Map<String, dynamic>,
              documentTypes!,
              subTypes!,
              subSubTypes!,
              subSubSubTypes!,
              languages!))
          .toList(),
      caDocTypeData: caData,
    );
  }
}
