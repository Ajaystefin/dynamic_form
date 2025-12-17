class FileDetails {
  String? fileName;
  String? filePath;
  String? fileId;
  bool isChecked;

  FileDetails(
      {this.fileName, this.filePath, this.fileId, this.isChecked = false});

  factory FileDetails.fromJson(Map<String, dynamic> json) {
    final fileName = json['fileName'];
    final filePath = json['filePath'];
    final fileId = json['fileId'];

    return FileDetails(fileName: fileName, filePath: filePath, fileId: fileId);
  }
}
