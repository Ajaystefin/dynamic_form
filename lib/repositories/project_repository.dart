import "dart:convert";
import "dart:typed_data";

import "package:easy_localization/easy_localization.dart";
import "package:file_saver/file_saver.dart";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";
import "package:wcas_frontend/models/request/project/project.dart";

class ProjectRepository {
  ProjectRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = ProjectRepository();
  static ProjectRepository get instance => _singleton;

  final APIManager _apiManager;

  Future<({List<Project> projects})> getSearchProjectDetails({
    Map<String, dynamic>? payload,
    bool? isProject = false,
  }) async {
    try {
      final Map data = BaseRequest.baseRequest({...?payload});

      final endpoint = (isProject ?? false)
          ? APIEndpoints.getSearchProjectDetails
          : APIEndpoints.getSearchProjectDetailsContract;

      final AppResponse response =
          await _apiManager.post(endpoint, data, plainResponse: true);

      if (response.status == ResponseStatus.success) {
        // FIX: Wrap large numbers in quotes BEFORE jsonDecode
        final String modifiedJson = response.body.replaceAllMapped(
          RegExp(
            r'("projectValueCurrent"|"projectValue"|"initialProjectValue")\s*:\s*([\d.]+)',
          ),
          (match) => '${match.group(1)}:"${match.group(2)}"',
        );
        final List<dynamic> responseData =
            jsonDecode(modifiedJson)["responseData"] ?? [];
        final projects = responseData
            .map((e) => Project.fromSearchJson(e as Map<String, dynamic>))
            .toList();
        return (projects: projects);
      } else {
        throw jsonDecode(response.body)["baseResponse"]["status"]
                ["statusDescription"]
            .toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> saveProjectDetails({
    bool? isCreateProject,
    Project? project,
  }) async {
    final Map data = BaseRequest.baseRequest({
      ...?project?.toSaveEditProjectJson(
        isCreateProject: (isCreateProject ?? false),
      ),
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveProjectDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message = "project.createNewProject.projectSaved".tr();
      if (response.body["responseData"] != null &&
          response.body["responseData"]["projectCode"] != null) {
        return response.body["responseData"]["projectCode"];
      } else {
        return response.message;
      }
    } else {
      response.message = "common.error".tr();
      throw response.body?["baseResponse"]?["status"]?["errorDescription"] ??
          response.message;
    }
  }

  Future<String?> saveLinkContractDetails(Contract contract) async {
    final Map data = BaseRequest.baseRequest({...contract.toSaveLinkJson()});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message = response.body?["baseResponse"]?["status"]
              ?["statusDescription"] ?? //contractCode
          "common.saveSuccess".tr();
      return response.body["responseData"]["contractCode"];
    } else {
      throw response.message;
    }
  }

  Future<List<Contract>> getProjectContractDetails(Project? project) async {
    final data = BaseRequest.baseRequest({"projectId": project?.projectId});
    final AppResponse response = await _apiManager
        .post(APIEndpoints.getContractDetails, data, plainResponse: true);

    if (response.status == ResponseStatus.success) {
      // FIX: Wrap large numbers in quotes BEFORE jsonDecode
      final String modifiedJson = response.body.replaceAllMapped(
        RegExp(r'("contractValue")\s*:\s*([\d.]+)'),
        (match) => '${match.group(1)}:"${match.group(2)}"',
      );
      final List<Contract> contract = [];
      // final List<dynamic> responseData =
      //     jsonDecode(modifiedJson)['responseData'] ?? [];

      for (final dynamic data in jsonDecode(modifiedJson)["responseData"]) {
        contract.add(Contract.fromProjectContractJson(data));
      }
      return contract;
    } else {
      throw response.message;
    }
  }

  Future<List<Customer>> getProjectBorrowerSearch({
    String? customerRimNo,
    String? customerName,
  }) async {
    final data = BaseRequest.baseRequest({
      "customerRimNo":
          customerRimNo == null || customerRimNo == "" ? null : customerRimNo,
      "preferredName":
          customerName == null || customerName == "" ? null : customerName,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getProjectBorrower, data);
    if (response.status == ResponseStatus.success) {
      final List<Customer> customer = [];
      for (final dynamic data in response.body["responseData"] as List) {
        customer.add(Customer.fromJson(data));
      }
      return customer;
    } else {
      throw response.message;
    }
  }

  Future<Contract> getContractByContractCodeDetails({
    String? contractCode,
  }) async {
    final data = BaseRequest.baseRequest({
      "contractCode": contractCode,
      // "contractorId":
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getContractByContractCodeDetails,
      data,
      plainResponse: true,
    );
    if (response.status == ResponseStatus.success) {
      // FIX: Wrap large numbers in quotes BEFORE jsonDecode
      final String modifiedJson = response.body.replaceAllMapped(
        RegExp(
          r'("contractValue"|"contractValueAedAmount"|"initialContractValue")\s*:\s*([\d.]+)',
        ),
        (match) => '${match.group(1)}:"${match.group(2)}"',
      );

      // final List<dynamic> responseData =
      //     jsonDecode(modifiedJson)['responseData'] ?? [];
      final dynamic data = jsonDecode(modifiedJson)["responseData"];
      final Contract contract = Contract.fromContractByContractCodeJson(data);
      return contract;
    } else {
      throw response.message;
    }
  }

  Future<List<LinkCommitmentNumber>> getLinkedCMNForRimDetails({
    String? contractRimNo,
  }) async {
    final data = BaseRequest.baseRequest({"rimNo": contractRimNo});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getLinkedCMNForRimDetails, data);
    if (response.status == ResponseStatus.success) {
      final List<LinkCommitmentNumber> contract = [];
      for (final dynamic data in response.body["responseData"] as List) {
        contract.add(LinkCommitmentNumber.fromJson(data));
      }
      return contract;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveContractDetail(Contract contract) async {
    final Map data =
        BaseRequest.baseRequest({...contract.toSaveContractJson()});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);

    if (response.status == ResponseStatus.success) {
      response.message = response.body?["baseResponse"]?["status"]
              ?["statusDescription"] ??
          "common.saveSuccess".tr();
//"responseData": {contractCode: 202601CONT000019}
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<Project> getProjectDetails() async {
    final Map<String, dynamic> data = {
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
        "appRefNo": Globals.request?.applicationRefNo,
      },
    };
    final AppResponse response = await _apiManager.get(
      APIEndpoints.getProjectDetails,
      queryParams: data,
    );
    if (response.status == ResponseStatus.success) {
      final responseData =
          response.body["responseData"] as Map<String, dynamic>;
      return Project.fromJson(responseData);
    } else {
      throw response.message;
    }
  }

  Future<Contract> getContractDetails() async {
    final Map<String, dynamic> data = {
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
        "appRefNo": Globals.request?.applicationRefNo,
      },
    };
    final AppResponse response = await _apiManager
        .get(APIEndpoints.getContractDetails, queryParams: data);
    if (response.status == ResponseStatus.success) {
      return Contract.fromJson(response.body["responseData"]);
    } else {
      throw response.message;
    }
  }

  Future<List<LinkCommitmentNumber>> getLinkContract() async {
    final Map<String, dynamic> data = {
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
        "appRefNo": Globals.request?.applicationRefNo,
      },
    };
    final AppResponse response =
        await _apiManager.get(APIEndpoints.getLinkContract, queryParams: data);
    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      final List<LinkCommitmentNumber> linkContracts = [];
      response.message = response.body["status"]["statusDescription"];
      for (final dynamic data in response.body["responseData"] as List) {
        linkContracts.add(LinkCommitmentNumber.fromJson(data));
      }
      return linkContracts;
    } else {
      throw response.message;
    }
  }

  Future<List<PPC>> getPPC() async {
    final Map<String, dynamic> data = {
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
        "appRefNo": Globals.request?.applicationRefNo,
      },
    };
    final AppResponse response =
        await _apiManager.get(APIEndpoints.getPerPartyLimit, queryParams: data);
    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      final List<PPC> ppcs = [];
      response.message = response.body["status"]["statusDescription"];
      for (final dynamic data in response.body["responseData"] as List) {
        ppcs.add(PPC.fromJson(data));
      }
      return ppcs;
    } else {
      throw response.message;
    }
  }

  Future<Contract> saveContractDetails(Map<String, dynamic> data) async {
    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);
    if (response.status == ResponseStatus.success) {
      return Contract.fromJson(response.body["responseData"]);
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getcountryCode() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCurrencyCode, data);

    if (response.status != ResponseStatus.success) {
      throw response.message;
    }

    final dynamic currencyList = response.body["responseData"];

    if (currencyList is! List) {
      return <Reference>[];
    }

    // Map isoCode -> name, description -> reference4
    return currencyList
        .whereType<Map<String, dynamic>>() // keep only proper map entries
        .map((e) {
          final iso = e["isoCode"];
          final desc = e["description"];

          if (iso is String && iso.trim().isNotEmpty) {
            return Reference(
              name: iso.trim(),
              reference4: (desc is String) ? desc.trim() : null,
            );
          }
          return null;
        })
        .whereType<Reference>()
        .toList();
  }

  Future<void> generateProjectExposureSummary(
    String? docType,
    String? projCode,
  ) async {
    try {
      final data = BaseRequest.baseRequest(
        {"projectCode": projCode, "docType": docType},
      );
      final AppResponse response = await _apiManager.post(
        APIEndpoints.generateProjectExposureSummary,
        data,
      );

      if (response.status == ResponseStatus.success) {
        final base64 = response.body!["responseData"]["response"];
        final Uint8List bytes = base64Decode(base64);
        docType = response.body!["responseData"]["type"];

        final safeName =
            (projCode ?? "Form").replaceAll(RegExp(r"[^\w\-]+"), "_");
        final filename = "${projCode}_$safeName.$docType";
        // if (!isDownload) {
        //   FileDownloadService.instance.openFileInNewTab(bytes, filename);
        // } else {
        await FileSaver.instance.saveFile(
          name: filename,
          bytes: bytes,
        );
        // }
      } else {
        throw ("[$projCode] ${response.message}");
      }
    } catch (e) {
      throw ("[$projCode] ${e.toString()}");
    }
  }
}
