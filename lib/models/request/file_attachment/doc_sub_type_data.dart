import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/file_details.dart";

class DocSubTypeData {
  DocSubTypeData({
    this.applicationID,
    this.date,
    this.decisionDate,
    this.docName,
    this.subType,
    this.summary,
    this.decision,
    this.rimNo,
    this.appRefNo,
    this.customerName,
    this.groupId,
    this.groupName,
    this.acNo,
    this.docType,
    this.docTypeId,
    this.subSubType,
    this.subSubSubType,
    this.language,
    this.applicationSummary,
    this.listItemGraphId,
    this.edmsDriveItemId,
    this.webUrl,
    this.downloadName,
    this.referenceNo,
    this.remarks,
    this.fileName,
    this.isChecked = false,
    this.files,
  });

  factory DocSubTypeData.fromJson(
    Map<String, dynamic> json,
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
  ) {
    // Basic fields
    final appRefNo = json["appRefNo"];
    final docName = json["documentName"];
    final customerName = json["customerName"];
    final groupId = json["groupId"];
    final groupName = json["groupName"];
    final acNo = json["accountNo"];
    final decision = json["decision"];
    final rimNo = json["rimNo"];
    final referenceNo = json["referenceNo"];
    final applicationSummary = json["applicationSummary"];
    final listItemGraphId = json["listItemGraphId"];
    final edmsDriveItemId = json["edmsDriveItemId"];
    final webUrl = json["webUrl"];
    final fileName = json["fileName"];
    final remarks = json["remarks"];

    final List<Reference> referenceList = [
      ...?documentTypes,
      ...?subTypes,
      ...?subSubTypes,
      ...?subSubSubTypes,
      ...?languages,
    ];

    // ✅ Compute docTypeId safely (nullable)
    final rawDocType = json["docType"];
    final docTypeId = rawDocType is int
        ? Utils.getDocumentTypeById(rawDocType)
        : rawDocType != null
            ? Utils.getDocumentTypeById(
                int.tryParse(rawDocType.toString()) ?? 0,
              )
            : null;

    // Safe lookups with orElse
    final docType = referenceList.firstWhere(
      (type) => type.id == json["docType"],
      orElse: Reference.new,
    );

    final subType = referenceList.firstWhere(
      (type) => type.id == json["subType"],
      orElse: Reference.new,
    );

    final subSubType = referenceList.firstWhere(
      (type) => type.id == json["subSubType"],
      orElse: Reference.new,
    );

    final subSubSubType = referenceList.firstWhere(
      (type) => type.id == json["subSubSubType"],
      orElse: Reference.new,
    );

    // Language (optional logic)
    final language = json["language"]?.toString();

    // Application ID parsing
    final rawAppId = json["applicationID"];
    final appId =
        rawAppId is int ? rawAppId : int.tryParse(rawAppId?.toString() ?? "");

    // Date parsing
    DateTime? parsedDate1;
    final String? rawDate1 =
        json["periodEndDate"]?.toString() ?? json["created"]?.toString();
    if (rawDate1 != null) {
      try {
        parsedDate1 = DateTime.parse(rawDate1);
      } catch (_) {
        parsedDate1 = null;
      }
    }

    DateTime? parsedDate2;
    final String? rawDate2 =
        json["decisionDate"]?.toString() ?? json["created"]?.toString();
    if (rawDate2 != null) {
      try {
        parsedDate2 = DateTime.parse(rawDate2);
      } on Exception catch (_) {
        parsedDate2 = null;
      }
    }

    return DocSubTypeData(
      applicationID: appId,
      date: parsedDate1,
      docName: docName ?? "null", // docName from fileName.toString()
      summary: json["summary"]?.toString() ?? "", // string coercion
      decision: decision?.toString() ?? "", // string coercion
      appRefNo: appRefNo,
      customerName: customerName,
      groupId: groupId,
      groupName: groupName,
      acNo: acNo,
      docType: docType,
      docTypeId: docTypeId,
      subType: subType,
      subSubType: subSubType,
      subSubSubType: subSubSubType,
      language: language,
      applicationSummary: applicationSummary,
      listItemGraphId: listItemGraphId,
      edmsDriveItemId: edmsDriveItemId,
      webUrl: webUrl,
      fileName: fileName,
      downloadName: fileName,
      referenceNo: referenceNo,
      decisionDate: parsedDate2,
      remarks: remarks,
      rimNo: rimNo,
    );
  }
  final int? applicationID;
  final DateTime? date;

  /// The date on which the decision was made.
  ///
  /// Can be `null` if the decision has not yet been finalized.
  final DateTime? decisionDate;
  Reference? subType;
  final String? docName;
  final String? summary;
  final String? decision;
  final String? rimNo;
  String? appRefNo;
  String? customerName;
  String? groupId;
  String? groupName;
  String? acNo;
  Reference? docType;
  DocumentType? docTypeId;
  Reference? subSubType;
  Reference? subSubSubType;
  String? language;
  String? applicationSummary;
  String? listItemGraphId;
  String? edmsDriveItemId;
  String? webUrl;
  String? downloadName;
  String? fileName;
  bool isChecked;
  List<FileDetails>? files;
  String? referenceNo;
  String? remarks;
}
