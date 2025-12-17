import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/services/file_upload_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/state.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/models/request/file_attachment/appendix_entry.dart';
import 'package:wcas_frontend/models/request/file_attachment/document.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';

/// Image slot identifiers for the Country section.
enum CountryImageSlot { ratingBar, countryMap, governmentIndicators }

/// Ratings (Country).
const List<String> kCountryRatings = <String>[
  'AAA',
  'AA',
  'A',
  'BBB',
  'BB',
  'B',
  'CCC',
  'CC',
  'C',
  'D',
];

class AppendixViewModel extends Cubit<AppendixState> {
  LoadingStatus loaderStatus = LoadingStatus.loading;
  String? error;
  String? requestRefNo;
  String? countryName;
  String? population;
  String? gdp;
  String? selectedRating;
  List<Document> uploadedDocuments = [];
  List<PlatformFile> selectedFiles = [];
  String? errorMessage;
  String? rating;
  DateTime? selectedDate;
  String? applicationId;
  final FileUploadService _fileService;
  final List<AppendixEntry> entries = [];
  bool showCorporateSection = false;
  bool showFinancialSection = false;
  bool showFinancialCFSection = false;
  List<Country>? countries;

  List<String> selectedExportPartners = [];
  List<String> selectedImportPartners = [];
  List<String>? strengths = [];
  List<String>? threats = [];
  String selectedSectionType = 'Country';
  late CustomerRepository repositoryCustomer;
  List<String> fieldValues = [''];
  AppendixViewModel({FileUploadService? files})
      : _fileService = files ?? FileUploadService.instance,
        super(const AppendixState());

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Future<void> init(BuildContext context) async {
    showCorporateSection = false;
    //     Utils.checkBusinessSegment(BusinessSegment.corporate);
    showFinancialSection = true;
    // Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    showFinancialCFSection = false;
    // Utils.checkBusinessSegment(BusinessSegment.financialInstitutionCF);
    repositoryCustomer = CustomerRepository.instance;

    await getCountries();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getCountries() async {
    try {
      countries = (await repositoryCustomer.getCountries() ?? [])
        ..sort((a, b) => (a.description ?? '').compareTo(b.description ?? ''));
      logger.i('Dropdown items: $countryNames');
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching getCountries : $e');
    }
  }

  /// Adds a new appendix entry.
  void onAddAppendix() {
    final updated = List<AppendixEntry>.from(entries)
      ..add(AppendixEntry(
        id: const Uuid().v4(),
      ));
    entries
      ..clear()
      ..addAll(updated);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes an appendix entry.
  void onRemoveAppendix(String id) {
    entries.removeWhere((e) => e.id == id);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates an appendix entry (label/value).
  void onUpdateAppendix(String id, {String? label, String? value}) {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].id == id) {
        entries[i] = entries[i].copyWith(
          label: label ?? entries[i].label,
          value: value ?? entries[i].value,
        );
        break;
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateExportPartners(List<String> selected) {
    selectedExportPartners = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateImportPartners(List<String> selected) {
    selectedImportPartners = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  List<String> get countryNames {
    return countries?.map((c) => c.description ?? '').toList() ?? [];
  }

  void addStrengthTableRow() {
    strengths!.add('');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void removeStrengthTableRow(int index) {
    if (index >= 0 && index < strengths!.length) {
      strengths!.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void addThreatTableRow() {
    threats!.add('');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void removeThreatTableRow(int index) {
    if (index >= 0 && index < threats!.length) {
      threats!.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void updateStrengths(List<String> updated) {
    strengths = updated;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateThreats(List<String> updated) {
    threats = updated;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Save handler with validation & status transitions.
  Future<void> onSavePress({bool isContinue = false}) async {
    final isValid = formKey.currentState?.validate() ?? false;
    // if (!(formKey.currentState?.validate() ?? false)) return;
    if (!isValid) {
      AlertManager().showFailureToast("common.validation.emptyField".tr());
      return;
    }
    formKey.currentState?.save();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showSuccessToast("common.saveSuccess".tr());
      LayoutViewModel().goToNextRoute();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast(e.toString());
    }
  }

  void updateSelectedSectionType(String value) {
    selectedSectionType = value;
    emit(
        state.copyWith(loaderStatus: LoadingStatus.loaded)); // triggers rebuild
  }

  /// Opens a file picker to select multiple files.
  /// Adds selected files to the uploaded documents list.
  /// Shows success or failure toast based on result.
  Future<void> pickMultipleFiles() async {
    final Document currentDocument = Document();
    if (!(formKey.currentState!.validate())) {
    } else {
      try {
        formKey.currentState?.save();

        List<PlatformFile>? files = await _fileService.pickMultipleFiles();

        if (files != null && files.isNotEmpty) {
          currentDocument.files = files;
          selectedFiles = files;
          uploadedDocuments.add(currentDocument);
          errorMessage = null;
          AlertManager().showSuccessToast(
              "eDigitalFilingFileAttachments.appendix.documentUploadedSuccessFully"
                  .tr());
        } else {
          errorMessage =
              "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr();
          selectedFiles = [];
        }
      } catch (e) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes a file and its associated document at the given [index],
  void removeFileAt(int index) {
    if (index >= 0 &&
        index < selectedFiles.length &&
        index < uploadedDocuments.length) {
      uploadedDocuments.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Sets the selected rating value and emits a state update.
  void setRating(String value) {
    selectedRating = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets the application ID and emits a state update.
  void setApplicationId(String? value) {
    applicationId = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets the selected date for the appendix entry.
  void setSelectedDate(DateTime value) {
    selectedDate = value;
  }

  /// Sets the country name for the appendix entry.
  void setCountryName(String? value) {
    countryName = value;
  }

  /// Sets the population value for the appendix entry.
  void setPopulation(String? value) {
    population = value;
  }

  /// Sets the GDP value for the appendix entry.
  void setGdp(String? value) {
    gdp = value;
  }
}
