import "dart:convert";
import "dart:typed_data";

import "package:file_saver/file_saver.dart";
import "package:flutter/material.dart";
import "package:uuid/uuid.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";
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
import "package:wcas_frontend/models/request/approval/request_for_fol.dart";
import "package:wcas_frontend/models/request/comment.dart";

class ApprovalRepository {
  ApprovalRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();
  static ApprovalRepository _singleton = ApprovalRepository();
  static ApprovalRepository get instance => _singleton;
  final ReferenceDataService _referenceDataService;

  static void overrideInstance(ApprovalRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  late List<CustomerPosition> groups = [];
  List<ReferenceType> allReferences = [];

  /// POST API method to get Proposed Facilities Positions data.
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
      throw response.message;
    }
    // final List<dynamic> proposedPosition =
    //     response.body['responseData']['proposed_position'];
    // final List<dynamic> presentPosition =
    //     response.body['responseData']['present_position'];
    // GroupPosition groupPositionList = GroupPosition();
    // groupPositionList.proposedPosition = proposedPosition
    //     .map((json) => Position.fromJson(json as Map<String, dynamic>))
    //     .toList();
    // groupPositionList.presentPosition = presentPosition
    //     .map((json) => Position.fromJson(json as Map<String, dynamic>))
    //     .toList();
    // return groupPositionList;

    // groupPositionData = await transformGroupPositionFacilitiesData(response);
    // return groupPositionData;

    return response;
  }

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
      throw response.message;
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
          OutputForm(id: ref.id, name: ref.name, url: ref.reference3),
        );
      }
    }

    return outputForms;
  }

  Future<void> downloadOutputForms(
    List<OutputForm> outputForms,
    bool isDownload,
    String? docType,
  ) async {
    if (outputForms.isEmpty) return;

    final String appRefNo = Globals.request?.applicationRefNo ?? "UNKNOWN";

    // Only selected forms
    final selectedForms = outputForms.where((f) => f.isSelected).toList();
    if (selectedForms.isEmpty) return;

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
        } catch (e) {
          errors.add("[${form.name}] ${e.toString()}");
        }
      }),
    );

    if (errors.isNotEmpty) {
      throw "Some forms failed to generate:\n- ${errors.join('\n- ')}";
    }
  }

  // Future<void> downloadOutputForm(List<OutputForm> outputForms) async {
  //   String docType = "docx";
  //   Map data = BaseRequest.baseRequest(
  //       {"appRefNo": Globals.request?.applicationRefNo, "docType": docType});
  //   AppResponse response =
  //       await _apiManager.post(APIEndpoints.generateMarkForward, data);
  //   if (response.status == ResponseStatus.success) {
  //     final base64 = response.body!['responseData'];
  //     Uint8List bytes = base64Decode(base64);
  //     FileDownloadService.instance.openFileInNewTab(
  //         bytes,
  // "${Globals.request?.applicationRefNo}_MarkForward.$docType");
  //   } else {
  //     throw response.message;
  //   }
  // }

  Future<List<Comment>> getQueryResponse() async {
    final Map<String, dynamic> requestPayload = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id,
      "userName": Globals.user?.name,
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "appRefNo": Globals.request?.applicationRefNo,
      },
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getQueryResponse, requestPayload);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body["commentList"];
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LimitDetail>> getCompanyLimitDetails() async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCompanyLimitDetails, data);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body["responseData"]["companyData"];
    return raw
        .map((e) => LimitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GuarantorsExposure>> getGuarantorExposure() async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getGuarantorExposure, data);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final List<dynamic> raw = response.body["responseData"] as List;
    return raw
        .map((e) => GuarantorsExposure.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
    // debugPrint("listJson length : ${listJson.length}");
    // List<ProposedFacilities> proposedList = [];
    // for (final proposed in listJson) {
    //   debugPrint("proposed value : ${proposed.toString()}");
    //   proposedList.add(ProposedFacilities.fromJson(proposed));
    // }
    // debugPrint(
    //     "First value :
    // ${ProposedFacilities.fromJson(listJson.first).toJson().toString()}");
    // proposedList.add(ProposedFacilities.fromJson(listJson.first));
    // debugPrint("proposedList lenght : ${proposedList.length}");
    // debugPrint(
    //     "listJson map length : ${listJson.map((e) =>
    // ProposedFacilities.fromJson(e as Map<String,
    // dynamic>)).toList().length}");

    return listJson
        .map((e) => ProposedFacilities.fromJson(e as Map<String, dynamic>))
        .toList();

    // return proposedList;
  }

  Future<LegalAndLimitDetails> getLegalAndLimitDetails() async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "userAction": 0,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getLegalAndLimitDetails,
      payload,
    );
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final Map<String, dynamic> responseData =
        response.body["responseData"] as Map<String, dynamic>;
    return LegalAndLimitDetails.fromJson(responseData);
  }

  Future<GroupPosition> transformGroupPositionFacilitiesData(
    AppResponse? getGroupPositionResponseData,
  ) async {
    final List<Position> proposedPosition = [];
    // debugPrint(
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
    // debugPrint("type is ${responseData.runtimeType}");
    // debugPrint("ResponseData: $responseData");
    // debugPrint("ResponseData Type: ${responseData.runtimeType}");
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
        if (json["isProposed"] == true) {
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
        }
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
        // debugPrint("group position data is:$groupPositionList");
        // debugPrint("group customerswise data $groups");
      }
    } on Exception catch (_, e) {
      debugPrint("exception $e");
    }
    return groupPositionList;
  }

  Future<List<User>> getUsersByRoles(List<String> roleCodes) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": roleCodes,
        "segment": Globals.user?.segments?.join(","),
        "region": Globals.user?.regions?.join(","),
      });
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getUsersByRoles,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          final List<User> users = [];

          for (final role in responseData) {
            final userDetails = role["userDetails"] as List<dynamic>;
            users.addAll(
              userDetails.map((e) {
                final User user = User.fromJson(e)
                  ..currentRole = Role(
                    bpmRole: role["bpmRoleName"],
                    roleId: role["roleId"],
                    name: role["role"],
                  );
                return user;
              }).toList(),
            );
          }
          // debugPrint("userscheck");
          // debugPrint(users.first.id);
          // debugPrint(users.first.name);
          // debugPrint(users.first.currentRole!.roleId.toString());
          return users;
        }
        return [];
      }

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

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
          } catch (e) {
            debugPrint("exception $e");
          }
        }
      }
      return lastRole;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> fetchReference() async {
    Map<String, List<Reference>> referenceData = {};
    referenceData = await ReferenceDataService().getReferenceData([
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

  Future<String> getInitiatedRole() async {
    try {
      final Role? assignedRole = await getLastAssignedRole();
      // debugPrint("role : ${assignedRole?.roleRM}
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
    } catch (e) {
      debugPrint("Error Fetching : $e");
    }
    return "";
  }

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

    throw response.message;
  }

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

    throw Exception(response.message);
  }

  Future<String> saveReviewComments(Comment comment) async {
    final Map data = BaseRequest.baseRequest({
      "commentList": [comment.toSaveReviewJson()],
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveReviewComments, data);
    if (response.status == ResponseStatus.success) {
      return response.body["responseData"]["reviewCommentId"].toString();
    } else {
      throw response.message;
    }
  }

  Future<List<String>?> getDashboardRoles({
    required String? workListKey,
  }) async {
    final List<Map<String, int>> bpmRolesMap = Globals.superBpmRolesId;

    //approvals/getDashboardRoleMapList
    final Map data = BaseRequest.baseRequest({
      "roleId": Globals.user?.currentRole?.roleId,
      "worklistKey": workListKey,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getDashboardRoleMapList, data);
    if (response.status == ResponseStatus.success) {
      final String? resData = response.body["responseData"];
      final List<String>? convertedresData = resData?.split(",");
      final List<int?>? roleIds = convertedresData?.map(int.parse).toList();
      final Set<int?> wanted = (roleIds ?? []).toSet();

      final List<String> bpmRoles = bpmRolesMap
          .expand(
            (Map<String, int> bpmRole) => bpmRole.entries,
          ) // turn each map into key/value entries
          .where((MapEntry<String, int> roleA) => wanted.contains(roleA.value))
          .map((MapEntry<String, int> roleB) => roleB.key)
          .toList();

      return bpmRoles;
    } else {
      // throw response.message;
      return [];
    }
  }

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
    } catch (e) {
      throw e.toString();
    }
    return null;
  }

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

    throw Exception(response.message);
  }

  Future<bool> validateRSAToken(String token) async {
    try {
      final String encryptedToken = EncryptionHelper.encrypt(token);
      debugPrint("encryptedToken : $encryptedToken");

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
    } catch (e) {
      throw e.toString();
    }
    return false;
  }

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
