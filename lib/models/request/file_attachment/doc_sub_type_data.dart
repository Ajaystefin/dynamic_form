import 'package:intl/intl.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/file_details.dart';

class DocSubTypeData {
  final int? applicationID;
  final DateTime? date;
  Reference? subType;
  final String? docName;
  final String? summary;
  final String? decision;
  String? appRefNo;
  String? customerName;
  String? groupId;
  String? groupName;
  String? acNo;
  Reference? docType;
  Reference? subSubType;
  Reference? subSubSubType;
  String? language;
  String? applicationSummary;
  String? listItemGraphId;
  String? edmsDriveItemId;
  String? webUrl;
  String? fileName;
  bool isChecked;
  List<FileDetails>? files;

  DocSubTypeData({
    this.applicationID,
    this.date,
    this.docName,
    this.subType,
    this.summary,
    this.decision,
    this.appRefNo,
    this.customerName,
    this.groupId,
    this.groupName,
    this.acNo,
    this.docType,
    this.subSubType,
    this.subSubSubType,
    this.language,
    this.applicationSummary,
    this.listItemGraphId,
    this.edmsDriveItemId,
    this.webUrl,
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
    final appRefNo = json['appRefNo'];
    final customerName = json['customerName'];
    final groupId = json['groupId'];
    final groupName = json['groupName'];
    final acNo = json['acNo'];
    final decision = json['decision'];
    final applicationSummary = json['applicationSummary'];
    final listItemGraphId = json['listItemGraphId'];
    final edmsDriveItemId = json['edmsDriveItemId'];
    final webUrl = json['webUrl'];
    final fileName = json['fileName'];

    // Safe lookups with orElse
    final docType = documentTypes?.firstWhere(
      (type) => type.id == json['docType'],
      orElse: () => Reference(),
    );

    final subType = subTypes?.firstWhere(
      (type) => type.id == json['subType'],
      orElse: () => Reference(),
    );

    final subSubType = subSubTypes?.firstWhere(
      (type) => type.id == json['subSubType'],
      orElse: () => Reference(),
    );

    final subSubSubType = subSubSubTypes?.firstWhere(
      (type) => type.id == json['subSubSubType'],
      orElse: () => Reference(),
    );

    // Language (optional logic)
    final language = json['language']?.toString();

    // Application ID parsing
    final rawAppId = json['applicationID'];
    final appId =
        rawAppId is int ? rawAppId : int.tryParse(rawAppId?.toString() ?? '');

    // Date parsing
    DateTime? parsedDate;
    final rawDate = json['date']?.toString();
    if (rawDate != null) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(rawDate);
      } catch (_) {
        parsedDate = null;
      }
    }

    return DocSubTypeData(
      applicationID: appId,
      date: parsedDate,
      docName:
          fileName?.toString() ?? 'null', // docName from fileName.toString()
      summary: json['summary']?.toString() ?? '', // string coercion
      decision: decision?.toString() ?? '', // string coercion
      appRefNo: appRefNo,
      customerName: customerName,
      groupId: groupId,
      groupName: groupName,
      acNo: acNo,
      docType: docType,
      subType: subType,
      subSubType: subSubType,
      subSubSubType: subSubSubType,
      language: language,
      applicationSummary: applicationSummary,
      listItemGraphId: listItemGraphId,
      edmsDriveItemId: edmsDriveItemId,
      webUrl: webUrl,
      fileName: fileName,
    );
  }
}
