import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'package:wcas_frontend/repositories/dashboard_repository.dart';
import 'state.dart';

class ClosedRequestsViewModel extends Cubit<ClosedRequestsState> {
  ClosedRequestsViewModel()
      : super(ClosedRequestsState(loaderStatus: LoadingStatus.loading));
  late DashboardRepository repository;
  List<Request?> closedRequestFilteredData = [];
  List<Request> requestTypeFilter = [];
  List<Reference>? requestStatusFilter;
  List<Reference> itemsRequestStatusList = [];
  String? reqRefNoFilter;
  String? applicantRimFilter;
  String? applicantNameFilter;
  List<Request> closedRequests = [];
  Map<String, List<Reference>> referenceData = {};
  String pageHeading = "dashboard.closedRequests.title".tr();

  /// Initializes the `ClosedRequestsViewModel`.
  ///
  /// This method logs the initialization process, sets the [repository]
  /// to an instance of [DashboardRepository], and then asynchronously
  /// fetches the request work list by calling [getRequestWorkList].
  ///
  /// It should be called when the view model is first created to ensure
  /// that all necessary data is loaded and ready for use.

  Future<void> init(BuildContext context,
      {required ApplicationFilterType applicationType}) async {
    logger.i('initialising ClosedRequestsViewModel');
    repository = DashboardRepository.instance;
    getHeading(applicationType);
    await loadReferenceData();
    await getRequestWorkList(applicationType);
  }

  void getHeading(ApplicationFilterType applicationType) {
    pageHeading = applicationTypes[applicationType] ?? "";
  }

  Map<ApplicationFilterType, String> applicationTypes = {
    ApplicationFilterType.applicationOverdue:
        "dashboard.home.applicationOverdue".tr(),
    ApplicationFilterType.dueForReview: "dashboard.home.dueforReview".tr(),
    ApplicationFilterType.recentApplication:
        "dashboard.home.myRecentApplications".tr(),
    ApplicationFilterType.applicationSegment:
        "dashboard.home.applicationwithinSegment".tr(),
    ApplicationFilterType.closedRequest: "dashboard.closedRequests.title".tr(),
  };

  /// Fetches the list of closed request work items from the repository.
  ///
  /// This method attempts to retrieve request details using the [repository]'s
  /// `getRequestDetailsWorkList` method. If data is successfully retrieved,
  /// it updates both [closedRequests] and [closedRequestFilteredData],
  /// and emits a new state with a loader status of either [LoadingStatus.loaded]
  /// or [LoadingStatus.empty] depending on whether the list is populated.
  ///
  /// If an error occurs during the fetch, it logs the error, shows a failure toast,
  /// and emits a state with [LoadingStatus.error].

  Future<void> getRequestWorkList(ApplicationFilterType applicationType) async {
    String key;
    switch (applicationType) {
      case ApplicationFilterType.applicationOverdue:
        key = 'applicationsOverdue';
        break;
      case ApplicationFilterType.dueForReview:
        key = 'applicationsDueForReview';
        break;
      case ApplicationFilterType.recentApplication:
        key = 'recentApplications';
        break;
      case ApplicationFilterType.applicationSegment:
        key = 'applicationSegment';
        break;
      case ApplicationFilterType.closedRequest:
        key = 'completed';
        break;
    }
    try {
      final closedRequests =
          await repository.getClosedRequestDetailsWorkList(key);
      logger.i("Closed Requests: $closedRequests");

      closedRequestFilteredData = closedRequests!;
      itemsRequestStatusList.clear();

      for (final data in closedRequests) {
        itemsRequestStatusList.add(
          Reference(name: data.requestStatus?.name ?? ''),
        );
      }

      emit(state.copyWith(
        loaderStatus: closedRequestFilteredData.isNotEmpty
            ? LoadingStatus.loaded
            : LoadingStatus.empty,
      ));
    } catch (e, stackTrace) {
      logger.e('Error getting reference data types: $e',
          stackTrace: stackTrace);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.transactionType
      ]);
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  List<Reference>? getApplicationType() {
    List<Reference>? applicationType =
        referenceData[ReferenceDataKeys.applicationType];

    return applicationType;
  }

  List<Reference>? getTransactionType() {
    List<Reference>? transactionType =
        referenceData[ReferenceDataKeys.transactionType];

    return transactionType;
  }

  /// Filters the closed request data based on the provided [value].
  ///
  /// This method checks if the [value] is contained in any of the following fields:
  /// - Application Reference Number
  /// - Application Type Name
  /// - Customer RIM Number
  /// - Customer Name
  /// - Request Status
  ///
  /// If a match is found, the corresponding filter variable is updated and the
  /// item is included in the filtered list. After filtering, the state is updated
  /// with [LoadingStatus.empty] to indicate that the table should refresh
  Future<void> onFilter(
      {required String value,
      List<Request>? selectedTypes,
      required FilterType filterType}) async {
    requestTypeFilter = [];
    closedRequestFilteredData = closedRequests.where((data) {
      bool refNoMatch = false;
      bool typeMatch = false;
      bool rimMatch = false;
      bool nameMatch = false;
      if (filterType == FilterType.applicantName) {
        nameMatch = (data.customerName ?? "").contains(value);
        applicantNameFilter = value;
      } else if (filterType == FilterType.referenceType) {
        for (Request? selectedType in (selectedTypes ?? [])) {
          if (data.applicationType?.name ==
              selectedType?.applicationType?.name) {
            requestTypeFilter.add(selectedType!);
            typeMatch = true;
          }
        }
      } else if (filterType == FilterType.applicantRim) {
        rimMatch = (data.customerRimNo?.toString() ?? "").contains(value);
        applicantRimFilter = value;
      } else if (filterType == FilterType.referenceNumber) {
        refNoMatch = (data.applicationRefNo ?? "").contains(value);
        reqRefNoFilter = value;
      }

      return refNoMatch || typeMatch || rimMatch || nameMatch;
    }).toList();
    if (filterType == FilterType.referenceType) {
      if (selectedTypes == [] || (selectedTypes ?? []).isEmpty) {
        requestTypeFilter = [];
        closedRequestFilteredData = closedRequests;
      }
    }
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }
}
