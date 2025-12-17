// import 'package:file_picker/file_picker.dart';
// import 'package:wcas_frontend/core/utils/utils.dart';

// class FiCountryData {
//   final String countryName;
//   final String? rating;
//   final String populationText;
//   final String gdpText;

//   final String exportPartners;
//   final String importPartners;
//   final String strengths;
//   final String threats;

//   final PlatformFile? ratingBarImage;
//   final PlatformFile? countryMapImage;
//   final PlatformFile? governmentIndicatorsImage;

//   final LoadingStatus status;
//   final String? error;

//   const FiCountryData({
//     this.countryName = '',
//     this.rating,
//     this.populationText = '',
//     this.gdpText = '',
//     this.exportPartners = '',
//     this.importPartners = '',
//     this.strengths = '',
//     this.threats = '',
//     this.ratingBarImage,
//     this.countryMapImage,
//     this.governmentIndicatorsImage,
//     this.status = LoadingStatus.loaded,
//     this.error,
//   });

//   bool get canSave =>
//       countryName.trim().isNotEmpty &&
//       (rating != null && rating!.isNotEmpty) &&
//       populationText.trim().isNotEmpty &&
//       gdpText.trim().isNotEmpty &&
//       exportPartners.trim().isNotEmpty &&
//       importPartners.trim().isNotEmpty &&
//       strengths.trim().isNotEmpty &&
//       threats.trim().isNotEmpty &&
//       ratingBarImage != null &&
//       countryMapImage != null &&
//       governmentIndicatorsImage != null &&
//       status != LoadingStatus.loading;

//   FiCountryData copyWith({
//     String? countryName,
//     String? rating,
//     String? populationText,
//     String? gdpText,
//     String? exportPartners,
//     String? importPartners,
//     String? strengths,
//     String? threats,
//     PlatformFile? ratingBarImage,
//     PlatformFile? countryMapImage,
//     PlatformFile? governmentIndicatorsImage,
//     LoadingStatus? status,
//     String? error,
//   }) {
//     return FiCountryData(
//       countryName: countryName ?? this.countryName,
//       rating: rating ?? this.rating,
//       populationText: populationText ?? this.populationText,
//       gdpText: gdpText ?? this.gdpText,
//       exportPartners: exportPartners ?? this.exportPartners,
//       importPartners: importPartners ?? this.importPartners,
//       strengths: strengths ?? this.strengths,
//       threats: threats ?? this.threats,
//       ratingBarImage: ratingBarImage ?? this.ratingBarImage,
//       countryMapImage: countryMapImage ?? this.countryMapImage,
//       governmentIndicatorsImage:
//           governmentIndicatorsImage ?? this.governmentIndicatorsImage,
//       status: status ?? this.status,
//       error: error,
//     );
//   }
// }