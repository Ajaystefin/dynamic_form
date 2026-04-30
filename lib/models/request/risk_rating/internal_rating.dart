import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";

enum InternalRatingtype { override, cascade, none }

class InternalRating {
  InternalRating({
    this.customer,
    this.rimWithNoEntity,
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
    this.secondBestRating,
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
    this.isDeleted = false,
    this.isSpreadingInProgress,
    this.isDeletable = false,
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

  InternalRating.fromJson(Map<String, dynamic> json) {
    fromWcasDB = true;
    customerName = json["customerName"];
    secondBestRating = json["secondBestRating"];
    customerRimNo = json["rimNo"];
    overrideComment = json["overrideComment"];
    cascadeNote = json["cascadeNote"];
    customerRiskRatingId = json["customerRiskRatingId"];
    cascadeReason = json["cascadeReason"];
    businessStatus = json["businessStatus"];
    ratingType = json["ratingType"];
    borrowerGuarantor = json["borrowerGuarantor"];
    sourceLongName = json["sourceLongName"];
    ifrs = json["ifrsStaging"];
    previousCRR = json["prevCrr"];
    isCascade = json["isCascade"];
    proposedBasisOfCrr = json["proposedBasisOfCrr"];
    prevRatingDate = json["prevRatingDate"];
    proposedCRR = json["proposedCrr"];
    proposedRatingSrc = "${json['proposedRatingSource']}";
    proposedRatingDate = json["proposedRatingDate"];
    proposedModel = json["proposedModel"];
    otherApplicantName = json["otherApplicantName"];
    otherApplicantOption = json["otherApplicantOption"];
    otherApplicantRim = json["otherApplicantRim"];
    otherApplicantCrr = json["otherApplicantCrr"];
    otherApplicantModel = json["otherApplicantModel"];
    overriddenCRR = "${json['overriddenCRR'] ?? ""}";
    overrideReason = json["overrideReason"];
    isOverrideCRR = json["isOverrideCRR"];
    approvedRating = json["approvedRating"];
    approvedCrr = json["approvedCrr"];
    proposedByCredit = "${json['proposedByCredit'] ?? ""}";
    crr = json["crr"];
    isDeletable = json["isDeletable"];
    entityId = json["entityId"] == 0 ? null : json["entityId"];
    isManualEntry = json["isManualEntry"];
    cbrbClassification = json["cbrbClassification"];
    cbdCbrbClassification = json["cbdCbrbClassification"];
    isDeleted = json["isDeleted"];
    isSpreadingInProgress = json["isSpreadingInProgress"];
    isChecked = json["isChecked"];
    proposedFinacialYearDate = json["proposedFinacialYearDate"];
    existingBasisOfCrr = json["existingBasisOfCrr"];
    detailsOverride = json["detailsOverride"];
    proposedBasisOfCrr = json["proposedBasisOfCrr"];
  }
  Customer? customer;
  int? customerRiskRatingId;
  int? customerRimNo;
  String? customerName;
  int? ratingType;
  String? secondBestRating;
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
  bool? rimWithNoEntity;

  InternalRating fromJsonMain(Map<String, dynamic> json) {
    final InternalRating lameData = InternalRating.fromJson(json);
    return updateForUI(lameData);
  }

  InternalRating updateForUI(InternalRating existingRating) {
    final bool isOverride = existingRating.isOverrideCRR == true;
    final bool isCascade = existingRating.isCascade == true;

    return existingRating
      ..entities =
          existingRating.entityId != null ? [existingRating.entityId] : null
      ..crr = existingRating.crr
      ..existingBasisOfCrr = existingRating.existingBasisOfCrr
      ..secondBestRating = existingRating.secondBestRating
      ..borrowerGuarantor = existingRating.borrowerGuarantor
      ..proposedModel = existingRating.proposedModel
      ..proposedCRR = existingRating.proposedCRR
      ..proposedBasisOfCrr = existingRating.proposedBasisOfCrr
      ..detailsOverride = existingRating.detailsOverride
      ..proposedByCredit = existingRating.proposedByCredit ?? ""
      ..entityFilled = entityId != null || entities?.length == 1
      ..internalRatingType = isOverride
          ? InternalRatingtype.override
          : (isCascade ? InternalRatingtype.cascade : InternalRatingtype.none);
  }

  InternalRating fromUpdatedRatings(
    InternalRating existingRating,
    UpdatedRating? updatedRating, {
    bool isMultipleEntity = false,
    List<int?>? entities,
  }) {
    final bool isExistingOverride =
        updatedRating?.existingOverrideReason != null ||
            updatedRating?.existingOverrideGrade != null;

    final bool isExistingCascade =
        updatedRating?.existingCascadeGrade != null ||
            updatedRating?.existingCascadeReason != null;

    final bool isProposedOverride =
        updatedRating?.proposedOverrideReason != null ||
            updatedRating?.proposedOverrideGrade != null;

    final bool isProposedCascade =
        updatedRating?.proposedCascadeGrade != null ||
            updatedRating?.proposedCascadeReason != null;

    // --- Precompute CRR string values once ---
    final String? existingCrrStr = getCrr(updatedRating?.existingFinalGrade);
    String? proposedCrrStr = getCrr(updatedRating?.proposedFinalGrade);
    // ignore: unused_local_variable
    final String? proposedCascadeCrrStr =
        getCrr(updatedRating?.proposedCascadeGrade);

    // --- Base fields that always carry over ---
    final InternalRating result = existingRating
      ..customerName = existingRating.customerName
      ..customerRimNo = existingRating.customerRimNo
      ..entities = existingRating.entities ?? entities
      ..ifrs = existingRating.ifrs
      ..fromWcasDB = existingRating.fromWcasDB;

    // --- Early return for multiple-entity branch (null-out single-entity
    // fields) ---
    if (isMultipleEntity) {
      return result
        ..entityId = null
        ..crr = null
        ..basisOfCrrPrefix = null
        ..proposedModel = null
        ..proposedCRR = null
        ..overrideReason = null
        ..cascadeReason = null
        ..proposedBasisOfCrr = null
        ..overrideComment = null
        ..cascadeNote = null
        ..detailsOverride = null
        ..internalRatingType = null
        ..existingBasisOfCrr = null
        ..proposedByCredit = null;
    }

    // --- Single-entity branch ---

    // basisOfCrrPrefix
    String? basisOfCrrPrefix;
    if (isExistingOverride) {
      basisOfCrrPrefix = "Override -";
    } else if (isExistingCascade) {
      basisOfCrrPrefix = "Cascade -";
    } else {
      basisOfCrrPrefix = null;
    }

    // proposedModel: "" if proposedModelName is null; otherwise "<CRR> -
    // <ModelName> - <FY>"
    final String? proposedModelName = updatedRating?.proposedModelName;
    final String proposedModel = (proposedModelName == null)
        ? ""
        : "${proposedCrrStr ?? ""} - $proposedModelName "
            "- ${updatedRating?.proposedFinacialYearDate}";

    // [proposedBasisOfCrr] & [detailsOverride] depend on proposed override/cascade flags
    String proposedBasisOfCrr;
    String detailsOverride;
    if (isProposedOverride) {
      proposedBasisOfCrr = (updatedRating?.proposedOverrideReason == null ||
              updatedRating?.proposedOverrideReason == "")
          ? ""
          : "Override - ${updatedRating?.proposedOverrideReason}";
      detailsOverride = updatedRating?.proposedOverrideComment ?? "";
    } else if (isProposedCascade) {
      proposedCrrStr = proposedCascadeCrrStr;
      proposedBasisOfCrr =
          "Substitution Rating Due to ${updatedRating?.proposedCascadeReason} "
          "from ${updatedRating?.sourceLongName ?? ""}";

      detailsOverride = updatedRating?.proposedCascadeNote ?? "";
    } else {
      proposedBasisOfCrr = "Model Rating";
      detailsOverride = "";
    }

    // [internalRatingType] & [existingBasisOfCrr] depend on existing override/cascade flags
    InternalRatingtype internalRatingType;
    String? existingBasisOfCrr;
    if (isExistingOverride) {
      internalRatingType = InternalRatingtype.override;
      existingBasisOfCrr = updatedRating?.existingOverrideReason;
    } else if (isExistingCascade) {
      internalRatingType = InternalRatingtype.cascade;
      existingBasisOfCrr = updatedRating?.existingCascadeReason;
    } else {
      internalRatingType = InternalRatingtype.none;
      existingBasisOfCrr = updatedRating?.existingModelName == null
          ? ""
          : "${updatedRating?.existingModelName} - "
              "${updatedRating?.existingFinacialYearDate}";
    }

    // proposedByCredit: show proposed CRR string only when AUTHORIZED; else ""
    final String proposedByCredit =
        updatedRating?.businessStatus == "AUTHORIZED"
            ? (proposedCrrStr ?? "")
            : "";

    // Final assignments for the single-entity branch
    return result
      ..entityId = updatedRating?.entityId
      ..crr = existingCrrStr == null ? null : int.tryParse(existingCrrStr)
      ..basisOfCrrPrefix = basisOfCrrPrefix
      ..proposedModel = proposedModel
      ..proposedCRR =
          proposedCrrStr == null ? null : int.tryParse(proposedCrrStr)
      ..overrideReason = updatedRating?.proposedOverrideReason
      ..cascadeReason = updatedRating?.proposedCascadeReason
      ..proposedBasisOfCrr = proposedBasisOfCrr
      ..overrideComment = updatedRating?.proposedOverrideComment
      ..cascadeNote = updatedRating?.proposedCascadeNote
      ..detailsOverride = detailsOverride
      ..internalRatingType = internalRatingType
      ..existingBasisOfCrr = existingBasisOfCrr
      ..proposedByCredit = proposedByCredit;
  }
}

/// Extracts the numeric CRR portion from a token like `$<CRR>#...`.
/// If input doesn't match the `$...#` pattern, returns the original string.
/// (Functionality unchanged.)
String? getCrr(String? crr) {
  if (crr == null) {
    return null;
  }

  final int start = crr.indexOf(r"$") + 1;
  final int end = crr.indexOf("#");

  if (start > 0 && end > start) {
    return crr.substring(start, end);
  } else {
    return crr;
  }
}
