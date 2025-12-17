import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/models/request/risk_rating/risk_rating.dart';
import 'package:wcas_frontend/models/request/risk_rating/updated_rating.dart';

class RiskRatingRepository {
  static final _singleton = RiskRatingRepository();
  static RiskRatingRepository get instance => _singleton;

  final APIManager _apiManager;

  RiskRatingRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<RiskRating> getRatingDetails() async {
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request?.applicationRefNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getRatingDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return (RiskRating.fromJson(response.body["responseData"]));
    } else {
      throw response.message;
    }
  }

  Future<List<UpdatedRating?>> getUpdatedRatingDetails(
      {int? rimNo, int? entityId}) async {
    Map data = BaseRequest.baseRequest({"rimNo": rimNo, "entityId": entityId});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getUpdatedRating, data);

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      List<UpdatedRating> updatedRating = [];
      for (dynamic data in response.body["responseData"]) {
        if (data != null) {
          updatedRating.add(UpdatedRating.fromJson(data));
        }
      }
      return updatedRating;
    } else {
      String errMsg =
          response.body["baseResponse"]["status"]['errorDescription'] ?? '';
      if (errMsg.contains("Server Unavailable")) {
        return [UpdatedRating(isClDown: true)];
      }
      return [];
    }
  }

  Future<List<UpdatedRating?>> getRatingDetailsByEntity(
      {required String rimNo}) async {
    Map data = BaseRequest.baseRequest({"rimNo": rimNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getUpdatedRating, data);

    if (response.status == ResponseStatus.success) {
      List<UpdatedRating> updatedRating = [];
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];

      for (dynamic data in response.body["responseData"]) {
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
    Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "mode": "SAVE",
      "customerRating": customerRating,
    });

    AppResponse response =
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
