// lib/features/request/file_attachment_digital_efiling/appendix/appendix_model.dart
import 'package:file_picker/file_picker.dart';
import 'package:wcas_frontend/models/request/file_attachment/appendix_entry.dart';

/// Pure business model. No UI flags or errors here.
class Appendix {
  final String groupCorporateStructure;
  final List<AppendixEntry> entries;
  final List<PlatformFile> files;
  final String countryName;
  final String? rating;
  final String populationText;
  final String gdpText;
  final String exportPartners;
  final String importPartners;
  final String strengths;
  final String threats;
  final PlatformFile? ratingBarImage;
  final PlatformFile? countryMapImage;
  final PlatformFile? governmentIndicatorsImage;

  const Appendix({
    this.groupCorporateStructure = '',
    this.entries = const <AppendixEntry>[],
    this.files = const <PlatformFile>[],
    this.countryName = '',
    this.rating,
    this.populationText = '',
    this.gdpText = '',
    this.exportPartners = '',
    this.importPartners = '',
    this.strengths = '',
    this.threats = '',
    this.ratingBarImage,
    this.countryMapImage,
    this.governmentIndicatorsImage,
  });
}
