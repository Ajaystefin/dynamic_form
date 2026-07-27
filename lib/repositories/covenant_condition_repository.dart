import "dart:convert";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";

/// Repository responsible for handling covenant and condition-related operations.
///
/// Provides methods to interact with APIs for managing covenant and condition data,
/// and maintains a singleton instance for shared usage across the application.
class CovenantConditionRepository {
  CovenantConditionRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [CovenantConditionRepository].
  static final _singleton = CovenantConditionRepository();

  /// Returns the singleton instance of [CovenantConditionRepository].
  static CovenantConditionRepository get instance => _singleton;

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Retrieves covenant or condition details for the current application.
  ///
  /// Accepts a flag to distinguish between covenants and conditions, fetches the data
  /// from the backend, and maps the response into a list of [Covenant] objects.
  /// Returns the list of covenants or conditions on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final body = response.body;
    final List<dynamic> rawList = body is List
        ? body
        : (body["responseData"]?["covenantList"] as List<dynamic>? ?? []);

    return rawList
        .map((e) => Covenant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves covenant or condition details for the current application.
  ///
  /// Accepts a list of covenant/condition data in JSON format along with a flag
  /// indicating the type, and submits it to the backend.
  /// Returns a success message string on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String> saveCovenantDetails(
    List<Map<String, dynamic>> covenantJsonList,
    int? isCovenant,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "covenantList": covenantJsonList,
      "appRefNo": Globals.request?.applicationRefNo,
      "isCovenant": isCovenant,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveCovenants, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves condition details for the current application.
  ///
  /// Sends the application reference number to the backend and parses
  /// the response into a list of [CovenantCondition] objects.
  /// Returns the list of conditions on success.
  /// Throws [ApiException] if the API call fails.
  Future<List<CovenantCondition>> getConditions() async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getConditions, json.encode(data));
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final List<dynamic> raw =
        response.body["responseData"]["conditionsList"] as List;
    return raw.map((e) => CovenantCondition.fromJson(e)).toList();
  }
}
