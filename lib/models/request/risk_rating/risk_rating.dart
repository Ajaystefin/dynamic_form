import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";

/// Represents internal and external risk ratings associated
/// with a customer or application.
class RiskRating {
  /// Creates a [RiskRating] instance.
  RiskRating({
    required this.internalRatings,
    this.externalRatings,
    this.comments,
    this.externalComments,
  });

  /// Creates a [RiskRating] instance from a JSON map.
  factory RiskRating.fromJson(Map<String, dynamic> json) {
    return RiskRating(
      externalRatings: (json["externalRatingList"] as List<dynamic>?)
              ?.where((e) => e["isDeleted"] != true)
              .map((e) => ExternalRating.fromJson(e))
              .toList() ??
          [],
      internalRatings: (json["internalRatingList"] as List<dynamic>?)
              ?.where((e) => e["isDeleted"] != true)
              .map((e) => InternalRating().fromJsonMain(e))
              .toList() ??
          [],
    );
  }

  /// External ratings.
  List<ExternalRating>? externalRatings;

  /// Internal ratings.
  List<InternalRating> internalRatings;

  /// Internal rating comments.
  String? comments;

  /// External rating comments.
  String? externalComments;

  /// Converts risk rating data to a JSON payload.
  static Map<String, dynamic> toJson({
    required List<ExternalRating> externalRatings,
    required List<InternalRating> internalRatings,
    required bool isClDown,
    required bool isFiFlow,
  }) {
    return {
      "internalRatingList": internalRatings
          .map(
            (internalRating) => {
              "customerRiskRatingId": internalRating.customerRiskRatingId,
              "ratingType": 195,
              "rimNo": internalRating.customerRimNo,
              "customerName": internalRating.customerName,
              "entityId": internalRating.entityId,
              "borrowerGuarantor": internalRating.borrowerGuarantor,
              "crr": internalRating.crr,
              "prevRatingSource": internalRating.prevRatingSrc,
              "existingBasisOfCrr": internalRating.existingBasisOfCrr,
              "prevCrr": internalRating.crr,
              //proposed model opt
              "proposedModel": internalRating.proposedModel,
              //prop crr
              "proposedCrr": internalRating.proposedCRR,
              //basis of proposed CRR
              "proposedBasisOfCrr": internalRating.proposedBasisOfCrr,
              if (internalRating.isOverrideCRR == false &&
                  internalRating.isCascade == false)
                "proposedRatingSource": 197,
              if (internalRating.isOverrideCRR ?? false)
                "proposedRatingSource": 3186,
              if (internalRating.isCascade ?? false)
                "proposedRatingSource": 14953,
              //Details of Override
              "detailsOverride": internalRating.detailsOverride,
              if (internalRating.isOverrideCRR ?? false)
                "overrideComment": internalRating.overrideComment,
              if (internalRating.isCascade ?? false)
                "cascadeNote": internalRating.cascadeNote,
              "proposedByCredit":
                  int.tryParse(internalRating.proposedByCredit ?? ""),
              "isOverrideCRR": internalRating.internalRatingType ==
                  InternalRatingtype.override,
              "isCascade": internalRating.internalRatingType ==
                  InternalRatingtype.cascade,
              "isManualEntry": isClDown,
              "sourceLongName": internalRating.sourceLongName ?? "",
              "isDeleted": internalRating.isDeleted ?? false,
              if (isFiFlow) "secondBestRating": internalRating.secondBestRating,
            },
          )
          .toList(),
      "externalRatingList": externalRatings
          .map(
            (externalRating) => {
              "customerName": externalRating.customerName,
              "rimNo": externalRating.customerRimNo,
              "isDeleted": externalRating.isDeleted ?? false,
              "isDeletable": false,
              "ratingList": [
                {"ratingType": 196, "rating": externalRating.sAndP?.id},
                {"ratingType": 286, "rating": externalRating.moodys?.id},
                {"ratingType": 287, "rating": externalRating.fitch?.id},
              ],
            },
          )
          .toList(),
    };
  }
}
