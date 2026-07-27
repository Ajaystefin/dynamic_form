import "dart:convert";
import "dart:typed_data";
import "package:file_saver/file_saver.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/user_by_filtered_roles_service.dart";
import "package:wcas_frontend/core/services/user_by_roles_service.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/approval/clean_exposure.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";
import "package:wcas_frontend/models/request/approval/guarantors_exposure.dart";
import "package:wcas_frontend/models/request/approval/limit_detail.dart";
import "package:wcas_frontend/models/request/approval/output_form.dart";
import "package:wcas_frontend/models/request/approval/proposed_facilities.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Repository responsible for handling approval-related operations.
///
/// Provides access to APIs and reference data required for approval workflows.
class ApprovalRepository {
  /// Creates an instance of [ApprovalRepository].
  ///
  /// Optionally accepts custom implementations of [APIManager]
  /// and [ReferenceDataService] for dependency injection.
  ApprovalRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();

  /// Singleton instance of [ApprovalRepository].
  static ApprovalRepository _singleton = ApprovalRepository();

  /// Provides access to the singleton instance.
  static ApprovalRepository get instance => _singleton;

  /// Allows overriding the singleton instance (useful for testing).
  // ignore: avoid_setters_without_getters
  static set overrideInstance(ApprovalRepository newInstance) {
    _singleton = newInstance;
  }

  /// Provides access to reference data services.
  final ReferenceDataService _referenceDataService;

  /// Handles API communication for approval-related operations.
  final APIManager _apiManager;

  /// Cached list of customer position groups.
  late List<CustomerPosition> groups = [];

  /// Holds all reference types used within approval workflows.
  List<ReferenceType> allReferences = [];

  /// Fetches group position details for the current application.
  ///
  /// Sends a request using the application reference number to retrieve
  /// proposed and present facility positions from the backend.
  ///
  /// Returns the raw [AppResponse] for flexible handling or further
  /// transformation by the caller.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<AppResponse> getGroupPositionDetails() async {
    // final Map<String, dynamic> data = {
    //   // "roleID": Globals.user?.currentRole?.id,
    //   // "role": Globals.user?.currentRole?.code,
    //   // "channelID": EnvConfig.channelID,
    //   // "sessionID": const Uuid().v4(),
    //   // "userID": Globals.user?.id,
    //   // "userName": Globals.user?.name,
    //   // // "pageId": 3,
    //   // "rqUID": const Uuid().v4(),
    //   // // "mode": null,
    //   "baseRequest": {
    //     "roleID": 126,
    //     "role": "RMB",
    //     "bpmRole": "Business Regional Manager-WCAS",
    //     "channelID": "WCAS",
    //     "sessionID": "e5341f6a-1e8b-4beb-9745-8067295d780d",
    //     "userID": "WCASTSP01",
    //     "userName": "wcastsp01",
    //     "rqUID": "0bec213e-9926-415d-8733-c789f991f421",
    //   },
    //   "requestData": {
    //     "appRefNo": "202511FULLAR000421" //Globals.request?.applicationRefNo,
    //   }
    // };
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getGroupPositionDetails, data);
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    return response;
  }

  /// Fetches available output forms for the current application.
  ///
  /// Retrieves reference data for output forms and combines it with the
  /// backend response to construct a list of [OutputForm] objects.
  ///
  /// Maps form identifiers returned by the API to their corresponding
  /// reference definitions to build complete form metadata.
  ///
  /// Returns a list of [OutputForm] objects available for the application.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<OutputForm>> getOutputForms() async {
    final List<OutputForm> outputForms = [];

    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.caOutputForms,
    ]);
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getOutputForms, data);
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final List<Reference> outputFormRef =
        referenceData[ReferenceDataKeys.caOutputForms] ?? [];
    final String raw = response.body["responseData"]["reportList"];
    final List<String> list = raw.split(",").map((e) => e.trim()).toList();

    for (final String data in list) {
      final Reference? ref = outputFormRef
          .where((value) => value.id == int.tryParse(data))
          .cast<Reference?>()
          .firstOrNull;

      if (ref != null) {
        outputForms.add(
          OutputForm(
            id: ref.id,
            name: ref.name,
            url: ref.reference3,
            ref1: ref.reference1,
            ref2: ref.reference2,
            ref4: ref.reference4,
            ref5: ref.reference5,
          ),
        );
      }
    }

    return outputForms;
  }

  /// Downloads or opens selected output forms for the current application.
  ///
  /// Filters the provided [outputForms] to process only selected items,
  /// then generates each form via API call and handles the resulting file.
  ///
  /// Depending on [isDownload], files are either saved locally or opened
  /// in a new browser tab.
  ///
  /// - [outputForms] list of available output forms.
  /// - [docType] specifies the document format (e.g., "pdf").
  /// - [isDownload] determines whether to download or open the file.
  ///
  /// Throws an [ApiException] if one or more forms fail to generate.
  Future<void> downloadOutputForms(
    List<OutputForm> outputForms,
    String? docType, {
    required bool isDownload,
  }) async {
    if (outputForms.isEmpty) {
      return;
    }

    final String appRefNo = Globals.request?.applicationRefNo ?? "UNKNOWN";

    // Only selected forms
    final selectedForms = outputForms.where((f) => f.isSelected).toList();
    if (selectedForms.isEmpty) {
      return;
    }

    final List<String> errors = [];

    await Future.wait(
      selectedForms.map((form) async {
        try {
          final String endpoint = form.url ?? "";

          final data = BaseRequest.baseRequest({
            "appRefNo": Globals.request?.applicationRefNo,
            "docType": docType ?? "pdf",
          });
          final AppResponse response = await _apiManager.post(endpoint, data);

          if (response.status == ResponseStatus.success) {
            final base64 = response.body!["responseData"]["response"];
            final Uint8List bytes = base64Decode(base64);
            docType = response.body!["responseData"]["type"];

            final String safeName =
                (form.name ?? "Form").replaceAll(RegExp(r"[^\w\-]+"), "_");
            final String filename = "${appRefNo}_$safeName.$docType";
            if (!isDownload) {
              await FileDownloadService.instance
                  .openFileInNewTab(bytes, filename);
            } else {
              await FileSaver.instance.saveFile(
                name: filename,
                bytes: bytes,
              );
            }
          } else {
            errors.add("[${form.name}] ${response.message}");
          }
        } on Object catch (e) {
          errors.add("[${form.name}] $e");
        }
      }),
    );

    if (errors.isNotEmpty) {
      throw ApiException(
        "Some forms failed to generate:\n- ${errors.join('\n- ')}",
      );
    }
  }

  /// Fetches company limit details for the current application.
  ///
  /// Sends a request using the application reference number and maps
  /// the response into a list of [LimitDetail] models based on
  /// the "companyData" section.
  ///
  /// Returns a list of [LimitDetail] objects on successful response.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<LimitDetail>> getCompanyLimitDetails() async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCompanyLimitDetails, data);
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final List<dynamic> raw = response.body["responseData"]["companyData"];
    return raw
        .map((e) => LimitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches guarantor exposure details for the current application.
  ///
  /// Sends a request using the application reference number and maps
  /// the response into a list of [GuarantorsExposure] models.
  ///
  /// Returns a list of [GuarantorsExposure] objects on successful response.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<GuarantorsExposure>> getGuarantorExposure() async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getGuarantorExposure, data);
    if (response.status == ResponseStatus.error) {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }

    final List<dynamic> raw = response.body["responseData"] as List;
    return raw
        .map((e) => GuarantorsExposure.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches pipeline request details for the given group and RIM.
  ///
  /// Sends a request using the current application's group ID and the
  /// provided [rimNo] to retrieve pipeline facility details from the backend.
  /// The response is mapped into a list of [ProposedFacilities] models.
  ///
  /// - [rimNo] represents the RIM identifier used for filtering results.
  ///
  /// Returns a list of [ProposedFacilities] objects.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<ProposedFacilities>> getPipelineRequestDetails(int? rimNo) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "groupId": Globals.request?.groupId,
      "rimNo": rimNo,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getPipelineRequestDetails,
      payload,
    );

    final List<dynamic> listJson = response.body["responseData"];
    // logger.i("listJson length : ${listJson.length}");
    // List<ProposedFacilities> proposedList = [];
    // for (final proposed in listJson) {
    //   logger.i("proposed value : ${proposed.toString()}");
    //   proposedList.add(ProposedFacilities.fromJson(proposed));
    // }
    // logger.i(
    //     "First value :
    // ${ProposedFacilities.fromJson(listJson.first).toJson().toString()}");
    // proposedList.add(ProposedFacilities.fromJson(listJson.first));
    // logger.i("proposedList lenght : ${proposedList.length}");
    // logger.i(
    //     "listJson map length : ${listJson.map((e) =>
    // ProposedFacilities.fromJson(e as Map<String,
    // dynamic>)).toList().length}");

    return listJson
        .map((e) => ProposedFacilities.fromJson(e as Map<String, dynamic>))
        .toList();

    // return proposedList;
  }

  /// currently not in use
  // Future<LegalAndLimitDetails> getLegalAndLimitDetails() async {
  //   final Map<String, dynamic> payload = BaseRequest.baseRequest({
  //     "appRefNo": Globals.request?.applicationRefNo,
  //     "userAction": 0,
  //   });

  //   final AppResponse response = await _apiManager.post(
  //     APIEndpoints.getLegalAndLimitDetails,
  //     payload,
  //   );
  //   if (response.status == ResponseStatus.error) {
  //     //throw Exception(response.message);
  //     throw ApiException(response.message);
  //   }
  //   final Map<String, dynamic> responseData =
  //       response.body["responseData"] as Map<String, dynamic>;
  //   return LegalAndLimitDetails.fromJson(responseData);
  // }

  /// Transforms raw group position API response into structured models.
  ///
  /// Parses the provided [getGroupPositionResponseData] and converts it into
  /// [GroupPosition] and related structures, including present and proposed
  /// positions as well as grouped customer-wise data.
  ///
  /// Extracts key financial metrics and organizes them into
  /// `presentPosition`, `proposedPosition`, and `groups` collections
  /// for UI consumption.
  ///
  /// Returns a populated [GroupPosition] object containing the transformed data.
  ///
  /// Returns an empty [GroupPosition] if response data is null or empty.
  ///
  /// Handles parsing errors gracefully without interrupting execution.
  Future<GroupPosition> transformGroupPositionFacilitiesData(
    AppResponse? getGroupPositionResponseData,
  ) async {
    final List<Position> proposedPosition = [];
    // logger.i(
    //     "responseData group is
    // ${getGroupPositionResponseData?.body["responseData"]}");
    //getGroupPositionResponseData.body['responseData']['proposed_position'];
    final List<Position> presentPosition = [];
    GroupPosition groupPositionList = GroupPosition()
      ..proposedPosition = proposedPosition
      ..presentPosition = presentPosition;
    groups = [];
    if (getGroupPositionResponseData?.body["responseData"].isEmpty) {
      return groupPositionList;
    }
    // Map<String,Map<String,dynamic>> responseData =
    // getGroupPositionResponseData?.body["responseData"];
    final List<dynamic> responseData =
        getGroupPositionResponseData?.body["responseData"];
    // logger.i("type is ${responseData.runtimeType}");
    // logger.i("ResponseData: $responseData");
    // logger.i("ResponseData Type: ${responseData.runtimeType}");
    try {
      for (final json in responseData) {
        Position pos = Position.fromJsonPresent(json);
        presentPosition.add(pos);
        final List<String> presentValues = [
          pos.overriddenCRR.toString(),
          pos.modelGeneratedCRR.toString(),
          pos.fundBasedLimits.toString(),
          pos.nonFundBasedLimits.toString(),
          pos.totalLimits.toString(),
          pos.totalTangibleSecurity.toString(),
          pos.totalCCSecurity.toString(),
          pos.totalLimitsNetOfTotalTangibleSecurity.toString(),
          pos.totalLimitsNetOfCashCollateralOnly.toString(),
        ];
        List<String> proposedValues = [];
        //CustomerPosition(customerName: pos.customerName.toString(),
        //presentRowValues: [], proposedRowValues: proposedRowValues)
        // if (json["isProposed"] ?? false) {
        pos = Position.fromJsonProposed(json);
        proposedPosition.add(pos);
        proposedValues = [
          pos.overriddenCRR.toString(),
          pos.modelGeneratedCRR.toString(),
          pos.fundBasedLimits.toString(),
          pos.nonFundBasedLimits.toString(),
          pos.totalLimits.toString(),
          pos.totalTangibleSecurity.toString(),
          pos.totalCCSecurity.toString(),
          pos.totalLimitsNetOfTotalTangibleSecurity.toString(),
          pos.totalLimitsNetOfCashCollateralOnly.toString(),
        ];
        // }
        groups.add(
          CustomerPosition(
            customerName: pos.customerName.toString(),
            rimNo: pos.rimNo.toString(),
            order: pos.order,
            presentRowValues: presentValues,
            proposedRowValues: proposedValues,
          ),
        );

        groupPositionList = GroupPosition()
          ..proposedPosition = proposedPosition;
        if (!Utils.isGroupApplication()) {
          groupPositionList.presentPosition = presentPosition;
        }
        // logger.i("group position data is:$groupPositionList");
        // logger.i("group customerswise data $groups");
      }
    } on Exception catch (_, e) {
      logger.i("exception $e");
    }
    return groupPositionList;
  }

  /// Fetches users for the given role codes.
  ///
  /// Retrieves roles based on the provided [roleCodes] and
  /// flattens their associated users into a single list.
  /// Each user is enriched with a populated [Role] in
  /// `currentRole` to indicate their associated role,
  /// enabling proper handling in assignment or recommendation flows.
  ///
  /// - [roleCodes] specifies the list of role codes to fetch users for.
  ///
  /// Returns a flattened list of [User] objects with role context assigned.
  ///
  /// Throws an exception if fetching roles or processing data fails.
  Future<List<User>> getUsersByRoles(List<String> roleCodes) async {
    try {
      // Fetch roles from cache or API; only missing role codes hit the network.
      final fetchedRoles = await UsersByRolesService().fetchRoles(roleCodes);

      // Flatten each role's user list and stamp currentRole so the UI knows
      // which role each user belongs to (used in recommend/assign dropdowns).
      return fetchedRoles.expand((role) {
        return (role.users ?? <User>[]).map((user) {
          return user
            ..currentRole = Role(
              bpmRole: role
                  .bpmRole, // BPM display name, e.g. "Relationship Manager-WCAS"
              roleId: role.roleId, // numeric role ID used in approval payloads
              name: role.code, // role code doubles as the name field here
              code: role.code, // e.g. "RM", "CAM"
            );
        });
      }).toList();
    } on Object {
      rethrow;
    }
  }

  /// Fetches users filtered by the given role codes.
  ///
  /// Retrieves roles using the provided [roleCodes] and maps their
  /// associated users into a flattened list. Each user is enriched
  /// with a [Role] assigned to their `currentRole` field for
  /// downstream usage in UI components such as assignment or
  /// recommendation dropdowns.
  ///
  /// - [roleCodes] specifies the list of role codes to filter users.
  ///
  /// Returns a flattened list of [User] objects with populated role context.
  ///
  /// Throws an exception if fetching roles or processing data fails.
  Future<List<User>> getFilteredUsersByrole(List<String> roleCodes) async {
    try {
      // Fetch roles from cache or API; only missing role codes hit the network.
      final fetchedRoles =
          await UsersByFilteredRolesService().fetchRoles(roleCodes);

      // Flatten each role's user list and stamp currentRole so the UI knows
      // which role each user belongs to (used in recommend/assign dropdowns).
      return fetchedRoles.expand((role) {
        return (role.users ?? <User>[]).map((user) {
          return user
            ..currentRole = Role(
              bpmRole: role
                  .bpmRole, // BPM display name, e.g. "Relationship Manager-WCAS"
              roleId: role.roleId, // numeric role ID used in approval payloads
              name: role.code, // role code doubles as the name field here
              code: role.code, // e.g. "RM", "CAM"
            );
        });
      }).toList();
    } on Object {
      rethrow;
    }
  }

  /// Submits the application for approval based on the provided action and context.
  ///
  /// Builds a request using the current application reference and user action,
  /// along with optional parameters such as assigned user, role, stage,
  /// delegation, and decline reasons.
  ///
  /// - [recommendedToUser] specifies the target user for assignment.
  /// - [commentId] identifies the associated comment.
  /// - [userActionId] represents the action being performed.
  /// - [mode] defines the submission mode.
  /// - [avoidWarning] controls whether warnings are bypassed.
  /// - [returnToUser] indicates if the application should be returned.
  /// - [approvalDelegation] specifies delegation details, if any.
  /// - [reasonForDecline] provides a reason when declining.
  /// - [userAction] determines the flow of assignment and processing.
  /// - [stage] defines the workflow stage.
  /// - [assignedRole] overrides the assigned role if provided.
  /// - [rightFirstTime] flags first-time processing logic.
  ///
  /// Returns the raw [AppResponse] for further handling by the caller.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<AppResponse> submitApplication(
    User? recommendedToUser,
    int? commentId,
    int? userActionId, {
    int mode = 0,
    bool avoidWarning = true,
    bool returnToUser = false,
    String approvalDelegation = "",
    String reasonForDecline = "",
    Enum? userAction,
    String stage = "",
    String assignedRole = "",
    int rightFirstTime = 0,
  }) async {
    // Transform grid data before creating request

    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "mode": mode,
      "userAction": userActionId ?? 0,
      "commentId": commentId ?? 0,
      "avoidWarning": avoidWarning,
      "returnToUser": returnToUser,
    });
    final List<Enum> actionList = [
      UserAction.returned,
      UserAction.recommended,
      FOLTypeAction.sendToDocumentation,
      FOLTypeAction.sendToDocumentationChecker,
      FOLTypeAction.sendToDocumentationMaker,
      FOLTypeAction.sendToRoRm,
      FOLTypeAction.returnFromDocCCU,
      FOLTypeAction.sendToCCUChecker,
      FOLTypeAction.sendToCCUMaker,
      FOLTypeAction.finalFolGenerated,
      FOLTypeAction.draftFolGenerated,
      FOLTypeAction.documentationSubmitted,
      FOLTypeAction.returnToUser,
      FOLTypeAction.initiateFitToLend,
    ];
    if (approvalDelegation.isNotEmpty) {
      data["requestData"]["approvalDelegation"] = approvalDelegation;
    }
    if (reasonForDecline.isNotEmpty) {
      data["requestData"]["reasonForDecline"] = reasonForDecline;
    }
    if (userAction == UserAction.approveOnBehalfOf) {
      data["requestData"]["approveOnBehalfOf"] = "";
      if (recommendedToUser?.currentRole?.bpmRole != null) {
        data["requestData"]["approveOnBehalfOfRole"] =
            recommendedToUser?.currentRole?.bpmRole ?? "";
      }
    } else if (actionList.contains(userAction)) {
      if (recommendedToUser?.id != null) {
        data["requestData"]["assignedTo"] = recommendedToUser?.id ?? "";
      }
      if (recommendedToUser?.currentRole?.bpmRole != null) {
        data["requestData"]["assignedRole"] =
            recommendedToUser?.currentRole?.bpmRole ?? "";
      }
    }
    if (stage.isNotEmpty) {
      data["requestData"]["stage"] = stage;
    }
    if (assignedRole.isNotEmpty) {
      data["requestData"]["assignedRole"] = assignedRole;
    }
    if (rightFirstTime == 1) {
      data["requestData"]["rightFirstTime"] = rightFirstTime;
    }
    final AppResponse response =
        await _apiManager.post(APIEndpoints.submitApplicationApproval, data);
    return response;
  }

  /// Fetches the last assigned role for the current application.
  ///
  /// Sends a request using the application reference number and
  /// attempts to map the response into a [Role] object.
  ///
  /// Returns the last assigned [Role] if available,
  /// otherwise returns `null`.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<Role?> getLastAssignedRole() async {
    Role? lastRole;
    try {
      final Map data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getLastAssignedRoleCCSYS, data);
      if (response.status == ResponseStatus.success) {
        if (response.body["responseData"] != null &&
            response.body["responseData"].isNotEmpty) {
          try {
            lastRole = Role.fromJsonCCSYS(response.body["responseData"]);
          } on Object catch (e) {
            logger.i("exception $e");
          }
        }
      }
      return lastRole;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Fetches and caches reference data required for approval workflows.
  ///
  /// Retrieves multiple reference types from the backend and populates
  /// corresponding global variables used across the application.
  ///
  /// Updates role mappings, action types, recommendation lists,
  /// delegation references, and other approval-related configurations.
  ///
  /// This method also refreshes application read-only state via utility checks.
  ///
  /// Throws an [ApiException] if fetching reference data fails.
  Future<void> fetchReference() async {
    Map<String, List<Reference>> referenceData = {};
    referenceData = await _referenceDataService.getReferenceData([
      ReferenceDataKeys.requestStatus,
      ReferenceDataKeys.userActionType,
      ReferenceDataKeys.roleType,
      ReferenceDataKeys.recommendationList,
      ReferenceDataKeys.returnedRolesList,
      ReferenceDataKeys.approvalDelegationList,
      ReferenceDataKeys.reasonForDecline,
      ReferenceDataKeys.approvalsOnBeHelafOf,
      ReferenceDataKeys.approvalDocumentationStages,
      ReferenceDataKeys.folTypes,
      ReferenceDataKeys.worklistStatusMap,
      ReferenceDataKeys.approvalListReleaseStages,
      ReferenceDataKeys.passwordModeForApproval,
    ]);
    Globals.requestStatus = referenceData[ReferenceDataKeys.requestStatus]!
        .map((ref) => {ref.name: ref.id})
        .toList();
    Globals.userAction = referenceData[ReferenceDataKeys.userActionType]!
        .map((ref) => {ref.name: ref.id})
        .toList();
    Globals.superUserRoles.addAll(
      referenceData[ReferenceDataKeys.roleType]!.map((ref) {
        return {ref.reference1 ?? "": ref.reference3 ?? ""};
      }),
    );
    Globals.superBpmRolesId.addAll(
      referenceData[ReferenceDataKeys.roleType]!.map((ref) {
        return {ref.reference3 ?? "": ref.id ?? 0};
      }),
    );
    Globals.superBpmRoles.addAll(
      referenceData[ReferenceDataKeys.roleType]!.map((ref) {
        return ref.reference3 ?? "";
      }),
    );
    Globals.superRolesId.addAll(
      referenceData[ReferenceDataKeys.roleType]!.map((ref) {
        return {ref.reference1 ?? "": ref.id ?? 0};
      }),
    );
    Globals.folTypeAction = referenceData[ReferenceDataKeys.folTypes]!
        .map((ref) => {ref.name: ref.id})
        .toList();
    Utils.checkIfAppReadOnly();
    Globals.recommendReferences =
        referenceData[ReferenceDataKeys.recommendationList] ?? [];
    Globals.returnReferences =
        referenceData[ReferenceDataKeys.returnedRolesList] ?? [];
    Globals.delegationReferences =
        referenceData[ReferenceDataKeys.approvalDelegationList] ?? [];
    Globals.reasonForDecline = referenceData[ReferenceDataKeys.reasonForDecline]
            ?.map((ref) => ref.name)
            .whereType<String>()
            .toList() ??
        [];
    Globals.approvalReferences =
        referenceData[ReferenceDataKeys.approvalsOnBeHelafOf] ?? [];
    Globals.documentStagesReferences =
        referenceData[ReferenceDataKeys.approvalDocumentationStages] ?? [];
    Globals.worklistStatusReferences =
        referenceData[ReferenceDataKeys.worklistStatusMap] ?? [];
    Globals.limitReleaseStagesReferences =
        referenceData[ReferenceDataKeys.approvalListReleaseStages] ?? [];
    ApprovalUtils.passwordModeReference =
        referenceData[ReferenceDataKeys.passwordModeForApproval] ?? [];
  }

  /// Retrieves the initiated role for the current user.
  ///
  /// Fetches the last assigned role and maps it against the predefined
  /// [Globals.superUserRoles] to determine the corresponding role key.
  ///
  /// Returns the matched role key as a string.
  ///
  /// Returns an empty string if no matching role is found
  /// or if an error occurs during processing.
  Future<String> getInitiatedRole() async {
    try {
      final Role? assignedRole = await getLastAssignedRole();
      // logger.i("role : ${assignedRole?.roleRM}
      // ${assignedRole?.createdRM}");
      for (final Map<String, String> map in Globals.superUserRoles) {
        final entry = map.entries.firstWhere(
          (e) => e.value == assignedRole?.roleRM,
          orElse: () => const MapEntry("", ""),
        );
        if (entry.key.isNotEmpty) {
          return entry.key;
        }
      }
    } on Object catch (e) {
      logger.i("Error Fetching : $e");
    }
    return "";
  }

  /// Fetches application strategy details for a given type and entity.
  ///
  /// Sends a request using the application reference number, strategy
  /// comment type, and entity identifier to retrieve associated comments.
  ///
  /// - [type] specifies the strategy comment category.
  /// - [entityIdentifier] identifies the entity context.
  /// - [appReffNo] optionally overrides the default application reference.
  ///
  /// Returns a list of [Comment] objects representing the retrieved data.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<List<Comment>> getApplicationStrategyDetails(
    CommentsType type,
    EntityIdentifier entityIdentifier, {
    String? appReffNo,
  }) async {
    final Map<String, dynamic> requestData = {
      "appRefNo": appReffNo ?? Globals.request?.applicationRefNo,
      "strategyCommentsType": ServerConstants.commentTypeId[type],
      "entityIdentifier": ServerConstants.entityId[entityIdentifier],
    };

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getApplicationStrategyDetails,
      data,
    );

    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]?["status"]?["statusDescription"];

      return (response.body["responseData"]?["commentList"] as List<dynamic>?)
              ?.map((item) => Comment.fromJson(item))
              .toList() ??
          [];
    }

    //throw Exception(response.message);
    throw ApiException(response.message);
  }

  /// Saves application strategy details for the current request.
  ///
  /// Sends strategy type and associated comments to the backend
  /// for persistence.
  ///
  /// - [strategyCommentsType] identifies the strategy comment category.
  /// - [comment] contains the list of comments to be saved.
  ///
  /// Returns a response message or identifier from the API
  /// if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<String?> saveApplicationStrategyDetails(
    int? strategyCommentsType,
    List<Comment>? comment,
  ) async {
    final Map<String, dynamic> requestData = {
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": strategyCommentsType,
      "commentList": comment?.map((com) => com.toPresentRequestJson()).toList(),
    };

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveApplicationStrategyDetails,
      data,
    );

    if (response.status == ResponseStatus.success) {
      return response.body["responseData"].toString();
    }

    //throw Exception(response.message);
    throw ApiException(response.message);
  }

  /// Saves review comments for the current application.
  ///
  /// Wraps the provided [comment] into a request payload and sends it
  /// to the backend for persistence.
  ///
  /// - [comment] contains the review comment details to be saved.
  ///
  /// Returns the generated review comment ID as a string
  /// if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<String> saveReviewComments(Comment comment) async {
    final Map data = BaseRequest.baseRequest({
      "commentList": [comment.toSaveReviewJson()],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveReviewComments, data);
    if (response.status == ResponseStatus.success) {
      return response.body["responseData"]["reviewCommentId"].toString();
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches clean exposure information for the current application.
  ///
  /// Sends a request using the application's reference number and
  /// maps the response into a [CleanExposure] model if data is available.
  ///
  /// Returns a [CleanExposure] object on successful response,
  /// otherwise returns `null` if no data is available.
  ///
  /// Throws an [ApiException] if an error occurs during the API request.
  Future<CleanExposure?> getCleanExposureInfo() async {
    try {
      final Map<String, dynamic> requestData = {
        "appRefNo": Globals.request?.applicationRefNo,
      };

      final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getCleanExposureInfo,
        data,
      );

      if (response.status == ResponseStatus.success) {
        response.message = response.body["responseData"].toString();
        if (response.body["responseData"] != null) {
          final CleanExposure cleanExposure =
              CleanExposure.fromJson(response.body["responseData"]);
          return cleanExposure;
        }
      }
      // throw Exception(response.message);
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
    return null;
  }

  /// Inserts clean exposure information into the system.
  ///
  /// Sends the provided list of [exposure] data to the backend
  /// after converting each item into the required request format.
  ///
  /// - [exposure] contains a list of exposure details to be inserted.
  ///
  /// Returns a response message or identifier from the API
  /// if the operation succeeds.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<String?> insertCleanExposureInfo(
    List<Exposure> exposure,
  ) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest(
      exposure.map((ex) => ex.toInsertJson()).toList(),
    );

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveCleanExposureInfo,
      data,
    );

    if (response.status == ResponseStatus.success) {
      return response.body["responseData"].toString();
    }

    throw ApiException(response.message);
  }

  /// Validates an RSA token provided by the user.
  ///
  /// Encrypts the given [token] and sends it to the backend
  /// for validation against the system.
  ///
  /// - [token] represents the raw RSA token entered by the user.
  ///
  /// Returns `true` if the token is successfully validated,
  /// otherwise returns `false`.
  ///
  /// Throws an [ApiException] if an error occurs during the request.
  Future<bool> validateRSAToken(String token) async {
    try {
      final String encryptedToken = EncryptionHelper.encrypt(token);
      logger.i("encryptedToken : $encryptedToken");

      final Map<String, dynamic> requestData = {
        "tokenData": encryptedToken,
      };

      final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

      final AppResponse response = await _apiManager.post(
        APIEndpoints.validateRSAToken,
        data,
      );

      if (response.status == ResponseStatus.success) {
        return true;
      }
      // throw Exception(response.message);
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
    return false;
  }

  /// Validates the approval action for the current application.
  ///
  /// Sends a request with the current application's reference number
  /// and the provided [userAction] to verify whether the action
  /// is allowed or meets approval criteria.
  ///
  /// - [userAction] represents the action performed by the user.
  ///
  /// Returns the raw [AppResponse] for flexible handling by the caller.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<AppResponse> validateApproval(int userAction) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "userAction": userAction,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.validateApproval, data);
    return response;
  }
}
