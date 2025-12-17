import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';
import 'package:wcas_frontend/models/request/project/link_contract.dart';
import 'package:wcas_frontend/models/request/project/ppc.dart';
import 'package:wcas_frontend/models/request/project/project.dart';

class ProjectRepository {
  static final _singleton = ProjectRepository();
  static ProjectRepository get instance => _singleton;

  final APIManager _apiManager;

  ProjectRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<String?> saveProjectDetails(
      {bool? isCreateProject, Project? project}) async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "new": isCreateProject,
        "code": project?.code,
        "name": project?.name,
        "ultimateOwner": project?.ultimateOwner,
        "ownerEntity": project?.ownerEntity,
        "ownerRim": project?.ownerRim,
        "ownerEntityRim": project?.ownerEntityRim,
        "initalValue": project?.initalProjectValue,
        "projectValue": project?.currentProjectValue,
        "period": project?.period,
        "completion": project?.completion,
        "liabilityEndDate": project?.liabilityEndDate,
        "summary": project?.summary
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveProjectDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message = response.body?["status"]?["statusDescription"] ??
          "project.createNewProject.projectSaved".tr();

      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<Project> getProjectDetails() async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": Globals.request?.customerRimNo,
        "groupId": Globals.request?.groupId,
        "appRefNo": Globals.request?.applicationRefNo
      }
    };
    AppResponse response = await _apiManager.get(APIEndpoints.getProjectDetails,
        queryParams: data);
    if (response.status == ResponseStatus.success) {
      final responseData =
          response.body['responseData'] as Map<String, dynamic>;
      return Project.fromJson(responseData);
    } else {
      throw response.message;
    }
  }

  Future<Contract> getContractDetails() async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": Globals.request?.customerRimNo,
        "groupId": Globals.request?.groupId,
        "appRefNo": Globals.request?.applicationRefNo
      }
    };
    AppResponse response = await _apiManager
        .get(APIEndpoints.getContractDetails, queryParams: data);
    if (response.status == ResponseStatus.success) {
      return Contract.fromJson(response.body['responseData']);
    } else {
      throw response.message;
    }
  }

  Future<List<LinkContract>> getLinkContract() async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": Globals.request?.customerRimNo,
        "groupId": Globals.request?.groupId,
        "appRefNo": Globals.request?.applicationRefNo
      }
    };
    AppResponse response =
        await _apiManager.get(APIEndpoints.getLinkContract, queryParams: data);
    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      List<LinkContract> linkContracts = [];
      response.message = response.body["status"]["statusDescription"];
      for (dynamic data in response.body["responseData"] as List) {
        linkContracts.add(LinkContract.fromJson(data));
      }
      return linkContracts;
    } else {
      throw response.message;
    }
  }

  Future<List<PPC>> getPPC() async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": Globals.request?.customerRimNo,
        "groupId": Globals.request?.groupId,
        "appRefNo": Globals.request?.applicationRefNo
      }
    };
    AppResponse response =
        await _apiManager.get(APIEndpoints.getPerPartyLimit, queryParams: data);
    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      List<PPC> ppcs = [];
      response.message = response.body["status"]["statusDescription"];
      for (dynamic data in response.body["responseData"] as List) {
        ppcs.add(PPC.fromJson(data));
      }
      return ppcs;
    } else {
      throw response.message;
    }
  }

  Future<Contract> saveContractDetails(Map<String, dynamic> data) async {
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);
    if (response.status == ResponseStatus.success) {
      return Contract.fromJson(response.body['responseData']);
    } else {
      throw response.message;
    }
  }

  Future<String?> saveLinkContractDetails(Contract contract) async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "borrowerRole": contract.borrowerRole,
        "customerName": contract.customerName,
        "rimNo": contract.customerRimNo,
        "paymasterName": contract.paymasterName,
        "contractorValue": contract.contractorValue,
        "projectTenor": contract.projectTenor,
        "expectedStartDate": contract.expectedStartDate,
        "expectedCompletionDate": contract.expectedCompletionDate,
        "contractorScope": contract.contractorScope,
      }
    };

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);

    if (response.status != ResponseStatus.success) {
      throw response.message;
    }
    final status = (response.body as Map)["status"] as Map;
    return status["statusDescription"] as String;
  }

  Future<({List<Project> projects, List<Contract> contracts})>
      getSearchProjectDetails() async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": Globals.request?.customerRimNo,
        "groupId": Globals.request?.groupId,
        "appRefNo": Globals.request?.applicationRefNo
      }
    };
    AppResponse response = await _apiManager
        .get(APIEndpoints.getSearchProjectDetails, queryParams: data);

    if (response.status == ResponseStatus.success) {
      final responseData = response.body['responseData'];

      final projects = (responseData['projects'] as List)
          .map((e) => Project.fromJson(e))
          .toList();

      final contracts = (responseData['contracts'] as List)
          .map((e) => Contract.fromJson(e))
          .toList();

      return (projects: projects, contracts: contracts);
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getcountryCode() async {
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
        "RatesInqRq": {
          "RqUID": "41cc4be8-d848-4f58-8d42-6ff482009113",
          "MsgRqHdr": {
            "SvcIdent": {
              "SvcProviderName": "WCAS",
              "SvcProviderId": "71",
              "SvcName": "RatesInq"
            }
          },
          "RatesSel": {"RateSel": "ExchangeRates"}
        }
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getCountryCode, data);
    if (response.status == ResponseStatus.success) {
      final forexList = response.body["RatesInqRs"]?["ForExQuoteRec"];

      if (forexList is List) {
        return forexList
            .map((element) {
              var code = element["BaseCurCode"]?["CurCodeValue"];
              var codeDesc = element["BaseCurCode"]?["CurCodeDesc"];
              if (code is String && codeDesc is String) {
                return Reference(name: code, reference4: codeDesc);
              }
              return null;
            })
            .whereType<Reference>()
            .toList();
      }

      return forexList;
    } else {
      throw response.message;
    }
  }
}
