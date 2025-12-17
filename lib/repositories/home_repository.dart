import 'dart:convert';
import 'package:wcas_frontend/core/constants/constants.dart';
// import 'package:wcas_frontend/core/env_config.dart';
// import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';
import 'package:wcas_frontend/models/home/audit.dart';
// import 'package:uuid/uuid.dart';

class HomeRepository {
  static final _singleton = HomeRepository();
  static HomeRepository get instance => _singleton;

  final APIManager _apiManager;

  HomeRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  void saveUIAuditData(
    Audit model,
  ) async {
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveUIAuditUrl, model.toJson());
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
  }

  Future<List<ReferenceType>> getReferenceData(List<String> missingKeys) async {
    List<ReferenceType> referenceDataTypeList = <ReferenceType>[];

    try {
      Map<String, dynamic> data = BaseRequest.baseRequest(
          {"referenceDataName": missingKeys, "isAdmin": false});

      AppResponse response = await _apiManager.post(
        APIEndpoints.referenceData,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null) {
          (responseData as List).map((data) {
            referenceDataTypeList.add(ReferenceType.fromJson(data));
          }).toList();
        }
      }

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return referenceDataTypeList;
  }
}
