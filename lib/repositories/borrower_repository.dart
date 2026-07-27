import "dart:convert";
import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/group_borrower_search.dart";

/// Repository responsible for handling borrower-related operations.
///
/// Provides methods to interact with APIs for fetching and managing
/// borrower data, and maintains a singleton instance for shared usage
/// across the application.
class BorrowerRepository {
  BorrowerRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  /// Internal singleton instance of [BorrowerRepository].
  static final _singleton = BorrowerRepository();

  /// Returns the singleton instance of [BorrowerRepository].
  static BorrowerRepository get instance => _singleton;

  /// API manager used to perform network requests.
  final APIManager _apiManager;

  /// Retrieves customer details using the provided RIM number.
  ///
  /// Sends the RIM and business segment information to the backend and parses
  /// the response into a [GroupBorrowerSearchResponse] object.
  /// Returns the customer search response on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final Map<String, dynamic> body = response.body as Map<String, dynamic>;
    return GroupBorrowerSearchResponse.fromJson(body);
  }

  /// Retrieves customer details using a potential RIM number.
  ///
  /// Sends the RIM and business segment information to the backend and attempts
  /// to parse the response into a [Customer] object.
  /// Returns the customer if found, or `null` if no valid data is available.
  /// Shows an error message or throws [ApiException] if the API call fails.
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
          } on Object catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        } else {
          throw ApiException("common.noUserFound".tr());
        }
      } else {
        throw ApiException("common.noUserFound".tr());
      }
      return requestCustomer;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }
}
