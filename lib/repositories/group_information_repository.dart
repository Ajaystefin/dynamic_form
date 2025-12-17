import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_other_banks.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart';
import 'package:wcas_frontend/models/request/group_information/risk_bureau.dart';

class GroupInformationRepository {
  static final _singleton = GroupInformationRepository();
  static GroupInformationRepository get instance => _singleton;

  final APIManager _apiManager;

  GroupInformationRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  // Facilities With CBD
  Future<List<FacilitiesWithCbd>> getGroupInformation() async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getGroupInformation, data);
    if (response.status == ResponseStatus.success) {
      List<dynamic> data = response.body['responseData'];
      return data.map((value) => FacilitiesWithCbd.fromJson(value)).toList();
    } else {
      throw response.message;
    }
  }

  // Facilities With Other Bank
  Future<FacilitiesOtherBanks> getFacilitiesOtherBanks() async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 21,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      return FacilitiesOtherBanks.fromJson(response.body['responseData']);
    } else {
      throw response.message;
    }
  }

  Future<RiskBureau> getFacilitiesCentralRiskBureau() async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 21,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getShareofWalletDetails, data);
    if (response.status == ResponseStatus.success) {
      return RiskBureau.fromJson(response.body['responseData']);
    } else {
      throw response.message;
    }
  }

  Future<String?> saveFacilitiesWithOtherBank(
      List<Map<String, dynamic>> facilitiesListJson) async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 21,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "facilitiesList": facilitiesListJson,
        "appRefNo": ServerConstants.appRefNo
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      response.message = response.body["responseData"]["message"];
      return response.message;
    } else {
      throw response.message;
    }
  }
}
