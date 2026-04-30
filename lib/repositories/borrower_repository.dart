import "dart:convert";

import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/group_borrower_search.dart";

class BorrowerRepository {
  BorrowerRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = BorrowerRepository();
  static BorrowerRepository get instance => _singleton;

  final APIManager _apiManager;

  Future<List<Customer>> getGroupCustomers() async {
    final AppResponse response =
        await _apiManager.get(APIEndpoints.getGroupCustomers);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body["responseData"] as List;
    return raw
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GroupBorrowerSearchResponse> getCustomerByRim(int rim) async {
    final payload = BaseRequest.baseRequest({
      "PartyId": rim,
      //if (isFI)
      "appBusinessSegment": Globals.request?.businessSegment?.name,
    });

    final response = await _apiManager.post(
      APIEndpoints.getCustomerByRim,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final Map<String, dynamic> body = response.body as Map<String, dynamic>;
    return GroupBorrowerSearchResponse.fromJson(body);
  }

  Future<Customer?> getCustomerByPotentialRim(int rim) async {
    Customer? requestCustomer;
    try {
      final Map data = BaseRequest.baseRequest({
        "PartyId": rim,
        //if (isFI)
        "appBusinessSegment": Globals.request?.businessSegment?.name,
      });
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getCustomerProfile, data);
      if (response.status == ResponseStatus.success) {
        if (response.body["responseData"] != null &&
            response.body["responseData"].isNotEmpty &&
            response.body["responseData"]["PartyInfo"] != null) {
          try {
            requestCustomer = Customer.fromJson(response.body["responseData"]);
          } catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        } else {
          throw "common.noUserFound".tr();
        }
      } else {
        throw "common.noUserFound".tr();
      }
      return requestCustomer;
    } catch (e) {
      throw e.toString();
    }
  }
}
