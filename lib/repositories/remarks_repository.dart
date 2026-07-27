import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_response.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor_financial_response.dart";

/// Repository responsible for handling remarks-related operations.
/// 
/// Provides methods to interact with APIs for managing remarks and comments,
/// and maintains a singleton instance for shared usage across the application.
class RemarksRepository {
  RemarksRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [RemarksRepository].
  static final _singleton = RemarksRepository();

  /// Returns the singleton instance of [RemarksRepository].
  static RemarksRepository get instance => _singleton;

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Retrieves financial details from Credit Lens for the specified entity.
  /// 
  /// Sends the entity ID in the request payload and parses the response
  /// into a [FinancialDetailsResponse] object.
  /// Returns the financial details on success.
  /// Throws [ApiException] if the API call fails.
  Future<FinancialDetailsResponse> getFinancialDetailsFromCreditLens(
    int entityId,
  ) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = entityId;

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getFinancialDataFromCreditLens,
      payload,
    );
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as Map<String, dynamic>;
    return FinancialDetailsResponse.fromJson(inner);
  }

  /// Retrieves financial ratio analysis details for the specified RIM number.
  /// 
  /// Sends the application reference number along with the provided RIM number
  /// to the backend and parses the response into a
  /// [FinancialRatioAnalysisResponse] object.
  /// Returns the financial ratio analysis details on success.
  /// Throws [ApiException] if the API call fails.
  Future<FinancialRatioAnalysisResponse> getFinancialRatioAnalysisDetails({
    required int rimNo,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = {
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": rimNo,
    };
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getFinancialRatioAnalysisDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as Map<String, dynamic>;
    return FinancialRatioAnalysisResponse.fromJson(inner);
  }

  /// Saves financial ratio analysis details for the current application.
  /// 
  /// Accepts a list of [FinancialRatioAnalysisResponse] items, converts them
  /// into the required JSON list format, and submits them to the backend.
  /// Parses the response and returns the list of saved items.
  /// Throws [ApiException] if the API call fails.
  Future<List<FinancialRatioAnalysisResponse>>
      saveFinancialRatioAnalysisDetails({
    required List<FinancialRatioAnalysisResponse> items,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = items.map((e) => e.toJson()).toList();
    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveFinancialRatioAnalysisDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as List<dynamic>;
    return inner
        .map(
          (e) => FinancialRatioAnalysisResponse.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Deletes a financial ratio analysis entry for the current application.
  /// 
  /// Sends the application reference number, RIM number, entity ID, and
  /// financial category (with optional user-defined ratio type) to the backend.
  /// Parses the response and returns a [DeleteFinancialRatioAnalysisResult].
  /// Throws [ApiException] if the API call fails.
  Future<DeleteFinancialRatioAnalysisResult>
      deleteFinancialRatioAnalysisDetails({
    required int rimNo,
    required int entityId,
    required int financialsCategory,
    String? userAddedRatioType,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = {
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": rimNo.toString(), // API sample uses string
      "entityId": entityId.toString(), // API sample uses string
      "financialsCategory": financialsCategory,
      if (userAddedRatioType != null) "userAddedRatioType": userAddedRatioType,
    };
    final AppResponse response = await _apiManager.delete(
      APIEndpoints.deleteFinancialRatioAnalysisDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"];
    return DeleteFinancialRatioAnalysisResult.fromJson(inner);
  }

  /// Retrieves guarantor financial details for the specified RIM number.
  /// 
  /// Sends the application reference number along with the given RIM number
  /// to the backend and parses the response into a
  /// [GuarantorFinancialDetailsResponse] object.
  /// Returns the guarantor financial details on success.
  /// Throws [ApiException] if the API call fails.
  Future<GuarantorFinancialDetailsResponse> getGuarantorFinancialDetails({
    required int rimNo,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = {
      "appRefNo": Globals
          .request?.applicationRefNo, // stays consistent with your other method
      "rimNo": rimNo,
    };
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getGuarantorFinancialDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as Map<String, dynamic>;
    return GuarantorFinancialDetailsResponse.fromJson(inner);
  }

  /// Deletes guarantor financial details for the current application.
  /// 
  /// Sends the application reference number, RIM number, entity ID, and
  /// financial category (with optional user-defined ratio type) to the backend.
  /// Parses the response and returns a [DeleteFinancialRatioAnalysisResult].
  /// Throws [ApiException] if the API call fails.
  Future<DeleteFinancialRatioAnalysisResult> deleteGuarantorDetails({
    required int rimNo,
    required int entityId,
    required int financialsCategory,
    String? userAddedRatioType,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = {
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": rimNo.toString(), // API sample uses string
      "entityId": entityId.toString(), // API sample uses string
      "financialsCategory": financialsCategory,
      if (userAddedRatioType != null) "userAddedRatioType": userAddedRatioType,
    };
    final AppResponse response = await _apiManager.delete(
      APIEndpoints.deleteGuarantorDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
     //throw Exception(response.message);
     throw ApiException(response.message);
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"];
    return DeleteFinancialRatioAnalysisResult.fromJson(inner);
  }

  /// Deletes guarantor details for the specified entity ID in the current application.
  /// 
  /// Sends the application reference number, RIM number, and entity ID to the backend.
  /// Parses the response and returns a [DeleteFinancialRatioAnalysisResult].
  /// Throws [ApiException] if the API call fails.
  Future<DeleteFinancialRatioAnalysisResult> deleteGuarantorDetailsByEntityId({
    required int entityId,
    required int rimNo,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = {
      "entityId": entityId.toString(),
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": rimNo.toString(),
    };

    final AppResponse response = await _apiManager.delete(
      APIEndpoints.deleteGuarantorDetailsByEntityId,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"]; // plain string, e.g., "Success"
    return DeleteFinancialRatioAnalysisResult.fromJson(inner);
  }

 /// Saves guarantor financial details for the current application.
  /// 
  /// Accepts a list of [GuarantorFinancialDetailsResponse] items, converts them
  /// into the required JSON list format, and submits them to the backend.
  /// Parses the response and returns the list of saved guarantor details.
  /// Throws [ApiException] if the API call fails.
  Future<List<GuarantorFinancialDetailsResponse>>
      saveGuarantorFinancialDetails({
    required List<GuarantorFinancialDetailsResponse> items,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload["requestData"] = items.map((e) => e.toJson()).toList();
    final AppResponse response = await _apiManager.post(
      APIEndpoints
          // or the literal URL
          // if constant isn't available
          .saveGuarantorFinancialDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as List<dynamic>;
    return inner
        .map(
          (e) => GuarantorFinancialDetailsResponse.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
