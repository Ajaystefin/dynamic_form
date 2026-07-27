import "dart:io";
import "package:file_picker/file_picker.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Represents a document uploaded to or retrieved from EDMS.
class Document {
  /// Creates a [Document] instance.
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

  /// Creates a [Document] instance from a JSON map.
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

  /// Serial number.
  String? sno;

  /// Document name.
  String? documentName;

  /// Entity identifier.
  String? entityId;

  /// Group RIM number.
  int? groupRim;

  /// Company RIM number.
  String? companyRim;

  /// Last updated date.
  DateTime? lastUpdated;

  /// Application reference number.
  String? applicationId;

  /// Document type.
  Reference? documentType;

  /// Document subtype.
  Reference? subType;

  /// Document sub-subtype.
  Reference? subSubType;

  /// Document sub-sub-subtype.
  Reference? subSubSubType;

  /// Document language.
  Reference? language;

  /// Language name.
  String? languageName;

  /// Period end date.
  DateTime? date;

  /// Attached files.
  List<PlatformFile>? files;

  /// Folder identifier.
  int? folderID;

  /// Document identifier.
  int? docID;

  /// File name.
  String? fileName;

  /// Physical file.
  File? file;

  /// Reference field 1.
  String? reference1;

  /// Reference field 2.
  String? reference2;

  /// Reference field 3.
  String? reference3;

  /// File size.
  int? fileSize;

  /// Document modified date.
  String? documentModifiedDate;

  /// Download operation status.
  LoadingStatus downloadLoader = LoadingStatus.loaded;

  /// Delete operation status.
  LoadingStatus deleteLoader = LoadingStatus.loaded;

  /// Converts this [Document] instance to a JSON map.
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

  /// Converts this [Document] instance to an EDMS payload.
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
