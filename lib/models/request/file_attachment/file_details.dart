class FileDetails {
  FileDetails({
    this.fileName,
    this.filePath,
    this.edmsDriveItemId,
    this.webUrl,
    this.isChecked = false,
    this.docTypeId,
    this.date,
    this.groupId,
    this.rimNo,
    this.downloadName,
  });

  factory FileDetails.fromJson(Map<String, dynamic> json) {
    final fileName = json["fileName"];
    final filePath = json["filePath"];
    final edmsDriveItemId = json["edmsDriveItemId"];
    final webUrl = json["webUrl"] ?? json["filePath"];
    final docTypeId = json["docTypeId"];
    final date = json["date"] ?? DateTime.now();
    final groupId = json["groupId"];
    final rimNo = json["rimNo"];
    final downloadName = json["downloadName"];

    return FileDetails(
      fileName: fileName,
      filePath: filePath,
      webUrl: webUrl,
      edmsDriveItemId: edmsDriveItemId,
      docTypeId: docTypeId,
      date: date,
      groupId: groupId,
      rimNo: rimNo,
      downloadName: downloadName,
    );
  }
  String? fileName;
  String? filePath;
  String? edmsDriveItemId;
  bool isChecked;
  String? webUrl;
  int? docTypeId;
  DateTime? date;
  String? groupId;
  int? rimNo;
  String? downloadName;
}
