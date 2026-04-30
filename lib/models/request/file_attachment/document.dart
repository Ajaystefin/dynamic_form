import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class Document {
  Document({
    this.sno,
    this.documentName,
    this.entityId,
    this.groupRim,
    this.companyRim,
    this.documentType,
    this.lastUpdated,
    this.applicationId,
    this.subType,
    this.subSubType,
    this.subSubSubType,
    this.language,
    this.languageName,
    this.date,
    this.files,
    this.file,
    this.folderID,
  });

  Document.fromJson(
    Map<String, dynamic> json,
    List<Reference> documentTypes,
    List<Reference> subTypes,
    List<Reference> subSubTypes,
    List<Reference> subSubSubTypes,
    List<Reference> languages,
  ) {
    final List<Reference> allReferences = [
      ...documentTypes,
      ...subTypes,
      ...subSubTypes,
      ...subSubSubTypes,
      ...languages,
    ];

    folderID = json["folderId"];
    docID = json["docId"];
    groupRim = int.tryParse(json["groupId"] ?? "0");
    applicationId = json["appRefNo"];
    documentType = Utils.findReferenceById(allReferences, json["docType"]);
    subType = Utils.findReferenceById(allReferences, json["subType"]);
    subSubType = Utils.findReferenceById(allReferences, json["subSubType"]);
    subSubSubType =
        Utils.findReferenceById(allReferences, json["subSubSubType"]);
    language = Utils.findReferenceById(allReferences, json["language"]);
    languageName = json["language"];
    fileName = json["fileName"];
    reference1 = json["reference1"];
    reference2 = json["reference2"];
    reference3 = json["reference3"];
    date = json["periodEndDate"] != null
        ? DateTimeUtils.parseDateTime(
            json["periodEndDate"],
            format: "yyyy-MM-dd",
          )
        : null;
    fileSize = json["fileSize"];
    documentModifiedDate = json["documentModifiedDate"];
    companyRim = json["rimNo"];
    documentName = json["documentName"];
    entityId = json["entityId"];
    files = [PlatformFile(name: json["fileName"], size: json["fileSize"])];
  }
  String? sno;
  String? documentName;
  String? entityId;
  int? groupRim;
  String? companyRim;
  DateTime? lastUpdated;
  String? applicationId;
  Reference? documentType;
  Reference? subType;
  Reference? subSubType;
  Reference? subSubSubType;
  Reference? language;
  String? languageName;
  DateTime? date;
  List<PlatformFile>? files;
  int? folderID;
  int? docID;

  String? fileName;
  File? file;
  String? reference1;
  String? reference2;
  String? reference3;
  int? fileSize;
  String? documentModifiedDate;

  LoadingStatus downloadLoader = LoadingStatus.loaded;
  LoadingStatus deleteLoader = LoadingStatus.loaded;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["appRefNo"] = applicationId;
    data["fileName"] = files!.first.name;
    data["rimNo"] = companyRim;
    data["documentName"] = documentName;
    data["entityId"] = entityId;
    data["groupId"] = Globals.request?.groupId.toString();
    data["groupName"] = Globals.request?.groupName.toString();
    data["language"] = language?.name;
    data["periodEndDate"] = date != null
        ? DateTimeUtils.formatDateTime(date!, format: "yyyy-MM-dd")
        : null;
    data["docType"] = documentType!.id;
    data["subType"] = subType?.id;
    data["subSubType"] = subSubType?.id;
    data["subSubSubType"] = subSubSubType?.id;
    data["folderId"] = folderID;
    data["userRole"] = Globals.user?.currentRole?.id ?? "";
    data["createdBy"] = Globals.user?.id;
    data["updatedBy"] = Globals.user?.id;
    data["folderPath"] = folderID;
    data["file"] = file;
    return data;
  }

  Map<String, dynamic> toEDMSJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // Top-level keys
    data["appRefNo"] = applicationId;
    data["fileName"] = files!.first.name;
    data["createdBy"] = Globals.user?.id;
    data["documentName"] = documentName;
    data["entityId"] = entityId;

    // Metadata object
    final Map<String, dynamic> metadata = <String, dynamic>{};
    metadata["AppRefNo"] = applicationId;
    metadata["RIMNo"] = companyRim;
    metadata["GroupId"] = groupRim.toString();
    metadata["GroupName"] = Globals.request?.groupName.toString();
    metadata["FileName"] = files!.first.name;
    metadata["Language"] = language?.name;
    metadata["DocType"] = documentType!.id;
    metadata["SubType"] = subType?.id;
    metadata["SubSubType"] = subSubType?.id;
    metadata["documentName"] = documentName;
    metadata["SubSubSubType"] = subSubSubType?.id;
    metadata["PeriodEndDate"] = date != null
        ? DateTimeUtils.formatDateTime(date!, format: "yyyy-MM-dd")
        : null;
    metadata["entityId"] = entityId;

    // Attach metadata to root
    data["metadata"] = metadata;
    return data;
  }
}
