import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/document_data.dart';

class FileDetail {
  String? type;
  String? name;
  List<DocumentDetail>? documents;

  FileDetail({required this.type, required this.documents, this.name});

  FileDetail.fromJson(
      Map<String, dynamic> json,
      List<Reference>? documentTypes,
      List<Reference>? subTypes,
      List<Reference>? subSubTypes,
      List<Reference>? subSubSubTypes,
      List<Reference>? languages) {
    type = json['type'] as String?;
    name = json['name'] as String?;
    documents = (json['children'] as List<dynamic>?)
            ?.map((e) => DocumentDetail.fromJson(
                e as Map<String, dynamic>,
                documentTypes!,
                subTypes!,
                subSubTypes!,
                subSubSubTypes!,
                languages!))
            .toList() ??
        [];
  }
}
