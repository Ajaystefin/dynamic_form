// import 'package:file_picker/file_picker.dart';
// import 'package:wcas_frontend/core/utils/utils.dart';

// class FiBankData {
//   final String applicationId;
//   final DateTime? periodEndDate;
//   final List<PlatformFile> files;
//   final LoadingStatus status;
//   final String? error;

//   const FiBankData({
//     this.applicationId = '',
//     this.periodEndDate,
//     this.files = const [],
//     this.status = LoadingStatus.loaded,
//     this.error,
//   });

//   bool get canUpload =>
//       applicationId.trim().isNotEmpty &&
//       periodEndDate != null &&
//       files.isNotEmpty &&
//       status != LoadingStatus.loading;

//   FiBankData copyWith({
//     String? applicationId,
//     DateTime? periodEndDate,
//     List<PlatformFile>? files,
//     LoadingStatus? status,
//     String? error,
//   }) {
//     return FiBankData(
//       applicationId: applicationId ?? this.applicationId,
//       periodEndDate: periodEndDate ?? this.periodEndDate,
//       files: files ?? this.files,
//       status: status ?? this.status,
//       error: error,
//     );
//   }
// }
