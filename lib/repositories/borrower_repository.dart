import 'dart:convert';

import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/group_information/group_borrower_search.dart';

class BorrowerRepository {
  static final _singleton = BorrowerRepository();
  static BorrowerRepository get instance => _singleton;

  final APIManager _apiManager;

  BorrowerRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<List<Customer>> getGroupCustomers() async {
    AppResponse response =
        await _apiManager.get(APIEndpoints.getGroupCustomers);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body['responseData'] as List;
    return raw
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GroupBorrowerSearchResponse> getCustomerByRim(int rim) async {
    final payload = BaseRequest.baseRequest({
      "PartyId": rim,
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
}
