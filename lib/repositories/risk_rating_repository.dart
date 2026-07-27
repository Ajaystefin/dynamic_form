import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";

/// Repository responsible for handling all Risk Rating related API operations.
///
/// This class communicates with backend services via [APIManager]
/// and provides methods to fetch and save risk rating data.
class RiskRatingRepository {
  /// Creates an instance of [RiskRatingRepository].
  ///
  /// Optionally accepts a custom [APIManager] for dependency injection.
  RiskRatingRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static final RiskRatingRepository _singleton = RiskRatingRepository();

  /// Singleton instance of [RiskRatingRepository].
  static RiskRatingRepository get instance => _singleton;

  final APIManager _apiManager;

  /// Fetches the base risk rating details for the current application.
  ///
  /// Returns a [RiskRating] object on success.
  /// Throws [ApiException] if the API call fails.
  Future<RiskRating> getRatingDetails() async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getRatingDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return RiskRating.fromJson(response.body["responseData"]);
    } else {
      throw ApiException(response.message);
    }
  }

  /// Fetches updated rating details using [rimNo] and/or [entityId].
  ///
  /// Returns a list of [UpdatedRating].
  /// If service is unavailable (error code 503), returns a special
  /// [UpdatedRating] with `isClDown = true`.
  Future<List<UpdatedRating?>> getUpdatedRatingDetails({
    int? rimNo,
    int? entityId,
  }) async {
    final Map data =
        BaseRequest.baseRequest({"rimNo": rimNo, "entityId": entityId});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getUpdatedRating, data);

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];

      final List<UpdatedRating> updatedRating = [];
      for (final dynamic data in response.body["responseData"]) {
        if (data != null) {
          updatedRating.add(UpdatedRating.fromJson(data));
        }
      }
      return updatedRating;
    } else {
      final int? errorCode = int.tryParse(
        response.body["baseResponse"]["status"]["errorCode"] ?? "",
      );
      if (errorCode == 503) {
        return [UpdatedRating(isClDown: true)];
      }
      return [];
    }
  }

  /// Fetches rating details for a specific entity using [rimNo].
  ///
  /// Returns a list of [UpdatedRating] on success.
  /// Throws [ApiException] if the API call fails.
  Future<List<UpdatedRating?>> getRatingDetailsByEntity({
    required String rimNo,
  }) async {
    final Map data = BaseRequest.baseRequest({"rimNo": rimNo});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getUpdatedRating, data);

    if (response.status == ResponseStatus.success) {
      final List<UpdatedRating> updatedRating = [];
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];

      for (final dynamic data in response.body["responseData"]) {
        if (data != null) {
          updatedRating.add(UpdatedRating.fromJson(data));
        }
      }

      return updatedRating;
    } else {
      throw ApiException(response.message);
    }
  }

  /// Saves customer rating details to the backend.
  ///
  /// Accepts [customerRating] as input.
  /// Returns success message string on success.
  /// Throws [ApiException] if the API call fails.
  Future<String> saveRatings({
    required Map<String, dynamic> customerRating,
  }) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "mode": "SAVE",
      "customerRating": customerRating,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveRatingDetailsUpdated, data);

    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      throw ApiException(response.message);
    }
  }
}
