import 'package:file_picker/file_picker.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/file_download_service/service.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class Document {
  String? sno;
  String? documentName;
  int? groupRim;
  String? companyRim;
  DateTime? lastUpdated;
  String? applicationId;
  Reference? documentType;
  Reference? subType;
  Reference? subSubType;
  Reference? subSubSubType;
  Reference? language;
  DateTime? date;
  List<PlatformFile>? files;
  int? folderID;
  int? docID;

  String? fileName;
  String? reference1;
  String? reference2;
  String? reference3;
  int? fileSize;
  String? documentModifiedDate;

  LoadingStatus downloadLoader = LoadingStatus.loaded;
  LoadingStatus deleteLoader = LoadingStatus.loaded;

  Document(
      {this.sno,
      this.documentName,
      this.groupRim,
      this.companyRim,
      this.documentType,
      this.lastUpdated,
      this.applicationId,
      this.subType,
      this.subSubType,
      this.language,
      this.date,
      this.files,
      this.folderID});

  Document.fromJson(
      Map<String, dynamic> json,
      List<Reference> documentTypes,
      List<Reference> subTypes,
      List<Reference> subSubTypes,
      List<Reference> subSubSubTypes,
      List<Reference> languages) {
    folderID = json['folderId'];
    docID = json['docId'];
    documentType = documentTypes.firstWhere((Reference type) {
      return type.id == json['docType'];
    });
    subType = subTypes.firstWhere((Reference type) {
      return type.id == json['subType'];
    }, orElse: () => Reference());
    subSubType = subSubTypes.firstWhere((Reference type) {
      return type.id == json['subSubType'];
    }, orElse: () => Reference());
    subSubSubType = subSubSubTypes.firstWhere((Reference type) {
      return type.id == json['subSubSubType'];
    }, orElse: () => Reference());
    language = languages.firstWhere((Reference type) {
      return type.id == int.tryParse("${json['language']}");
    }, orElse: () => Reference());
    fileName = json['fileName'];
    reference1 = json['reference1'];
    reference2 = json['reference2'];
    reference3 = json['reference3'];
    date = DateTimeUtils.parseDateTime(json['periodEndDate'],
        format: "yyyy-MM-dd");
    fileSize = json['fileSize'];
    documentModifiedDate = json['documentModifiedDate'];
    companyRim = json['reference1'];
    documentName = json['reference2'];
    files = [PlatformFile(name: json['fileName'], size: json['fileSize'])];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['appRefNo'] = applicationId;
    data['fileName'] = files!.first.name;
    data['rimNo'] = companyRim;
    data['groupId'] = Globals.request?.groupId.toString();
    data['groupName'] = Globals.request?.groupName.toString();
    data['language'] = language?.id;
    data['periodEndDate'] = date != null
        ? DateTimeUtils.formatDateTime(date!, format: "yyyy-MM-dd")
        : null;
    data['docType'] = documentType!.id;
    data['subType'] = subType?.id;
    data['subSubType'] = subSubType?.id;
    data['subSubSubType'] = subSubSubType;
    data['folderId'] = folderID;
    data['reference1'] = companyRim;
    data['reference2'] = documentName;
    data['reference3'] = reference3;
    data['userRole'] = Globals.user?.currentRole?.id ?? "";
    data['createdBy'] = Globals.user?.id;
    data['updatedBy'] = Globals.user?.id;
    data['folderPath'] = folderID;

    data['fileContentBase64'] =
        FileDownloadService.instance.fileToBase64(files!.first);
    return data;
  }

  Map<String, dynamic> toEDMSJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // Top-level keys
    data['appRefNo'] = applicationId;
    data['fileName'] = documentName ?? files!.first.name;
    data['content'] = FileDownloadService.instance.fileToBase64(files!.first);
    data['createdBy'] = Globals.user?.id;

    // Metadata object
    final Map<String, dynamic> metadata = <String, dynamic>{};
    metadata['AppRefNo'] = applicationId;
    metadata['RIMNo'] = companyRim;
    metadata['GroupId'] = groupRim.toString();
    metadata['GroupName'] = Globals.request?.groupName.toString();
    // metadata['CustomerName'] = customerName;
    metadata['FileName'] = documentName ?? files!.first.name;
    metadata['Language'] = language?.id;
    metadata['DocType'] = documentType!.id;
    metadata['SubType'] = subType?.id;
    metadata['SubSubType'] = subSubType?.id;
    metadata['SubSubSubType'] = subSubSubType;

    metadata['FileContentBase64'] =
        FileDownloadService.instance.fileToBase64(files!.first);
    metadata['PeriodEndDate'] = date != null
        ? DateTimeUtils.formatDateTime(date!, format: "yyyy-MM-dd")
        : null;

    // Attach metadata to root
    data['metadata'] = metadata;

    return data;
  }
}
