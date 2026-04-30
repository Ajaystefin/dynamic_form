import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";

class RiskRatingRepository {
  RiskRatingRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = RiskRatingRepository();
  static RiskRatingRepository get instance => _singleton;

  final APIManager _apiManager;

  Future<RiskRating> getRatingDetails() async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getRatingDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return (RiskRating.fromJson(response.body["responseData"]));
    } else {
      throw response.message;
    }
  }

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
      throw response.message;
    }
  }

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
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }
}
