import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/risk_rating/updated_rating.dart';

enum InternalRatingtype { override, cascade, none }

class InternalRating {
  Customer? customer;
  int? customerRiskRatingId;
  int? customerRimNo;
  String? customerName;
  int? ratingType;
  int? previousCRR;
  int? prevRatingDate;
  int? prevRatingSrc;
  int? proposedCRR;
  String? proposedRatingSrc;
  String? existingBasisOfCrr;
  String? proposedBasisOfCrr;
  int? proposedRatingDate;
  String? proposedModel;
  String? otherApplicantName;
  String? borrowerGuarantor;
  int? otherApplicantOption;
  int? otherApplicantRim;
  int? otherApplicantCrr;
  String? otherApplicantModel;
  String? overriddenCRR;
  String? overrideReason;
  String? cascadeReason;
  String? overrideComment;
  String? cascadeNote;
  String? sourceLongName;
  bool? isOverrideCRR;
  bool? isCascade;
  double? approvedRating;
  String? businessStatus;
  double? approvedCrr;
  int? crr;
  int? entityId;
  bool? isManualEntry;
  String? cbrbClassification;
  String? cbdCbrbClassification;
  bool? isDeleted;
  bool? isSpreadingInProgress;
  bool? isDeletable;
  bool? isChecked;
  String? ifrs;
  String? basisOfCrrPrefix;
  String? detailsOverride;
  String? proposedByCredit;
  bool? entityFilled;
  bool? supportParam;
  String? proposedFinacialYearDate;
  List<int?>? entities;
  InternalRatingtype? internalRatingType;
  bool? fromWcasDB;
  int? searchedRim;

  InternalRating({
    this.customer,
    this.cascadeReason,
    this.customerRiskRatingId,
    this.customerRimNo,
    this.customerName,
    this.ratingType,
    this.searchedRim,
    this.overrideComment,
    this.cascadeNote,
    this.previousCRR,
    this.prevRatingDate,
    this.businessStatus,
    this.prevRatingSrc,
    this.isCascade,
    this.proposedCRR,
    this.proposedRatingSrc,
    this.proposedRatingDate,
    this.proposedModel,
    this.otherApplicantName,
    this.otherApplicantOption,
    this.otherApplicantRim,
    this.otherApplicantCrr,
    this.otherApplicantModel,
    this.overriddenCRR,
    this.overrideReason,
    this.isOverrideCRR,
    this.approvedRating,
    this.approvedCrr,
    this.crr,
    this.entityId,
    this.isManualEntry,
    this.cbrbClassification,
    this.cbdCbrbClassification,
    this.isDeleted,
    this.isSpreadingInProgress,
    this.isDeletable,
    this.isChecked,
    this.sourceLongName,
    this.ifrs,
    this.entityFilled,
    this.supportParam,
    this.fromWcasDB,
    this.entities,
    this.basisOfCrrPrefix,
    this.detailsOverride,
    this.proposedByCredit,
    this.internalRatingType,
    this.proposedFinacialYearDate,
    this.proposedBasisOfCrr,
    this.existingBasisOfCrr,
    this.borrowerGuarantor,
  });

  InternalRating fromJsonMain(Map<String, dynamic> json) {
    InternalRating lameData = InternalRating.fromJson(json);
    return updateForUI(lameData);
  }

  InternalRating.fromJson(Map<String, dynamic> json) {
    fromWcasDB = true;
    customerName = json['customerName'];
    customerRimNo = json['rimNo'];
    overrideComment = json['overrideComment'];
    cascadeNote = json['cascadeNote'];
    customerRiskRatingId = json['customerRiskRatingId'];
    cascadeReason = json['cascadeReason'];
    businessStatus = json['businessStatus'];
    ratingType = json['ratingType'];
    // borrowerStatus = json['borrowerStatus'];
    borrowerGuarantor = json['borrowerGuarantor'];
    sourceLongName = json['sourceLongName'];
    ifrs = json['ifrsStaging'];
    previousCRR = json['prevCrr'];
    isCascade = json['isCascade'];
    proposedBasisOfCrr = json['proposedBasisOfCrr'];
    prevRatingDate = json['prevRatingDate'];
    proposedCRR = json['proposedCrr'];
    proposedRatingSrc = "${json['proposedRatingSource']}";
    proposedRatingDate = json['proposedRatingDate'];
    proposedModel = json['proposedModel'];
    otherApplicantName = json['otherApplicantName'];
    otherApplicantOption = json['otherApplicantOption'];
    otherApplicantRim = json['otherApplicantRim'];
    otherApplicantCrr = json['otherApplicantCrr'];
    otherApplicantModel = json['otherApplicantModel'];
    overriddenCRR = "${json['overriddenCRR'] ?? ""}";
    overrideReason = json['overrideReason'];
    isOverrideCRR = json['isOverrideCRR'];
    approvedRating = json['approvedRating'];
    approvedCrr = json['approvedCrr'];
    proposedByCredit = "${json['proposedByCredit'] ?? ""}";
    crr = json['crr'];
    entityId = json['entityId'] == 0 ? null : json['entityId'];
    isManualEntry = json['isManualEntry'];
    cbrbClassification = json['cbrbClassification'];
    cbdCbrbClassification = json['cbdCbrbClassification'];
    isDeleted = json['isDeleted'];
    isSpreadingInProgress = json['isSpreadingInProgress'];
    isChecked = json['isChecked'];
    proposedFinacialYearDate = json['proposedFinacialYearDate'];
    existingBasisOfCrr = json['existingBasisOfCrr'];
    proposedBasisOfCrr = json['proposedBasisOfCrr'];
  }

  InternalRating updateForUI(InternalRating existingRating) {
    bool isOverride = existingRating.isOverrideCRR == true;

    bool isCascade = existingRating.isCascade == true;

    return existingRating
      // ..borrowerStatus = existingRating.borrowerStatus
      ..entities =
          existingRating.entityId != null ? [existingRating.entityId] : null
      ..crr = existingRating.crr
      ..existingBasisOfCrr = existingRating.existingBasisOfCrr
      // ..basisOfCrrPrefix = isOverride
      //     ? "Override -"
      //     : isCascade
      //         ? "Cascade -"
      //         : null
      ..borrowerGuarantor = existingRating.borrowerGuarantor
      ..proposedModel = existingRating.proposedModel
      ..proposedCRR = existingRating.proposedCRR
      ..proposedBasisOfCrr = existingRating.proposedBasisOfCrr
      ..detailsOverride = isOverride
          ? existingRating.overrideComment
          : isCascade
              ? existingRating.cascadeNote
              : "NA"
      ..proposedByCredit = existingRating.proposedByCredit ?? ""
      ..entityFilled = entityId != null || entities?.length == 1
      ..internalRatingType = isOverride
          ? InternalRatingtype.override
          : isCascade
              ? InternalRatingtype.cascade
              : InternalRatingtype.none;
  }

  InternalRating fromUpdatedRatings(
      InternalRating existingRating, UpdatedRating? updatedRating,
      {bool isMultipleEntity = false, List<int?>? entities}) {
    final bool isOverride = updatedRating?.existinOverrideReason != null ||
        updatedRating?.existinOverrideGrade != null;
    final bool isCascade = updatedRating?.existingCascadeGrade != null ||
        updatedRating?.existingCascadeReason != null;

    return existingRating
      ..customerName = existingRating.customerName
      ..customerRimNo = existingRating.customerRimNo
      ..entities = existingRating.entities ?? entities
      ..ifrs = existingRating.ifrs
      ..fromWcasDB = existingRating.fromWcasDB
      ..entityId = isMultipleEntity ? null : updatedRating?.entityId
      ..crr = isMultipleEntity
          ? null
          : int.tryParse(getCrr(updatedRating?.existingFinalGrade) ?? "")
      ..basisOfCrrPrefix = isMultipleEntity
          ? null
          : isOverride
              ? "Override -"
              : isCascade
                  ? "Cascade -"
                  : null
      ..proposedModel = isMultipleEntity
          ? null
          : "${getCrr(updatedRating?.proposedFinalGrade)} - ${updatedRating?.proposedModelId} - ${updatedRating?.proposedFinacialYearDate}"
      ..proposedModel = isMultipleEntity ? null : updatedRating?.proposedModelId
      ..proposedCRR = isMultipleEntity
          ? null
          : int.tryParse(getCrr(updatedRating?.proposedFinalGrade) ?? '')
      ..overrideReason =
          isMultipleEntity ? null : updatedRating?.proposedOverrideReason
      ..cascadeReason =
          isMultipleEntity ? null : updatedRating?.proposedCascadeReason
      ..proposedBasisOfCrr = isMultipleEntity
          ? null
          : isOverride
              ? "Override - ${updatedRating?.proposedOverrideReason}"
              : isCascade
                  ? "Substitution Rating Due to ${updatedRating?.proposedCascadeReason} from ${updatedRating?.sourceLongName ?? ""}"
                  : "Model Rating"
      ..overrideComment =
          isMultipleEntity ? null : updatedRating?.proposedOverrideComment
      ..cascadeNote =
          isMultipleEntity ? null : updatedRating?.proposedCascadeNote
      ..detailsOverride = isMultipleEntity
          ? null
          : isOverride
              ? updatedRating?.proposedOverrideComment
              : isCascade
                  ? updatedRating?.proposedCascadeNote
                  : "NA"
      ..internalRatingType = isMultipleEntity
          ? null
          : isOverride
              ? InternalRatingtype.override
              : isCascade
                  ? InternalRatingtype.cascade
                  : InternalRatingtype.none
      ..existingBasisOfCrr = isMultipleEntity
          ? null
          : isOverride
              ? updatedRating?.existinOverrideReason
              : isCascade
                  ? updatedRating?.existingCascadeReason
                  : "${updatedRating?.existingMmodelId} - ${updatedRating?.existingFinacialYearDate}"
      ..proposedByCredit = isMultipleEntity
          ? null
          : updatedRating?.businessStatus == "Authorised Status"
              ? getCrr(updatedRating?.proposedFinalGrade)
              : "";
  }
}

String? getCrr(String? crr) {
  if (crr == null) {
    return null;
  }

  int start = crr.indexOf('\$') + 1;
  int end = crr.indexOf('#');

  if (start > 0 && end > start) {
    return crr.substring(start, end);
  } else {
    return crr;
  }
}
