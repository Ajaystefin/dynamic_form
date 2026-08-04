import "dart:convert";
import "dart:typed_data";
import "package:easy_localization/easy_localization.dart";
import "package:file_saver/file_saver.dart";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";
import "package:wcas_frontend/models/request/project/project.dart";

/// Repository responsible for project-related operations.
class ProjectRepository {
  /// Creates a [ProjectRepository].
  ///
  /// Uses a default [APIManager] if none is provided.
  ProjectRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static final _singleton = ProjectRepository();

  /// Returns the singleton instance of [ProjectRepository].
  static ProjectRepository get instance => _singleton;

  final APIManager _apiManager;

  /// Retrieves project search details from the backend.
  ///
  /// Sends the provided [payload] to the appropriate search endpoint and
  /// returns a list of matching [Project] objects.
  ///
  /// When [isProject] is `true`, the project search endpoint is used.
  /// Otherwise, the contract search endpoint is used.
  ///
  /// Returns:
  /// - `projects`: List of matching projects.
  ///
  /// Throws an [ApiException] when the API request fails or the response
  /// cannot be processed.
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
        throw ApiException(
          jsonDecode(response.body)["baseResponse"]["status"]
                  ["statusDescription"]
              .toString(),
        );
      }
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Saves project details to the backend.
  ///
  /// Creates or updates a project based on the value of [isCreateProject]
  /// and returns the project code on success.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<String?> saveProjectDetails({
    bool? isCreateProject,
    Project? project,
  }) async {
    final Map data = BaseRequest.baseRequest({
      ...?project?.toSaveEditProjectJson(
        isCreateProject: isCreateProject ?? false,
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
      final errorMessage = response.body?["baseResponse"]?["status"]
              ?["errorDescription"] ??
          response.message;
      throw ApiException(errorMessage);
    }
  }

  /// Saves linked contract details to the backend.
  ///
  /// Sends the provided [contract] information and returns the generated
  /// contract code upon successful completion.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves contract details associated with the specified [project].
  ///
  /// Returns a list of [Contract] objects linked to the given project.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Searches and retrieves project borrower details based on the provided
  /// customer RIM number or customer name.
  ///
  /// Returns a list of matching [Customer] records.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves contract details for the specified [contractCode].
  ///
  /// Returns the corresponding [Contract] information when the contract
  /// is found.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves linked commitment numbers for the specified contract RIM number.
  ///
  /// Returns a list of [LinkCommitmentNumber] records associated with the
  /// provided [contractRimNo].
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves contract details to the backend.
  ///
  /// Sends the provided [contract] information and returns the success
  /// message from the response.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<String?> saveContractDetail(Contract contract) async {
    final Map data =
        BaseRequest.baseRequest({...contract.toSaveContractJson()});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);

    if (response.status == ResponseStatus.success) {
      return response.body?["baseResponse"]?["status"]?["statusDescription"] ??
          "common.saveSuccess".tr();
    } else {
      throw ApiException(response.message);
    }
  }

  /// Retrieves project details for the current application context.
  ///
  /// Returns the associated [Project] information based on the current
  /// request and user context.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves contract details for the current application context.
  ///
  /// Returns the associated [Contract] information based on the current
  /// request and user context.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves linked contract details for the current application context.
  ///
  /// Returns a list of [LinkCommitmentNumber] records associated with the
  /// current request and customer information.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves Per Party Limits (PPC) for the current application.
  ///
  /// Sends a request to the backend using the current user's role,
  /// application reference number, RIM number, and group ID.
  ///
  /// Returns a list of [PPC] objects when the request is successful.
  ///
  /// Throws an [ApiException] if the API call fails or the service
  /// returns a non-success status
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves contract details to the backend service.
  ///
  /// Sends the provided contract data to the save contract details API
  /// and returns the saved [Contract] object on success.
  ///
  /// Throws an [ApiException] if the API request fails or the service
  /// returns an error response.
  ///
  /// Parameters:
  /// - Contract information to be persisted.
  Future<Contract> saveContractDetails(Map<String, dynamic> data) async {
    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveContractDetails, data);
    if (response.status == ResponseStatus.success) {
      return Contract.fromJson(response.body["responseData"]);
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Generates and downloads the Project Exposure Summary report.
  ///
  /// Sends the specified project code and document type to the backend
  /// service, decodes the returned Base64 content, and saves the report
  /// file locally.
  ///
  /// Parameters:
  /// - The document format requested (for example, pdf or xlsx).
  /// - The project code for which the exposure summary is generated.
  ///
  /// Throws an [ApiException] if report generation or file download fail
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
            "Project Exposure Report".replaceAll(RegExp(r"[^\w\-]+"), "_");
        final filename = "${projCode}_$safeName.$docType";
        await FileSaver.instance.saveFile(
          name: filename,
          bytes: bytes,
        );
        // }
      } else {
        throw ApiException("[$projCode] ${response.message}");
      }
    } on Object catch (e) {
      throw ApiException("[$projCode] $e");
    }
  }

  /// Saves a comment for the current contract/request.
  ///
  /// Sends the provided [Comment] to the backend service and returns
  /// the success message received from the API.
  ///
  /// Throws an [ApiException] if the comment cannot be saved.
  Future<String> saveComment(Comment comment) async {
    final Map data = BaseRequest.baseRequest({
      "commentList": [comment.toSaveContractJson()],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveComments, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves comments associated with the specified contract/reference.
  ///
  /// Returns a list of [Comment] objects for the given comment [type]
  /// and application reference number.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<Comment>> getComments(
    CommentsType type,
    EntityIdentifier? entityIdentifier,
    String? appRefNo,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "contractCode": appRefNo,
      "commentCategoryId": ServerConstants.commentTypeId[type],
      //"entityIdentifier": ServerConstants.entityId[entityIdentifier],
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getComments, data);
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final List<dynamic> raw =
        response.body["responseData"]["commentList"] as List;
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }
}
