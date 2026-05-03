import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_response.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor_financial_response.dart";

class RemarksRepository {
  RemarksRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = RemarksRepository();
  static RemarksRepository get instance => _singleton;

  final APIManager _apiManager;

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
      throw response.message;
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as Map<String, dynamic>;
    return FinancialDetailsResponse.fromJson(inner);
  }

  /// Fetch Financial Ratio Analysis details (remarks page)
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
      throw response.message;
    }
    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as Map<String, dynamic>;
    return FinancialRatioAnalysisResponse.fromJson(inner);
  }

  /// - The API expects `requestData` to be a *list* of items.
  /// - Each item has the same shape as FinancialRatioAnalysisResponse.toJson().
  /// - The API returns `responseData` as a *list* of saved items.
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
      throw response.message;
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

  /// Delete a Financial Ratio Analysis item (remarks page)
  /// - API expects rimNo and entityId as strings in requestData (we convert for
  /// safety).
  /// - Response returns responseData as a simple string like "Success".
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
      throw response.message;
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"];
    return DeleteFinancialRatioAnalysisResult.fromJson(inner);
  }

  ///Guarantor section repositories--------------------------
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
      throw response.message;
    }
    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"] as Map<String, dynamic>;
    return GuarantorFinancialDetailsResponse.fromJson(inner);
  }

  /// Delete a Financial Ratio Analysis item (remarks page)
  /// - API expects rimNo and entityId as strings in requestData (we convert for
  /// safety).
  /// - Response returns responseData as a simple string like "Success".
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
      throw response.message;
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"];
    return DeleteFinancialRatioAnalysisResult.fromJson(inner);
  }

  /// Delete guarantor details by entityId (remarks page).
  /// The backend expects requestData: { "entityId": "7656" } and returns
  /// responseData: "Success".
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
      throw response.message;
    }

    final full = response.body as Map<String, dynamic>;
    final inner = full["responseData"]; // plain string, e.g., "Success"
    return DeleteFinancialRatioAnalysisResult.fromJson(inner);
  }

  /// Save Guarantor Financial Details (remarks page)
  /// - The API expects `requestData` to be a *list* of items.
  /// - Each item has the same shape as
  /// GuarantorFinancialDetailsResponse.toJson().
  /// - The API returns `responseData` as a *list* of saved items.
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
      throw response.message;
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
