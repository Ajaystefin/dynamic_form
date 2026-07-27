import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Request Info feature.
///
/// Manages loading status, button state, flags related to request configuration,
/// and various date fields used in the request lifecycle.
class RequestInfoState {
  /// Creates an instance of [RequestInfoState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  /// Other parameters control flags, customer details, and date handling.
  RequestInfoState({
    required this.loaderStatus,
    this.isButtonLoading = false,
    this.isTPAN = false,
    this.isIslamic = false,
    this.isInterimReviewDateRequired = false,
    this.isApplicationTypeMarkForward = false,
    this.isPolicyDeviation = false,
    this.overrideDate = false,
    this.isPresentReviewDate = false,
    this.customerName = "",
    this.nextReviewDate,
    this.presentReviewDate,
    this.markForwardDate,
    this.defaultPresentReviewDate,
    this.defaultNextReviewDate,
    this.isPresentReviewDateLocked = false,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Indicates whether the action button is in a loading state.
  final bool isButtonLoading;

  /// Indicates whether the request is TPAN.
  final bool isTPAN;

  /// Indicates whether the request is Islamic.
  final bool isIslamic;

  /// Indicates whether interim review date is required.
  final bool isInterimReviewDateRequired;

  /// Indicates whether application type is mark-forward.
  final bool isApplicationTypeMarkForward;

  /// Indicates whether there is a policy deviation.
  bool? isPolicyDeviation;

  /// Indicates whether override date is enabled.
  bool? overrideDate;

  /// Indicates whether present review date is active.
  bool? isPresentReviewDate;

  /// Stores the customer name.
  String? customerName;

  /// Stores the present review date.
  DateTime? presentReviewDate;

  /// Stores the default next review date.
  DateTime? defaultNextReviewDate;

  /// Stores the default present review date.
  DateTime? defaultPresentReviewDate;

  /// Stores the next review date.
  DateTime? nextReviewDate;

  /// Stores the mark-forward date.
  DateTime? markForwardDate;

  /// Indicates whether present review date is locked.
  final bool isPresentReviewDateLocked;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  RequestInfoState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
    bool? isTPAN,
    bool? isIslamic,
    bool? isInterimReviewDateRequired,
    bool? isApplicationTypeMarkForward,
    bool? isPolicyDeviation,
    bool? overrideDate,
    bool? isPresentReviewDate,
    String? customerName,
    DateTime? presentReviewDate,
    DateTime? defaultNextReviewDate,
    DateTime? defaultPresentReviewDate,
    DateTime? markForwardDate,
    DateTime? nextReviewDate,
    bool? isPresentReviewDateLocked,
  }) {
    return RequestInfoState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
      isTPAN: isTPAN ?? this.isTPAN,
      isIslamic: isIslamic ?? this.isIslamic,
      isInterimReviewDateRequired:
          isInterimReviewDateRequired ?? this.isInterimReviewDateRequired,
      isApplicationTypeMarkForward:
          isApplicationTypeMarkForward ?? this.isApplicationTypeMarkForward,
      isPolicyDeviation: isPolicyDeviation ?? this.isPolicyDeviation,
      overrideDate: overrideDate ?? this.overrideDate,
      isPresentReviewDate: isPresentReviewDate ?? this.isPresentReviewDate,
      customerName: customerName ?? this.customerName,
      presentReviewDate: presentReviewDate ?? this.presentReviewDate,
      defaultNextReviewDate:
          defaultNextReviewDate ?? this.defaultNextReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      defaultPresentReviewDate:
          defaultPresentReviewDate ?? this.defaultPresentReviewDate,
      markForwardDate: markForwardDate ?? this.markForwardDate,
      isPresentReviewDateLocked:
          isPresentReviewDateLocked ?? this.isPresentReviewDateLocked,
    );
  }
}
