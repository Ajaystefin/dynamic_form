import 'dart:convert';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart';

class CovenantConditionRepository {
  static final _singleton = CovenantConditionRepository();
  static CovenantConditionRepository get instance => _singleton;

  final APIManager _apiManager;

  CovenantConditionRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<List<Covenant>> getCovenants(int? isCovenant) async {
    final payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "isCovenant": isCovenant,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getCovenants,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final body = response.body;
    final List<dynamic> rawList = body is List
        ? body
        : (body['responseData']?['covenantList'] as List<dynamic>? ?? []);

    return rawList
        .map((e) => Covenant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> saveCovenantDetails(
      List<Map<String, dynamic>> covenantJsonList,
      int? isCovenant,
      ) async {
    Map data = BaseRequest.baseRequest({
      "covenantList": covenantJsonList,
      "appRefNo": Globals.request?.applicationRefNo,
      "isCovenant": isCovenant
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveCovenants, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<CovenantCondition>> getConditions() async {
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request?.applicationRefNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getConditions, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final List<dynamic> raw =
        response.body['responseData']['conditionsList'] as List;
    return raw.map((e) => CovenantCondition.fromJson(e)).toList();
  }

  Future<String> deleteCovenantCondition(
      CovenantCondition? covenantConditionData, int? isCovenant) async {
    covenantConditionData?.deleted = true;
    Map data = BaseRequest.baseRequest({
      "covenantList": [covenantConditionData?.toJson()],
      "applicationRefNumber": ServerConstants.appRefNo,
      "mode": "Edit",
      "isCovenant": isCovenant
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveCovenants, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }
}
