import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart';

class RemarksRepository {
  static final _singleton = RemarksRepository();
  static RemarksRepository get instance => _singleton;

  final APIManager _apiManager;

  RemarksRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<FinancialDetailsResponse> getFinancialDetailsFromCreditLens(
      int entityId) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({});
    payload['requestData'] = entityId;

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getFinancialDataFromCreditLens,
      payload,
    );
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final full = response.body as Map<String, dynamic>;
  final inner = full['responseData'] as Map<String, dynamic>;
  return FinancialDetailsResponse.fromJson(inner);
  }
}
