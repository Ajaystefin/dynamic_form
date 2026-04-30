import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";

class GroupInformationRepository {
  GroupInformationRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = GroupInformationRepository();
  static GroupInformationRepository get instance => _singleton;

  final APIManager _apiManager;

  // Facilities With CBD
  Future<List<FacilitiesWithCbd>> getGroupInformation() async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo, // "202007APNAR004538" //
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getGroupInformation, data);
    if (response.status == ResponseStatus.success) {
      final List<dynamic> data = response.body["responseData"];
      return data.map((value) => FacilitiesWithCbd.fromJson(value)).toList();
    } else {
      throw response.message;
    }
  }

  // Facilities With Other Bank
  Future<List<Facility>> getFacilitiesOtherBanks() async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      final List<dynamic> respData = response.body["responseData"];
      return respData.map((value) => Facility.fromJson(value)).toList();
    } else {
      throw response.message;
    }
  }

  Future<RiskBureau> getFacilitiesCentralRiskBureau() async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo, //"201903FSPFS000121" //
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getShareofWalletDetails, data);
    if (response.status == ResponseStatus.success) {
      return RiskBureau.fromJson(response.body["responseData"]);
    } else {
      throw response.message;
    }
  }

  Future<String?> saveCBRBData(
    List<Map<String, dynamic>> facilitiesListJson,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "customerName": facilitiesListJson.first["customerName"],
      "rimNo": facilitiesListJson.first["rimNo"],
      "direct_limits": facilitiesListJson.first["directLimit"] != "null"
          ? facilitiesListJson.first["directLimit"]?.toString()
          : "",
      "indirect_limits": facilitiesListJson.first["indirectLimit"] != "null"
          ? facilitiesListJson.first["indirectLimit"]?.toString()
          : "",
      "direct_os": facilitiesListJson.first["directOutstanding"] != "null"
          ? facilitiesListJson.first["directOutstanding"]?.toString()
          : "",
      "indirect_os": facilitiesListJson.first["indirectOutstanding"] != "null"
          ? facilitiesListJson.first["indirectOutstanding"]?.toString()
          : "",
      "no_of_bank": facilitiesListJson.first["noOfBanks"] != "null"
          ? facilitiesListJson.first["noOfBanks"]?.toString()
          : "",
      "cbrb_classifications": facilitiesListJson.first["cbrbClassifications"],
      "comments": facilitiesListJson.first["cbrbClassifications"],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveCBRBData, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveOtherBankData(Facility facilitiesListJson) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "facilitiesList": [facilitiesListJson.toJson()],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteOtherBankFacility(Facility? dataFacility) async {
    final Map data = BaseRequest.baseRequest({
      // "appRefNo": Globals.request?.applicationRefNo,
      "facilityOtherBankId": dataFacility?.facilityOtherbanksId,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteCBRBData(CBRB? dataCBRB) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": dataCBRB?.rimNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deletCBRBInformation, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }
}
