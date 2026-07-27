import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart" show visibleForTesting;
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Repository responsible for customer-related data operations.
///
/// Provides functionality for retrieving, searching, and managing
/// customer information used across the application.
class CustomerRepository {
  /// Creates a [CustomerRepository] instance.
  ///
  /// If no [apiManager] is provided, a default [APIManager] instance
  /// is used.
  CustomerRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static CustomerRepository _singleton = CustomerRepository();

  /// Returns the singleton instance of [CustomerRepository].
  static CustomerRepository get instance => _singleton;

  final APIManager _apiManager;

  /// Returns the current repository instance for testing purposes.
  @visibleForTesting
  static CustomerRepository get debugReplaceInstance => _singleton;

  /// Replaces the singleton repository instance during testing.
  @visibleForTesting
  static set debugReplaceInstance(CustomerRepository fake) {
    _singleton = fake;
  }

  /// Retrieves application details for the specified application
  /// reference number.
  ///
  /// Returns an [ApplicationDetails] object containing the latest
  /// application information. If no application reference number is
  /// provided, the current application's reference number is used.
  ///
  /// Throws an [ApiException] if the application details cannot be
  /// retrieved.
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
      throw ApiException(
        response.body["baseResponse"]["status"]["statusDescription"],
      );
    }
  }

  /// Generates output forms for the specified application and submits
  /// them to SharePoint.
  ///
  /// Triggers document generation based on the application's current
  /// decision and uploads the generated output forms to the configured
  /// SharePoint location.
  ///
  /// Returns a success message when the operation completes
  /// successfully.
  ///
  /// Throws an [ApiException] if form generation or SharePoint
  /// submission fails.
  Future<String?> generateOutputFormsAndSubmitToSharepoint({
    String? appRefNo,
    String? decision,
  }) async {
    final Map data = BaseRequest.baseRequest(
      {
        "appRefNo": appRefNo ?? Globals.request?.applicationRefNo,
        "decision": decision,
      },
    );

    final AppResponse response = await _apiManager.post(
      APIEndpoints.generateOutputFormsAndSubmitToSharepoint,
      data,
    );
    if (response.status == ResponseStatus.success) {
      return "Success";
    } else {
      throw ApiException(
        response.body["baseResponse"]["status"]["statusDescription"],
      );
    }
  }

  /// Retrieves customer information for the specified RIM number.
  ///
  /// Returns a [Customer] containing the customer's profile and
  /// application-related information associated with the provided RIM.
  ///
  /// If no customer data is found, `null` is returned.
  ///
  /// Throws an [ApiException] if the request fails or the customer
  /// information cannot be retrieved.
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
          } on Object catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        } else {
          throw ApiException(
            response.body["baseResponse"]["status"]["statusDescription"],
          );
        }
      } else {
        throw ApiException(
          response.body["baseResponse"]["status"]["statusDescription"],
        );
      }
      return customer;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Retrieves the list of supported countries.
  ///
  /// Returns a list of [Country] objects retrieved from the backend
  /// service and used throughout the application for country selection
  /// and validation purposes.
  ///
  /// Returns `null` when no country data is available.
  ///
  /// Throws an [ApiException] if the request fails or the response
  /// cannot be processed.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.e("countries fetch failed: $e");
      throw ApiException(e.toString());
    }
  }

  /// Searches for customer details using customer, group, or party
  /// information.
  ///
  /// Returns a [Customer] matching the supplied search criteria,
  /// including customer RIM number, customer name, group ID, or group
  /// name.
  ///
  /// Returns `null` when no matching customer is found.
  ///
  /// Throws an [ApiException] if the search request fails or no customer
  /// data is available.
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
        "FullName": customerName ?? "",
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

  /// Searches for customer details for the credit line workflow.
  ///
  /// Performs a customer lookup using the provided customer and group
  /// information and returns the matching [Customer] profile when
  /// available.
  ///
  /// Unlike the standard customer search, this method does not throw an
  /// exception when no matching customer is found and instead returns
  /// `null`.
  ///
  /// Throws an [ApiException] if the search request fails.
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
          } on Object catch (e) {
            AlertManager().showFailureToast(e.toString());
          }
        }
      }
      return requestCustomer;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Validates whether the specified relationship manager is authorized
  /// for the current customer's sub-segment.
  ///
  /// This validation is typically performed before assigning or updating
  /// relationship manager information to ensure compliance with
  /// sub-segment ownership rules.
  ///
  /// Throws an [ApiException] if the validation fails or the service
  /// returns an error response.
  Future<void> validateSubSegment(String? relationshipMgrUserId) async {
    final Map data = BaseRequest.baseRequest({
      "RelationshipMgrUserId": relationshipMgrUserId,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.validateSubSegment, data);

    try {
      if (response.status == ResponseStatus.success) {
        return;
      } else if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Searches customer profiles using customer, group, or party
  /// information.
  ///
  /// Returns a list of matching [Customer] records based on the provided
  /// search criteria. The service may return either a single customer or
  /// multiple customers, both of which are handled and converted into a
  /// collection of [Customer] objects.
  ///
  /// Search criteria may include:
  /// - Customer ID (Party ID)
  /// - Customer name
  /// - Group ID
  /// - Group name
  ///
  /// Returns an empty list when no matching customers are found.
  ///
  /// Throws an [ApiException] if the search operation fails.
  Future<List<Customer?>> searchCustomerProfile(
    String? customerName,
    String? groupId,
    String? groupName, [
    String? customerId,
  ]) async {
    try {
      final Map data = BaseRequest.baseRequest({
        "PartyId": customerId,
        "FullName": customerName ?? "",
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
        } on Object {
          try {
            resultCustomers
                .add(Customer.fromJson(response.body["responseData"]));
          } on Object {
            rethrow;
          }
        }
      }

      // if (groupName != null) {
      //   // Filter out duplicate customers by group ID
      //   final Map<String?, Customer?> uniqueCustomers = {};
      //   for (final Customer? customer in resultCustomers) {
      //     final groupId = customer?.groups?.id;
      //     if (groupId != null) {
      //       // Keep the first occurrence of each group ID
      //       if (!uniqueCustomers.containsKey(groupId)) {
      //         uniqueCustomers[groupId] = customer;
      //       }
      //     } else {
      //       // If no group ID, keep the customer (use a unique key based on
      //       // customer ID or index)
      //       final uniqueKey = "no_group_${customer?.id ?? customer.hashCode}";
      //       uniqueCustomers[uniqueKey] = customer;
      //     }
      //   }

      //   return uniqueCustomers.values.toList();
      // }
      return resultCustomers;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Saves customer information and related ownership and exception
  /// details for the current application.
  ///
  /// Persists customer profile data, ownership information, and borrower
  /// exception records, and returns the status message received from the
  /// backend service when the save operation succeeds.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i(e.toString());
      throw ApiException(e.toString());
    }
  }

  /// Retrieves ownership information for the specified customer.
  ///
  /// Returns a list of [CustomerOwnerShipInfo] records associated with
  /// the provided customer information identifier. The ownership details
  /// are used to capture and display customer shareholding and ownership
  /// structures.
  ///
  /// Returns an empty list when no ownership information is available.
  ///
  /// Throws an [ApiException] if the request fails or the ownership
  /// information cannot be retrieved.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.e("Customer ownership fetch failed: $e");
      throw ApiException(e.toString());
    }
  }

  /// Retrieves borrower exception information for the specified customer.
  ///
  /// Returns a list of [CustomerException] records associated with the
  /// provided customer information identifier. These records represent
  /// customer-specific exceptions captured as part of the customer
  /// onboarding and assessment process.
  ///
  /// Returns an empty list when no exception records are available.
  ///
  /// Throws an [ApiException] if the request fails or the exception
  /// information cannot be retrieved.
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
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.e("Customer exception fetch failed: $e");
      throw ApiException(e.toString());
    }
  }

  /// Deletes a customer ownership record.
  ///
  /// Removes the ownership information identified by the specified
  /// ownership and customer information identifiers, and returns the
  /// status message from the backend service when the operation
  /// succeeds.
  ///
  /// Throws an [ApiException] if the delete operation fails.
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
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  /// Deletes a customer exception record.
  ///
  /// Removes the exception identified by the specified exception and
  /// customer information identifiers, and returns the status message
  /// received from the backend service when the operation succeeds.
  ///
  /// Throws an [ApiException] if the delete operation fails.
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
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  /// Classifies customers as borrowers and non-borrowers for the current
  /// application.
  ///
  /// Retrieves borrower classification details for the supplied customer
  /// list, updates the application context with borrower and non-borrower
  /// information, and ensures the primary customer is included in the
  /// borrower list.
  ///
  /// The identified primary customer is marked with `isPrimary = true`
  /// and removed from the non-borrower collection if necessary.
  ///
  /// Returns the status message from the backend service when the
  /// operation completes successfully.
  ///
  /// Throws an [ApiException] if the classification request fails.
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
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i(e.toString());
      rethrow;
    }
  }

  /// Retrieves child customer RIMs associated with the current group.
  ///
  /// Returns a list of [Customer] records representing the child
  /// customers linked to the application's group owner. These records
  /// are typically used for group-level customer and borrower
  /// processing.
  ///
  /// Returns `null` when no child RIM information is available.
  ///
  /// Throws an [ApiException] if the request fails or the customer data
  /// cannot be retrieved.
  Future<List<Customer>?> getChildRimsForGroup() async {
    try {
      int? groupOwner;
      //For Sometimes Create Request Screen Group Owner is NULL or Empty.
      if (Globals.request?.groupOwner == null ||
          Globals.request?.groupOwner == 0) {
        final List<Customer> list = Globals.request?.borrowers ?? [];
        if (list.isNotEmpty && list.first.groupOwner != null) {
          groupOwner = list.first.groupOwner;
        }
      } else {
        groupOwner = Globals.request?.groupOwner;
      }

      final Map data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
        "groupOwner": groupOwner,
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.e("countries fetch failed: $e");
      throw ApiException(e.toString());
    }
  }

  /// Searches customer information using the Party Inquiry service.
  ///
  /// Retrieves customer details based on the supplied customer and group
  /// criteria and maps the Party Inquiry response to a [Customer]
  /// object. This method is specifically used by the Customer
  /// Information module and relies on the Party Inquiry API response
  /// structure.
  ///
  /// Returns the matching [Customer] when found; otherwise returns
  /// `null`.
  ///
  /// Throws an [ApiException] if the Party Inquiry request fails.
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
          } on Object catch (e) {
            logger.e(e.toString());
          }
        }
      } else if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }

      return requestCustomer;
    } on Object {
      rethrow;
    }
  }

  /// Builds the request payload for the Party Inquiry customer search
  /// service.
  ///
  /// Populates the payload with the provided customer and group search
  /// criteria and produces the request structure expected by the Party
  /// Inquiry API. Only non-empty search parameters are included in the
  /// generated payload.
  ///
  /// Supported search criteria include:
  /// - Customer RIM number (`PartyId`)
  /// - Customer name
  /// - Group ID
  /// - Group name
  ///
  /// Returns the formatted request payload ready for submission to the
  /// Party Inquiry service.
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
