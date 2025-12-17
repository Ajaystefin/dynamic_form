import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';
import 'package:wcas_frontend/models/request/approval/guarantors_exposure.dart';
import 'package:wcas_frontend/models/request/approval/limit_detail.dart';
import 'package:wcas_frontend/models/request/approval/output_form.dart';
import 'package:wcas_frontend/models/request/approval/proposed_facilities.dart';
import 'package:wcas_frontend/models/request/approval/request_for_fol.dart';
import 'package:wcas_frontend/models/request/comment.dart';

class ApprovalRepository {
  static ApprovalRepository _singleton = ApprovalRepository();
  static ApprovalRepository get instance => _singleton;

  static void overrideInstance(ApprovalRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  ApprovalRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// POST API method to get Proposed Facilities Positions data.
  Future<GroupPosition> getGroupPositionDetails() async {
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
      }
    };
    AppResponse response = await _apiManager.post(
        APIEndpoints.getProposedFacilities, requestPayload);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> proposedPosition =
        response.body['responseData']['proposed_position'];
    final List<dynamic> presentPosition =
        response.body['responseData']['present_position'];
    GroupPosition groupPositionList = GroupPosition();
    groupPositionList.proposedPosition = proposedPosition
        .map((json) => Position.fromJson(json as Map<String, dynamic>))
        .toList();
    groupPositionList.presentPosition = presentPosition
        .map((json) => Position.fromJson(json as Map<String, dynamic>))
        .toList();
    return groupPositionList;
  }

  Future<List<OutputForm>> getOutputForms() async {
    AppResponse response = await _apiManager.get(APIEndpoints.getOutputForms);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List raw = response.body['responseData']['forms'] as List;
    return raw
        .map((e) => OutputForm.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getQueryResponse, requestPayload);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body['commentList'];
    return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LimitDetail>> getCompanyLimitDetails() async {
    Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });
    AppResponse response =
        await _apiManager.post(APIEndpoints.getCompanyLimitDetails, data);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body['responseData']['companyData'];
    return raw
        .map((e) => LimitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GuarantorsExposure>> getGuarantorExposure() async {
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request?.applicationRefNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getGuarantorExposure, data);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final List<dynamic> raw = response.body['responseData'] as List;
    return raw
        .map((e) => GuarantorsExposure.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProposedFacilities>> getPipelineRequestDetails(int? rimNo) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'groupId': Globals.request?.groupId,
      'rimNo': rimNo.toString(),
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getPipelineRequestDetails,
      payload,
    );

    final List<dynamic> listJson =
        response.body['responseData'] as List<dynamic>;

    return listJson
        .map((e) => ProposedFacilities.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LegalAndLimitDetails> getLegalAndLimitDetails() async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'appRefNo': Globals.request?.applicationRefNo,
      'userAction': 0,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getLegalAndLimitDetails,
      payload,
    );
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final Map<String, dynamic> responseData =
        response.body['responseData'] as Map<String, dynamic>;
    return LegalAndLimitDetails.fromJson(responseData);
  }
}
