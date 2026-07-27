// class FileDetails {
//   FileDetails({
//     this.fileName,
//     this.filePath,
//     this.edmsDriveItemId,
//     this.webUrl,
//     this.isChecked = false,
//     this.docTypeId,
//     this.date,
//     this.groupId,
//     this.rimNo,
//     this.downloadName,
//   });

//   factory FileDetails.fromJson(Map<String, dynamic> json) {
//     final String? fileName = json["fileName"];
//     final String? filePath = json["filePath"];
//     final String? edmsDriveItemId = json["edmsDriveItemId"];
//     final String? webUrl = json["webUrl"] ?? json["filePath"];
//     final int? docTypeId = json["docTypeId"];
//     final DateTime? date = json["date"] ?? DateTime.now();
//     final String? groupId = json["groupId"];
//     final int? rimNo = json["rimNo"];
//     final String? downloadName = json["downloadName"];

//     return FileDetails(
//       fileName: fileName,
//       filePath: filePath,
//       webUrl: webUrl,
//       edmsDriveItemId: edmsDriveItemId,
//       docTypeId: docTypeId,
//       date: date,
//       groupId: groupId,
//       rimNo: rimNo,
//       downloadName: downloadName,
//     );
//   }
//   String? fileName;
//   String? filePath;
//   String? edmsDriveItemId;
//   bool isChecked;
//   String? webUrl;
//   int? docTypeId;
//   DateTime? date;
//   String? groupId;
//   int? rimNo;
//   String? downloadName;
// }
