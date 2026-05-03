import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart" show visibleForTesting;
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";

class CustomerRepository {
  CustomerRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static CustomerRepository _singleton = CustomerRepository();
  static CustomerRepository get instance => _singleton;

  final APIManager _apiManager;

  @visibleForTesting
  static set debugReplaceInstance(CustomerRepository fake) {
    _singleton = fake;
  }

  Future<ApplicationDetails?> getApplicationDetails({String? appRefNo}) async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": appRefNo ?? Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getApplicationDetails, data);
    if (response.status == ResponseStatus.success) {
      return ApplicationDetails.fromJson(
        response.body["responseData"],
      );
    } else {
      throw response.body["baseResponse"]["status"]["statusDescription"];
    }
  }

  Future<Customer?> getCustomerInformationByRim(int? customerRimNo) async {
    Customer? customer;
    try {
      final Map data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
        "rimNo": customerRimNo,
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getCustomerInformationByRim,
        data,
      );

      if (response.status == ResponseStatus.success) {
        if (response.body["responseData"] != null) {
          try {
            customer = Customer.fromJson(response.body["responseData"]);
          } catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        } else {
          throw response.body["baseResponse"]["status"]["statusDescription"];
        }
      } else {
        throw response.body["baseResponse"]["status"]["statusDescription"];
      }
      return customer;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Country>?> getCountries() async {
    try {
      final Map data = BaseRequest.baseRequest({});
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getCountries, data);

      if (response.status == ResponseStatus.success &&
          response.body["responseData"] != null) {
        final List<dynamic> res = response.body["responseData"];
        return res.map((item) => Country.fromJson(item)).toList();
      } else {
        logger.i("countries--: ${response.message}");
        throw response.message;
      }
    } catch (e) {
      logger.e("countries fetch failed: $e");
      throw e.toString();
    }
  }

  Future<Customer?> searchUserDetails(
    String? customerRimNo,
    String? customerName,
    String? groupId,
    String? groupName,
  ) async {
    Customer? requestCustomer;
    try {
      final Map data = BaseRequest.baseRequest({
        "PartyId": int.tryParse(customerRimNo ?? ""),
        "FullName": customerName ?? " ",
        "GroupId": groupId,
        "GroupName": groupName,
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

  Future<Customer?> searchUserDetailsForCL(
    String? customerRimNo,
    String? customerName,
    String? groupId,
    String? groupName,
  ) async {
    Customer? requestCustomer;
    try {
      final Map data = BaseRequest.baseRequest({
        "PartyId": int.tryParse(customerRimNo ?? ""),
        "FullName": customerName ?? " ",
        "GroupId": groupId,
        "GroupName": groupName,
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
        }
      }
      return requestCustomer;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> validateSubSegment(String? relationshipMgrIdent) async {
    final Map data = BaseRequest.baseRequest({
      "RelationshipMgrIdent": relationshipMgrIdent,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.validateSubSegment, data);

    try {
      if (response.status == ResponseStatus.success) {
        return;
      } else if (response.status == ResponseStatus.error) {
        throw response.message;
      }
    } catch (e) {
      throw e.toString();
    }
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
        "FullName": customerName ?? " ",
        "GroupId": int.tryParse(groupId ?? ""),
        "GroupName": groupName ?? "",
      });
      final List<Customer?> resultCustomers = [];
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getCustomerProfile, data);
      if (response.status == ResponseStatus.success) {
        try {
          for (final element in (response.body["responseData"] as List)) {
            resultCustomers.add(Customer.fromJson(element));
          }
        } catch (e) {
          try {
            resultCustomers
                .add(Customer.fromJson(response.body["responseData"]));
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

  // Method from main: saveUserDetails
  Future<String?> saveUserDetails(
    Customer? customerInformation,
    List<CustomerOwnerShipInfo>? customerOwnerShipInfo,
    List<CustomerException>? customerException,
  ) async {
    try {
      final Map data = BaseRequest.baseRequest({
        "customerInfo": customerInformation?.toSaveJson(),
        "borrowerExcption": customerException?.map((e) => e.toJson()).toList(),
        "customerOwnershipInfo":
            customerOwnerShipInfo?.map((e) => e.toJson()).toList(),
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.saveCustomerInformation, data);

      if (response.status == ResponseStatus.success) {
        return response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      logger.i(e.toString());
      throw e.toString();
    }
  }

  Future<List<CustomerOwnerShipInfo>?> getCustomerInformationByRimOwnership(
    int? customerRimNo,
  ) async {
    try {
      final Map data = BaseRequest.baseRequest({"custInfoId": customerRimNo});
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getCustomerInformationByRimOwnership,
        data,
      );

      if (response.status == ResponseStatus.success &&
          response.body["responseData"] != null) {
        final List<dynamic>? res = response.body["responseData"];
        return (res ?? [])
            .map((item) => CustomerOwnerShipInfo.fromJson(item))
            .toList();
      } else {
        logger.i("Customer ownership fetch failed: ${response.message}");
        throw response.message;
      }
    } catch (e) {
      logger.e("Customer ownership fetch failed: $e");
      throw e.toString();
    }
  }

  Future<List<CustomerException>?> getCustomerInformationByRimException(
    int? customerRimNo,
  ) async {
    try {
      final Map data = BaseRequest.baseRequest({"custInfoId": customerRimNo});
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getCustomerInformationByRimException,
        data,
      );
      if (response.status == ResponseStatus.success &&
          response.body["responseData"] != null) {
        final List<dynamic>? res = response.body["responseData"];
        return (res ?? [])
            .map((item) => CustomerException.fromJson(item))
            .toList();
      } else {
        logger.i("Customer exception fetch failed: ${response.message}");
        throw response.message;
      }
    } catch (e) {
      logger.e("Customer exception fetch failed: $e");
      throw e.toString();
    }
  }

  Future<String> deleteOwnership(int? custOwnerId, int? customerRimNo) async {
    try {
      final Map data = BaseRequest.baseRequest(
        {"custOwnershipId": custOwnerId, "custInfoId": customerRimNo},
      );

      final AppResponse response =
          await _apiManager.post(APIEndpoints.deleteOwnership, data);

      if (response.status == ResponseStatus.success) {
        return response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  Future<String> deleteException(int? exceptionId, int? customerRimNo) async {
    try {
      final Map data = BaseRequest.baseRequest(
        {"exceptionId": exceptionId, "custInfoId": customerRimNo},
      );

      final AppResponse response =
          await _apiManager.post(APIEndpoints.deleteException, data);

      if (response.status == ResponseStatus.success) {
        return response.message =
            response.body["baseResponse"]["status"]["statusDescription"];
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  Future<String> getBorrowerCustomers(
    List<Customer?> customerList,
    Customer primaryCustomer,
  ) async {
    try {
      final Map data = BaseRequest.baseRequest({
        "partyIds":
            customerList.map((user) => int.tryParse(user?.id ?? "")).toList(),
      });
      final List<Customer> borrowers = [];
      final List<Customer> nonBorrowers = [];
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getBorrowerNonBorrower, data);

      if (response.status == ResponseStatus.success) {
        (response.body["responseData"]["borrowers"] as List).map(
          (user) {
            // borrowers.add(
            customerList.map((customer) {
              if (customer?.id == user.toString()) {
                borrowers.add(customer!);
              }
            }).toList();
          },
        ).toList();
        (response.body["responseData"]["nonBorrowers"] as List).map(
          (user) {
            customerList.map((customer) {
              if (customer?.id == user.toString()) {
                nonBorrowers.add(customer!);
              }
            }).toList();
          },
        ).toList();
        Globals.request?.nonBorrowers = nonBorrowers;
        Globals.request?.borrowers = borrowers;
        Globals.request?.fiCustomerListCountry = customerList;

        //filter out primary customer to be in borrower list
        for (final Customer borrower in Globals.request!.borrowers!) {
          if (borrower.customerRimNo == primaryCustomer.customerRimNo) {
            borrower.isPrimary = true;
          }
        }
        for (final Customer borrower in Globals.request!.nonBorrowers!) {
          if (borrower.customerRimNo == primaryCustomer.customerRimNo) {
            borrower.isPrimary = true;
            Globals.request!.borrowers!.add(borrower);
          }
        }
        Globals.request?.nonBorrowers!.removeWhere((Customer customer) {
          return customer.customerRimNo == primaryCustomer.customerRimNo;
        });
        return response.message;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  Future<List<Customer>?> getChildRimsForGroup() async {
    try {
      final Map data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
        "groupOwner": Globals.request?.groupOwner,
      });
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getChildRimsForGroup, data);

      if (response.status == ResponseStatus.success &&
          response.body["responseData"] != null) {
        final List<dynamic> res = response.body["responseData"];
        return res
            .map((item) => Customer.fromJsonGetChildRimsForGroup(item))
            .toList();
      } else {
        logger.i("countries--: ${response.message}");
        throw response.message;
      }
    } catch (e) {
      logger.e("countries fetch failed: $e");
      throw e.toString();
    }
  }

// Do not delete or change because its using for customer Information
  Future<Customer?> searchUserDetailsPartyInqOnly(
    String customerRimNo,
    String customerName,
    String groupId,
    String groupName,
  ) async {
    Customer? requestCustomer;
    try {
      final AppResponse response = await _apiManager.post(
        APIEndpoints.searchPartyInq,
        getPayload(customerRimNo, customerName, groupId, groupName),
      );
      if (response.status == ResponseStatus.success) {
        if (response.body["partyInqOwnershipDTO"]["PartyInqRs"]["PartyRec"] !=
            null) {
          try {
            requestCustomer = Customer.fromJson(
              response.body["partyInqOwnershipDTO"]["PartyInqRs"]["PartyRec"],
            );
          } catch (e) {
            logger.e(e.toString());
          }
        }
      } else if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      return requestCustomer;
    } catch (e) {
      rethrow;
    }
  }

  Map getPayload(
    String? customerRimNo,
    String? customerName,
    String? groupId,
    String? groupName,
  ) {
    final Map<String, dynamic> payload = {
      "PartyInqRq": {
        "RqUID": const Uuid().v4(),
        "MsgRqHdr": {
          "SvcIdent": {
            "SvcProviderName": "WCAS",
            "SvcProviderId": "71",
            "SvcName": "PARTYINQ-GETCUSTOMERPROFILE",
          },
        },
        "PartySel": {},
      },
    };

    final partySel = <String, dynamic>{};

    if ((customerRimNo ?? "").isNotEmpty) {
      partySel["PartyKeys"] = {"PartyId": customerRimNo};
    }
    if ((customerName ?? "").isNotEmpty) {
      partySel["FullName"] = customerName;
    }
    if ((groupId ?? "").isNotEmpty || (groupName ?? "").isNotEmpty) {
      partySel["GroupKeys"] = {};
      if ((groupId ?? "").isNotEmpty) {
        partySel["GroupKeys"]["GroupId"] = groupId;
      }
      if ((groupName ?? "").isNotEmpty) {
        partySel["GroupKeys"]["groupName"] = groupName;
      }
    }

    payload["PartyInqRq"]["PartySel"] = partySel;

    return payload;
  }
}
