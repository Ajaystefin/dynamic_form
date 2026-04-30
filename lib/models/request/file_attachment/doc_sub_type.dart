import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

class DocSubTypeDetail {
  DocSubTypeDetail({
    this.name,
    this.data,
  });

  factory DocSubTypeDetail.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    return DocSubTypeDetail(
      name: json["name"]?.toString(),
      data: json["attributes"] != null
          ? DocSubTypeData.fromJson(
              json["attributes"] as Map<String, dynamic>,
              documentTypes,
              subTypes,
              subSubTypes,
              subSubSubTypes,
              languages,
            )
          : null,
    );
  }
  String? name;
  DocSubTypeData? data;
}
