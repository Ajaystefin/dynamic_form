import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/state.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class ClosedRequestsViewModel extends SafeCubit<ClosedRequestsState> {
  ClosedRequestsViewModel()
      : super(ClosedRequestsState(loaderStatus: LoadingStatus.loading));
  late DashboardRepository repository;
  List<Request?> closedRequestFilteredData = [];
  List<Request> requestTypeFilter = [];
  List<Request> reqStatusFilter = [];
  List<Reference>? requestStatusFilter;
  List<Reference> itemsRequestStatusList = [];
  String? reqRefNoFilter;
  String? applicantRimFilter;
  String? applicantNameFilter;
  String? requestedByFilter;
  List<Request> closedRequests = [];
  Map<String, List<Reference>> referenceData = {};
  String pageHeading = "dashboard.closedRequests.title".tr();

  bool isCCSYS = false;
  List<Request> worklistData = [];
  List<Request> filteredWorkList = [];

  /// Names from CUSTOM_APPLICATION_TYPE reference data, including hardcoded
  /// exceptions.
  /// CCSYS is always treated as a current type even though it is not in
  /// CUSTOM_APPLICATION_TYPE.
  List<String> customApplicationTypeNames = ["CCSYS"];

  /// Initializes the `ClosedRequestsViewModel`.
  ///
  /// This method logs the initialization process, sets the [repository]
  /// to an instance of [DashboardRepository], and then asynchronously
  /// fetches the request work list by calling [getRequestWorkList].
  ///
  /// It should be called when the view model is first created to ensure
  /// that all necessary data is loaded and ready for use.

  Future<void> init(
    BuildContext context, {
    required ApplicationFilterType applicationType,
  }) async {
    logger.i("initialising ClosedRequestsViewModel");
    repository = DashboardRepository.instance;
    if (applicationType == ApplicationFilterType.ccsys) {
      isCCSYS = true;
      await getWorkList();
      return;
    } else {
      getHeading(applicationType);
      await loadReferenceData();
      await getRequestWorkList(applicationType);
    }
  }

  Future<void> getWorkList() async {
    try {
      worklistData = (await DashboardRepository().getWorkList(
            ageingType: DashboardAgeingType.zeroToSevenDays,
            summaryType: SummaryType.me,
            isCCSYS: true,
            isBarGraph: false,
          )) ??
          [];
      filteredWorkList = worklistData;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  String? getRequestStatusNameById(dynamic id) {
    if (id == null || id is String) return id as String?;
    final entry = ServerConstants.requestStatusId.entries
        .firstWhereOrNull((e) => e.value == id);
    return entry?.key.name;
  }

  Future<void> openApplication(Request request, int? index) async {
    try {
      emit(state.copyWith(appRefIndex: index));
      await repository.openApplication(request);
      emit(state.copyWith(appRefIndex: -1));
    } catch (e) {
      emit(state.copyWith(appRefIndex: -1));
      AlertManager().showFailureToast(e.toString());
    }
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
  /// and emits a new state with a loader status of either
  /// [LoadingStatus.loaded]
  /// or [LoadingStatus.empty] depending on whether the list is populated.
  ///
  /// If an error occurs during the fetch, it logs the error, shows a failure
  /// toast,
  /// and emits a state with [LoadingStatus.error].

  Future<void> getRequestWorkList(ApplicationFilterType applicationType) async {
    String key;
    switch (applicationType) {
      case ApplicationFilterType.applicationOverdue:
        key = "applicationsOverdue";
      case ApplicationFilterType.dueForReview:
        key = "applicationsDueForReview";
      case ApplicationFilterType.recentApplication:
        key = "recentApplications";
      case ApplicationFilterType.applicationSegment:
        key = "pendingWithSegment";
      case ApplicationFilterType.closedRequest:
        key = "completed";
      case ApplicationFilterType.ccsys:
        key = "ccsys";
    }
    try {
      final fetched =
          await repository.getClosedRequestDetailsWorkList(key) ?? [];
      logger.i("Closed Requests: $fetched");

// assign to the FIELD, not a local variable
      closedRequests = fetched;
      closedRequestFilteredData = List<Request>.from(closedRequests);

      itemsRequestStatusList.clear();

      for (final data in closedRequests) {
        itemsRequestStatusList.add(
          Reference(name: data.requestStatus?.name ?? ""),
        );
      }

      emit(
        state.copyWith(
          loaderStatus: closedRequestFilteredData.isNotEmpty
              ? LoadingStatus.loaded
              : LoadingStatus.empty,
        ),
      );
    } catch (e, stackTrace) {
      logger.e(
        "Error getting reference data types: $e",
        stackTrace: stackTrace,
      );
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
        ReferenceDataKeys.transactionType,
        ReferenceDataKeys.applicationTypeCustom,
      ]);

      final List<String> fetchedNames =
          (referenceData[ReferenceDataKeys.applicationTypeCustom] ?? [])
              .map((Reference ref) => ref.name?.trim() ?? "")
              .where((String name) => name.isNotEmpty)
              .toList();
      customApplicationTypeNames =
          {...customApplicationTypeNames, ...fetchedNames}.toList();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  List<Reference>? getApplicationType() {
    final List<Reference>? applicationType =
        referenceData[ReferenceDataKeys.applicationType];

    return applicationType;
  }

  List<Reference>? getTransactionType() {
    final List<Reference>? transactionType =
        referenceData[ReferenceDataKeys.transactionType];

    return transactionType;
  }

  /// Filters the closed request data based on the provided [value].
  ///
  /// This method checks if the [value] is contained in any of the following
  /// fields:
  /// - Application Reference Number
  /// - Application Type Name
  /// - Customer RIM Number
  /// - Customer Name
  /// - Request Status
  ///
  /// If a match is found, the corresponding filter variable is updated and the
  /// item is included in the filtered list. After filtering, the state is
  /// updated
  /// with [LoadingStatus.empty] to indicate that the table should refresh
  Future<void> onFilter({
    required String value,
    required FilterType filterType,
    List<Request>? selectedTypes,
  }) async {
    requestTypeFilter = [];
    reqStatusFilter = [];
    closedRequestFilteredData = closedRequests.where((data) {
      bool refNoMatch = false;
      bool typeMatch = false;
      bool rimMatch = false;
      bool nameMatch = false;
      if (filterType == FilterType.applicantName) {
        nameMatch = (data.customerName ?? "").contains(value);
        applicantNameFilter = value;
      } else if (filterType == FilterType.referenceType) {
        for (final Request? selectedType in (selectedTypes ?? [])) {
          if (data.applicationType?.name ==
              selectedType?.applicationType?.name) {
            requestTypeFilter.add(selectedType!);
            typeMatch = true;
          }
        }
      } else if (filterType == FilterType.requestType) {
        if (selectedTypes == null || selectedTypes.isEmpty) {
          requestTypeFilter = [];
          closedRequestFilteredData = closedRequests;
        } else {
          for (final Request? selectedType in selectedTypes) {
            final String? selectedName = selectedType?.requestType?.name;
            if (selectedName ==
                "dashboard.home.historicalApplicationTypes".tr()) {
              final String? dataName = data.requestType?.name?.trim();
              if (dataName != null &&
                  dataName.isNotEmpty &&
                  !customApplicationTypeNames.contains(dataName)) {
                requestTypeFilter.add(selectedType!);
                typeMatch = true;
              }
            } else {
              if (data.requestType?.name == selectedName) {
                requestTypeFilter.add(selectedType!);
                typeMatch = true;
              }
            }
          }
        }
      } else if (filterType == FilterType.requestStatus) {
        if (selectedTypes == null || selectedTypes.isEmpty) {
          reqStatusFilter = [];
          closedRequestFilteredData = closedRequests;
        } else {
          for (final Request? selectedType in selectedTypes) {
            if (data.requestStatus?.name == selectedType?.requestStatus?.name) {
              reqStatusFilter.add(selectedType!);
              typeMatch = true;
            }
          }
        }
      } else if (filterType == FilterType.applicantRim) {
        rimMatch = (data.customerRimNo?.toString() ?? "").contains(value);
        applicantRimFilter = value;
      } else if (filterType == FilterType.referenceNumber) {
        refNoMatch = (data.applicationRefNo ?? "").contains(value);
        reqRefNoFilter = value;
      } else if (filterType == FilterType.requestBy) {
        nameMatch = (data.requestedBy ?? "").contains(value);
        requestedByFilter = value;
      }

      return refNoMatch || typeMatch || rimMatch || nameMatch;
    }).toList();
    if (filterType == FilterType.referenceType ||
        filterType == FilterType.requestType ||
        filterType == FilterType.requestStatus) {
      if (selectedTypes == null || selectedTypes.isEmpty) {
        requestTypeFilter = [];
        closedRequestFilteredData = closedRequests;
      }
    }
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  //
  /// Filters the closed request data based on the provided [value].
  /// Filters the closed request data based on the provided [value].
  ///
  /// This method checks if the [value] is contained in any of the following
  /// fields:
  /// - Application Reference Number
  /// - Application Type Name
  /// - Customer RIM Number
  /// - Customer Name
  /// - Request Status
  ///
  /// If a match is found, the corresponding filter variable is updated and the
  /// item is included in the filtered list. After filtering, the state is
  /// updated
  /// with [LoadingStatus.empty] to indicate that the table should refresh
  Future<void> onFilterWorklistTable({
    required String value,
    required FilterType filterType,
    List<Request>? selectedTypes,
  }) async {
    requestTypeFilter = [];
    filteredWorkList = worklistData.where((data) {
      bool refNoMatch = false;
      bool typeMatch = false;
      bool rimMatch = false;
      bool nameMatch = false;
      if (filterType == FilterType.applicantName) {
        applicantRimFilter = null;
        requestStatusFilter = null;
        reqRefNoFilter = null;
        nameMatch = (data.customerName ?? "").contains(value);
        applicantNameFilter = value;
      } else if (filterType == FilterType.referenceType) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        requestStatusFilter = null;
        reqRefNoFilter = null;
        for (final Request? selectedType in (selectedTypes ?? [])) {
          if (data.requestType?.name == selectedType?.requestType?.name) {
            requestTypeFilter.add(selectedType!);
            typeMatch = true;
          }
        }
      } else if (filterType == FilterType.applicantRim) {
        applicantNameFilter = null;
        requestStatusFilter = null;
        reqRefNoFilter = null;
        rimMatch = (data.customerRimNo?.toString() ?? "").contains(value);
        applicantRimFilter = value;
      } else if (filterType == FilterType.referenceNumber) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        requestStatusFilter = null;
        refNoMatch = (data.applicationRefNo ?? "").contains(value);
        reqRefNoFilter = value;
      }

      return refNoMatch || typeMatch || rimMatch || nameMatch;
    }).toList();
    if (filterType == FilterType.referenceType) {
      if (selectedTypes == [] || (selectedTypes ?? []).isEmpty) {
        requestTypeFilter = [];
        filteredWorkList = worklistData;
      }
    }
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }
}
