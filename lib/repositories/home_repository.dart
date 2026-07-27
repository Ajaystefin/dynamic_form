import "dart:convert";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/home/audit.dart";

/// Repository responsible for handling home-related operations.
/// 
/// Provides access to API calls related to home features and maintains
/// a singleton instance for shared usage across the application.
class HomeRepository {
  HomeRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [HomeRepository].
  static final _singleton = HomeRepository();

  /// Returns the singleton instance of [HomeRepository].
  static HomeRepository get instance => _singleton;

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Saves UI audit data to the backend.
  /// 
  /// Accepts an [Audit] model and submits it for logging purposes.
  /// Throws [ApiException] if the API call fails.
  Future<void> saveUIAuditData(
    Audit model,
  ) async {
    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveUIAuditUrl, model.toJson());
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves reference data for the given list of keys.
  /// 
  /// Sends the requested reference data names to the backend and maps
  /// the response into a list of [ReferenceType] objects.
  /// Returns the list of reference data on success.
  /// Throws [ApiException] if the API call fails.
  Future<List<ReferenceType>> getReferenceData(List<String> missingKeys) async {
    final List<ReferenceType> referenceDataTypeList = <ReferenceType>[];

    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest(
        {"referenceDataName": missingKeys, "isAdmin": false},
      );

      final AppResponse response = await _apiManager.post(
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
       // throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }

    return referenceDataTypeList;
  }
}
