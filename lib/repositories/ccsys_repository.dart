import "dart:convert";

import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/ccsys/ccsys_approval.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";
import "package:wcas_frontend/models/request/customer.dart";

class CcsysRepository {
  // Constructor for dependency injection (used in tests)
  CcsysRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager.instance;
  static final _singleton = CcsysRepository();
  static CcsysRepository get instance => _singleton;

  // ignore: unused_field
  final APIManager _apiManager;

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
      throw response.message;
    }
  }

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
      throw Exception(
        response.body["baseResponse"]["status"]["statusDescription"],
      );
    }
  }

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
      throw response.message;
    }
  }

  Future<List<Reference>> getCurrencyCodes() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCurrencyCode, data);

    if (response.status != ResponseStatus.success) {
      throw response.message;
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
        } catch (e) {
          try {
            resultCustomers.add(
              Customer.fromJsonCustomerCCSYS(response.body["responseData"]),
            );
          } catch (e) {
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
    } catch (e) {
      throw e.toString();
    }
  }

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
        //   } catch (e) {
        //     AlertManager().showFailureToast(e.toString());
        //   }
        // }
      }
      return customer;
    } catch (e) {
      throw e.toString();
    }
  }

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
          throw "common.somethingWentWrong".tr();
        }
        return appRefNoResp!;
      }

      // Backend failure (provide user-friendly message if available)
      throw response.message;
    } catch (e) {
      // Surface errors via your AlertManager and rethrow for upstream handling
      AlertManager().showFailureToast(e.toString());
      rethrow;
    }
  }

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
        throw response.message;
      }

      final respBody = response.body ?? {};
      final respData = respBody["responseData"];

      // Validate shape
      if (respData is! Map<String, dynamic>) {
        throw "common.somethingWentWrong".tr(); // unexpected payload
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      rethrow;
    }
  }

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
    } catch (e) {
      logger.i(e.toString());
      throw e.toString();
    }
  }

  Future<void> submitApplication(CCSYSApproval? ccsysApproval) async {
    final Map data = BaseRequest.baseRequest({...?ccsysApproval?.toJson()});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.submitApplicationCCSYS, data);
    if (response.status == ResponseStatus.success) {
      // AlertManager().showSuccessToast("Application Recommended
      // Successfully!");
    } else {
      throw response.message;
    }
  }

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
          } catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        }
      }
      return lastRole;
    } catch (e) {
      throw e.toString();
    }
  }

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
        throw response.message;
      }
      return <Role>[];
    } catch (e) {
      rethrow;
    }
  }

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
      if (response.status == ResponseStatus.error) throw response.message;
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
