import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";

/// Repository responsible for handling group information-related operations.
/// 
/// Provides methods to interact with APIs for fetching and managing group data,
/// and maintains a singleton instance for shared usage across the application.
class GroupInformationRepository {
  GroupInformationRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [GroupInformationRepository].
  static final _singleton = GroupInformationRepository();

  /// Returns the singleton instance of [GroupInformationRepository].
  static GroupInformationRepository get instance => _singleton;

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Retrieves group information including facilities with CBD for the current application.
  /// 
  /// Sends the application reference number to the backend and maps the response
  /// into a list of [FacilitiesWithCbd] objects.
  /// Returns the list of group information on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves facility details associated with other banks for the current application.
  /// 
  /// Sends the application reference number to the backend and maps the response
  /// into a list of [Facility] objects.
  /// Returns the list of facilities on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves central risk bureau details related to facilities for the current application.
  /// 
  /// Sends the application reference number to the backend and parses the response
  /// into a [RiskBureau] object.
  /// Returns the risk bureau details on success.
  /// Throws [ApiException] if the API call fails.
  Future<RiskBureau> getFacilitiesCentralRiskBureau() async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo, //"201903FSPFS000121" //
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getShareofWalletDetails, data);
    if (response.status == ResponseStatus.success) {
      return RiskBureau.fromJson(response.body["responseData"]);
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves Central Bank Risk Bureau (CBRB) data for the current application.
  /// 
  /// Extracts required fields from the provided facilities list, formats values,
  /// and submits the data to the backend.
  /// Returns the status description message on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String?> saveCBRBData(
    List<Map<String, dynamic>> facilitiesListJson,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "cbrbDataId": facilitiesListJson.first["cbrbDataId"],
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
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
     //throw Exception(response.message);
     throw ApiException(response.message);
    }
  }

  /// Saves facility details associated with other banks for the current application.
  /// 
  /// Accepts a [Facility] object, converts it into the required format, and
  /// submits it to the backend.
  /// Returns the status description message on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String?> saveOtherBankData(Facility facilitiesListJson) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "facilitiesList": [facilitiesListJson.toJson()],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Deletes a facility associated with other banks for the current application.
  /// 
  /// Sends the facility identifier to the backend to perform deletion.
  /// Returns the status description message on successful deletion.
  /// Throws [ApiException] if the API call fails.
  Future<String?> deleteOtherBankFacility(Facility? dataFacility) async {
    final Map data = BaseRequest.baseRequest({
      // "appRefNo": Globals.request?.applicationRefNo,
      "facilityOtherBankId": dataFacility?.facilityOtherbanksId,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Deletes Central Bank Risk Bureau (CBRB) data for the current application.
  /// 
  /// Sends the application reference number, RIM number, and CBRB data ID
  /// to the backend to perform deletion.
  /// Returns the status description message on successful deletion.
  /// Throws [ApiException] if the API call fails.
  Future<String?> deleteCBRBData(CBRB? dataCBRB) async {
    final Map data = BaseRequest.baseRequest({
      // "appRefNo": Globals.request?.applicationRefNo,
      // "rimNo": dataCBRB?.rimNo,
      "cbrbDataId": dataCBRB?.cbrbDataId,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deletCBRBInformation, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }
}
