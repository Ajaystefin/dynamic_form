import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";

/// Represents the type of internal rating.
enum InternalRatingtype { override, cascade, none }

/// Represents an internal customer risk rating record.
class InternalRating {
  /// Creates an [InternalRating] instance.
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

  /// Creates an [InternalRating] instance from a JSON map.
  InternalRating.fromJson(Map<String, dynamic> json) {
    fromWcasDB = true;
    customerName = json["customerName"];
    secondBestRating = json["secondBestRating"];
    customerRimNo = json["rimNo"];
    overrideComment = json["overrideComment"];
    cascadeNote = json["cascadeNote"];
    customerRiskRatingId = ((json["customerRiskRatingId"] ?? 0) == 0)
        ? Utils.randomDigits()
        : json["customerRiskRatingId"];

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

  /// Customer associated with the rating.
  Customer? customer;

  /// Customer risk rating identifier.
  int? customerRiskRatingId;

  /// Customer RIM number.
  int? customerRimNo;

  /// Customer name.
  String? customerName;

  /// Rating type identifier.
  int? ratingType;

  /// Second best rating.
  String? secondBestRating;

  /// Previous CRR.
  int? previousCRR;

  /// Previous rating date.
  int? prevRatingDate;

  /// Previous rating source.
  int? prevRatingSrc;

  /// Proposed CRR.
  int? proposedCRR;

  /// Proposed rating source.
  String? proposedRatingSrc;

  /// Existing basis of CRR.
  String? existingBasisOfCrr;

  /// Proposed basis of CRR.
  String? proposedBasisOfCrr;

  /// Proposed rating date.
  int? proposedRatingDate;

  /// Proposed model.
  String? proposedModel;

  /// Other applicant name.
  String? otherApplicantName;

  /// Borrower or guarantor indicator.
  String? borrowerGuarantor;

  /// Other applicant option.
  int? otherApplicantOption;

  /// Other applicant RIM number.
  int? otherApplicantRim;

  /// Other applicant CRR.
  int? otherApplicantCrr;

  /// Other applicant model.
  String? otherApplicantModel;

  /// Overridden CRR.
  String? overriddenCRR;

  /// Override reason.
  String? overrideReason;

  /// Cascade reason.
  String? cascadeReason;

  /// Override comment.
  String? overrideComment;

  /// Cascade note.
  String? cascadeNote;

  /// Source long name.
  String? sourceLongName;

  /// Indicates whether the rating is overridden.
  bool? isOverrideCRR;

  /// Indicates whether the rating is cascaded.
  bool? isCascade;

  /// Approved rating.
  double? approvedRating;

  /// Business status.
  String? businessStatus;

  /// Approved CRR.
  double? approvedCrr;

  /// Current CRR.
  int? crr;

  /// Entity identifier.
  int? entityId;

  /// Indicates whether the record was manually entered.
  bool? isManualEntry;

  /// CBRB classification.
  String? cbrbClassification;

  /// CBD CBRB classification.
  String? cbdCbrbClassification;

  /// Indicates whether the record is deleted.
  bool? isDeleted;

  /// Indicates whether spreading is in progress.
  bool? isSpreadingInProgress;

  /// Indicates whether the record can be deleted.
  bool? isDeletable;

  /// Indicates whether the record is selected.
  bool? isChecked;

  /// IFRS staging.
  String? ifrs;

  /// Basis of CRR prefix.
  String? basisOfCrrPrefix;

  /// Override details.
  String? detailsOverride;

  /// Proposed by credit value.
  String? proposedByCredit;

  /// Indicates whether entity information is populated.
  bool? entityFilled;

  /// Support parameter.
  bool? supportParam;

  /// Proposed financial year date.
  String? proposedFinacialYearDate;

  /// Associated entity identifiers.
  List<int?>? entities;

  /// Internal rating type.
  InternalRatingtype? internalRatingType;

  /// Indicates whether the record originated from WCAS.
  bool? fromWcasDB;

  /// Searched RIM number.
  int? searchedRim;

  /// Indicates whether the RIM has no entity.
  bool? rimWithNoEntity;

  /// proposedOverrideGrade
  String? proposedOverrideGrade;

  /// Creates an [InternalRating] instance from a main JSON payload.
  InternalRating fromJsonMain(Map<String, dynamic> json) {
    final InternalRating lameData = InternalRating.fromJson(json);
    return updateForUI(lameData);
  }

  /// Updates rating information for UI consumption.
  InternalRating updateForUI(InternalRating existingRating) {
    final bool isOverride = existingRating.isOverrideCRR ?? false;
    final bool isCascade = existingRating.isCascade ?? false;

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

  /// Updates the rating using the supplied rating information.
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
    final String? proposedCascadeCrrStr =
        getCrr(updatedRating?.proposedCascadeGrade);
    final String? proposedOverrideCrrStr =
        getCrr(updatedRating?.proposedOverrideGrade);

    // --- Base fields that always carry over ---
    final InternalRating result = existingRating
      ..customerName = existingRating.customerName
      ..customerRimNo = existingRating.customerRimNo
      ..entities = existingRating.entities ?? entities
      ..ifrs = existingRating.ifrs
      ..customerRiskRatingId = existingRating.customerRiskRatingId
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
      proposedCrrStr = proposedOverrideCrrStr;
    } else if (isProposedCascade) {
      proposedCrrStr = proposedCascadeCrrStr;
      proposedBasisOfCrr =
          "Substitution Rating Due to ${updatedRating?.proposedCascadeReason} "
          "from ${updatedRating?.sourceLongName ?? ""}";

      detailsOverride = updatedRating?.proposedCascadeNote ?? "";
    } else {
      proposedBasisOfCrr = "Model Rating";
      detailsOverride = "NA";
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
///
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
