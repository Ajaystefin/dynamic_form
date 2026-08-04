import "dart:convert";
import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/ccsys/ccsys_approval.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Repository responsible for CCSYS-related data retrieval and
/// persistence operations.
///
/// Provides functionality for managing CCSYS application data,
/// workflow interactions, and integration with CCSYS backend services.
class CcsysRepository {
  /// Creates a [CcsysRepository] instance.
  ///
  /// If no [apiManager] is provided, a default [APIManager] instance
  /// is used.
  CcsysRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager();

  static final _singleton = CcsysRepository();

  /// Returns the singleton instance of [CcsysRepository].
  static CcsysRepository get instance => _singleton;

  final APIManager _apiManager;

  /// Retrieves CCSYS application details for the specified application.
  ///
  /// Returns an [ApplicationDetails] object containing the application
  /// information associated with the provided application reference
  /// number. If no reference number is supplied, the current application
  /// reference number from the application context is used.
  ///
  /// Throws an [ApiException] if the application details cannot be
  /// retrieved.
  Future<ApplicationDetails?> getApplicationDetails({String? appRefNo}) async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getApplicationDetailsCCSYS, data);
    if (response.status == ResponseStatus.success) {
      return ApplicationDetails.fromJson(
        response.body["responseData"]?["applicationInfo"],
      );
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the most recently approved CCSYS application for the
  /// current customer or group.
  ///
  /// Returns an [ApplicationDetails] object containing the application
  /// information from the latest approved CCSYS application. This data is
  /// commonly used to reference or prepopulate details from the previous
  /// approved application.
  ///
  /// Returns `null` when no approved application information is
  /// available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<ApplicationDetails?> getLastApprovedApplication() async {
    final Map data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getCcsysLastApprovedApplicationDetails,
      data,
    );
    if (response.status == ResponseStatus.success) {
      if (response.body["responseData"]["applicationInfo"] != null) {
        return ApplicationDetails.fromJson(
          response.body["responseData"]["applicationInfo"],
        );
      } else {
        return response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      }
    } else {
      throw ApiException(
        response.body["baseResponse"]["status"]["statusDescription"],
      );
    }
  }

  /// Saves CCSYS application information.
  ///
  /// Persists the supplied application details and returns the
  /// application reference number generated or updated by the backend
  /// service.
  ///
  /// Throws an [ApiException] if the save operation fails.
  Future<String> saveApplicationInformation(
    ApplicationDetails? applicationDetails,
  ) async {
    final Map data = BaseRequest.baseRequest(
      applicationDetails?.toSaveApplicationJsonCCSYS(),
    );
    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveCcsysApplicationInformation,
      data,
    );
    if (response.status == ResponseStatus.success) {
      return response.body["responseData"]["applicationRefNo"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the list of available currency codes.
  ///
  /// Returns a collection of [Reference] objects where:
  /// - [Reference.name] contains the currency ISO code.
  /// - [Reference.reference4] contains the currency description.
  ///
  /// Invalid or incomplete currency records are ignored.
  ///
  /// Returns an empty list when no valid currency data is available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Reference>> getCurrencyCodes() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCurrencyRateList, data);

    if (response.status != ResponseStatus.success) {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }

    final dynamic currencyList = response.body["responseData"];

    // Ensure it's a list
    if (currencyList is! List) {
      return <Reference>[];
    }

    // Map isoCode -> name, description -> reference4
    return currencyList
        .whereType<Map<String, dynamic>>() // keep only proper map entries
        .map((e) {
          final String iso = e["isoCode"];
          final String desc = e["description"];

          if (iso.trim().isNotEmpty) {
            return Reference(
              name: iso.trim(),
              reference4: desc.trim(),
            );
          }
          return null; // skip invalid rows
        })
        .whereType<Reference>()
        .toList();
  }

  /// Searches CCSYS customer profiles using customer and group search
  /// criteria.
  ///
  /// Returns a list of matching [Customer] records retrieved from the
  /// CCSYS customer profile service. The response supports both
  /// single-customer and multiple-customer payload formats.
  ///
  /// When a group name is provided, duplicate customers belonging to the
  /// same group are removed, ensuring only one customer entry is returned
  /// per group.
  ///
  /// Returns an empty list when no matching customers are found.
  ///
  /// Throws an [ApiException] if the search request fails or the response
  /// cannot be processed.
  Future<List<Customer?>> searchCustomerProfile(
    String? customerName,
    String? groupId,
    String? groupName, [
    String? customerId,
  ]) async {
    try {
      final Map data = BaseRequest.baseRequest({
        "PartyId": customerId,
        "customerName": customerName ?? " ",
        "GroupId": int.tryParse(groupId ?? ""),
        "GroupName": groupName ?? "",
      });
      final List<Customer?> resultCustomers = [];
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getCcsysCustomerProfile, data);
      if (response.status == ResponseStatus.success) {
        try {
          for (final element in (response.body["responseData"] as List)) {
            resultCustomers.add(Customer.fromJsonCustomerCCSYS(element));
          }
        } on Object {
          try {
            resultCustomers.add(
              Customer.fromJsonCustomerCCSYS(response.body["responseData"]),
            );
          } on Object {
            rethrow;
          }
        }
      }

      if (groupName != null) {
        // Filter out duplicate customers by group ID
        final Map<String?, Customer?> uniqueCustomers = {};
        for (final Customer? customer in resultCustomers) {
          final groupId = customer?.groups?.id;
          if (groupId != null) {
            // Keep the first occurrence of each group ID
            if (!uniqueCustomers.containsKey(groupId)) {
              uniqueCustomers[groupId] = customer;
            }
          } else {
            // If no group ID, keep the customer (use a unique key based on
            // customer ID or index)
            final uniqueKey = "no_group_${customer?.id ?? customer.hashCode}";
            uniqueCustomers[uniqueKey] = customer;
          }
        }

        return uniqueCustomers.values.toList();
      }
      return resultCustomers;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Retrieves customer information for the current CCSYS application.
  ///
  /// Loads the customer profile associated with the application's
  /// reference number and maps the response into a
  /// [CcsysCustomerInformation] object. Numeric financial fields are
  /// normalized before deserialization to ensure compatibility with the
  /// customer information model.
  ///
  /// Returns the customer information if available; otherwise returns
  /// `null`.
  ///
  /// Throws an [ApiException] if the request fails or the response
  /// cannot be processed.
  Future<CcsysCustomerInformation?> getCustomerInformationCCSYS() async {
    CcsysCustomerInformation? customer;
    try {
      final Map data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getCustomerInformationCCSYS,
        data,
        plainResponse: true,
      );

      if (response.status == ResponseStatus.success) {
        final String modifiedJson = response.body.replaceAllMapped(
          RegExp(
            r'("capital"|"turnover"|"networthPartnerShareholderAed")\s*:\s*([\d.]+)',
          ),
          (match) => '${match.group(1)}:"${match.group(2)}"',
        );
        final dynamic data = jsonDecode(modifiedJson)["responseData"];
        customer = CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(data);
        // if (response.body["responseData"] != null) {
        //   try {
        //     customer = CcsysCustomerInformation.fromJsonGetCCSYSCustomerInfo(
        //         response.body["responseData"]);
        //   } on Object catch (e) {
        //     AlertManager().showFailureToast(e.toString());
        //   }
        // }
      }
      return customer;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Searches for a CCSYS customer using the provided customer
  /// identification details.
  ///
  /// Performs a customer profile lookup in the CCSYS system using the
  /// customer's RIM number and/or customer name. Returns the matching
  /// customer profile when a result is found.
  ///
  /// Returns `null` when no customer details are available.
  ///
  /// Throws an [ApiException] if no matching customer is found or if the
  /// search request fails.
  Future<Customer?> searchUserDetails(
    String? customerRimNo,
    String? customerName,
  ) async {
    Customer? requestCustomer;
    try {
      final Map data = BaseRequest.baseRequest({
        "rimNo": int.tryParse(customerRimNo ?? ""),
        "customerName": customerName ?? " ",
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getCcsysCustomerProfile, data);
      if (response.status == ResponseStatus.success) {
        if (response.body["responseData"] != null &&
            response.body["responseData"].isNotEmpty) {
          try {
            requestCustomer =
                Customer.fromJsonCustomerCCSYS(response.body["responseData"]);
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

  /// Saves CCSYS application information and returns the generated
  /// application reference number.
  ///
  /// Creates or updates the application using the supplied customer,
  /// region, branch, and workflow details. On successful completion, the
  /// newly created or updated application reference number is returned.
  ///
  /// Throws an [ApiException] if the save operation fails or the
  /// application reference number is not returned by the service.
  Future<String> saveApplicationInformationd({
    required String region,
    required String branch,
    required int rimNo,
    required String customerName,

    // Optional: include if your backend requires these fixed fields.
    String requestType = "APN",
    String businessSegment = "Corporate",
    String subType = "CS",
    int enabledForView = 0,

    // Optional: include if needed; otherwise omit.
    String? caDateIsoPlus4, // e.g. "2025-12-12T00:00:00.000+04:00"
    String? lastApprovedAppRefNum,
    String? lastApprovedAppDate,
    String? appRefNo,
    String? instanceIdentifier,
  }) async {
    try {
      // Build requestData (only required editable fields + fixed values)
      final requestData = <String, dynamic>{
        "appRefNo": appRefNo,
        "instanceIdentifier": instanceIdentifier,
        if (caDateIsoPlus4 != null) "caDate": caDateIsoPlus4,
        "requestType": requestType,
        "businessSegment": businessSegment,
        "region": region,
        "branch": branch,
        "subType": subType,
        "lastApprovedAppRefNum": lastApprovedAppRefNum,
        "lastApprovedAppDate": lastApprovedAppDate,
        "rimNo": rimNo,
        "enabledForView": enabledForView,
        "customerName": customerName,
      };

      // Wrap with baseRequest via your existing helper
      final body = BaseRequest.baseRequest(requestData);

      // POST
      final response = await _apiManager.post(
        APIEndpoints
            .saveCcsysApplicationInformation, // http://localhost:8080/wcas/ccsys/requestInformation/saveApplicationInformation
        body,
      );

      // Success check
      if (response.status == ResponseStatus.success) {
        final appRefNoResp =
            response.body?["responseData"]?["applicationRefNo"]?.toString();

        if ((appRefNoResp ?? "").isEmpty) {
          throw ApiException("common.somethingWentWrong".tr());
        }
        return appRefNoResp!;
      }

      // Backend failure (provide user-friendly message if available)
      //throw Exception(response.message);
      throw ApiException(response.message);
    } on Object catch (e) {
      // Surface errors via your AlertManager and rethrow for upstream handling
      AlertManager().showFailureToast(e.toString());
      rethrow;
    }
  }

  /// Retrieves details from the most recently approved CCSYS application
  /// for the specified customer.
  ///
  /// Returns a map containing the last approved application's
  /// information and associated CCSYS customer details. This data is
  /// typically used to prepopulate fields or reference information from
  /// the customer's previously approved application.
  ///
  /// Returned keys:
  /// - `applicationInfo`: Last approved application details.
  /// - `ccsysCustomer`: Associated CCSYS customer information.
  ///
  /// Throws an [ApiException] if the request fails or the response
  /// format is invalid.
  Future<Map<String, dynamic>> getLastApprovedApplicationDetails({
    required int rimNo,
  }) async {
    try {
      // Build requestData with only rimNo
      final requestData = <String, dynamic>{"rimNo": rimNo};

      // Wrap once into { baseRequest, requestData }
      final body = BaseRequest.baseRequest(requestData);

      // POST
      final response = await _apiManager.post(
        APIEndpoints.getCcsysLastApprovedApplicationDetails,
        body,
      );

      // Transport-level OK?
      if (response.status != ResponseStatus.success) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }

      final respBody = response.body ?? {};
      final respData = respBody["responseData"];

      // Validate shape
      if (respData is! Map<String, dynamic>) {
        throw ApiException(
          "common.somethingWentWrong".tr(),
        ); // unexpected payload
      }

      // Extract two blocks
      final applicationInfo = respData["applicationInfo"];
      final ccsysCustomer = respData["ccsysCustomer"];

      // Type guards
      final applicationInfoMap =
          (applicationInfo is Map<String, dynamic>) ? applicationInfo : null;
      final ccsysCustomerMap =
          (ccsysCustomer is Map<String, dynamic>) ? ccsysCustomer : null;

      // Return both; caller decides what to read/use
      return {
        "applicationInfo": applicationInfoMap,
        "ccsysCustomer": ccsysCustomerMap,
      };
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      rethrow;
    }
  }

  /// Saves CCSYS customer information for the current application.
  ///
  /// Persists customer information entered during the CCSYS workflow and
  /// returns the status description provided by the backend service.
  ///
  /// The returned message indicates whether the save operation was
  /// successful or unsuccessful based on the service response.
  ///
  /// Throws an [ApiException] if the request cannot be completed.
  Future<String> saveCustomerInformation(
    CcsysCustomerInformation? customerInformation,
  ) async {
    try {
      final Map data = BaseRequest.baseRequest({
        ...?customerInformation?.toJsonGetCCSYSCustomerInfo(),
      });
      final AppResponse response = await _apiManager.post(
        APIEndpoints.saveCustomerInformationCCSYS,
        data,
      );

      if (response.status == ResponseStatus.success) {
        return response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      } else {
        return response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      }
    } on Object catch (e) {
      logger.i(e.toString());
      throw ApiException(e.toString());
    }
  }

  /// Submits a CCSYS application for workflow processing.
  ///
  /// Sends the provided approval decision and workflow details to the
  /// CCSYS workflow engine for processing. The submission may represent
  /// actions such as recommendation, approval, rejection, or routing to
  /// another stage, depending on the values contained in
  /// [ccsysApproval].
  ///
  /// Throws an [ApiException] if the submission fails.
  Future<void> submitApplication(CCSYSApproval? ccsysApproval) async {
    final Map data = BaseRequest.baseRequest({...?ccsysApproval?.toJson()});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.submitApplicationCCSYS, data);
    if (response.status == ResponseStatus.success) {
      // AlertManager().showSuccessToast("Application Recommended
      // Successfully!");
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the most recently assigned role for the current CCSYS
  /// application.
  ///
  /// Returns a [Role] representing the last role to which the
  /// application was assigned in the CCSYS workflow. This information is
  /// typically used to determine the previous workflow owner or routing
  /// context.
  ///
  /// Returns `null` when no assignment history is available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<Role?> getLastAssignedRole() async {
    Role? lastRole;
    try {
      final Map data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getLastAssignedRoleCCSYS, data);
      if (response.status == ResponseStatus.success) {
        if (response.body["responseData"] != null &&
            response.body["responseData"].isNotEmpty) {
          try {
            lastRole = Role.fromJsonCCSYS(response.body["responseData"]);
          } on Object catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        }
      }
      return lastRole;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Retrieves users grouped by the specified role codes.
  ///
  /// Accepts a list of role codes and returns the corresponding [Role]
  /// objects populated with the users assigned to each role. The role
  /// hierarchy and associated user information are preserved as returned
  /// by the backend service.
  ///
  /// Returns an empty list when no matching roles or users are found.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Role>> getUsersByRolesList(List<String> roleCodes) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": roleCodes,
        // "segment": Globals.user?.segments?.join(','),
        // "region":  Globals.user?.regions?.join(','),
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getUsersByRoles,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          return responseData
              .map(
                (group) =>
                    Role.fromJsonUsersByRoles(group as Map<String, dynamic>),
              )
              .toList();
        }
        return <Role>[];
      }

      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
      return <Role>[];
    } on Object {
      rethrow;
    }
  }

  /// Retrieves users grouped by the specified role codes.
  ///
  /// Accepts a comma-separated list of role codes and returns the
  /// corresponding [Role] objects, including the users associated with
  /// each role. The response preserves the role-to-user relationship
  /// returned by the backend service.
  ///
  /// Returns an empty list when no roles or users are found.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Role>> getUsersByRoles(String rolesCsv) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": rolesCsv, // <-- CSV string
      });
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getUsersByRoles,
        json.encode(data),
      );
      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          return responseData
              .map(
                (group) =>
                    Role.fromJsonUsersByRoles(group as Map<String, dynamic>),
              )
              .toList();
        }
        return <Role>[];

        // final responseData = response.body["responseData"];
        // if (responseData != null && responseData is List) {
        //   final List<Role> users = [];
        //   for (var role in responseData) {
        //     final userDetails =
        //         role["userDetails"] as List<dynamic>? ?? <dynamic>[];
        //     users.addAll(
        //         userDetails.map((e) =>
        // Role.fromJsonUsersByRoles(e)).toList());
        //   }
        //   return users;
        // }
        // return [];
      }
      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
      return [];
    } on Object {
      rethrow;
    }
  }
}
