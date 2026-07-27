import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Customer Info screen.
///
/// Manages loading states, user name update loading,
/// and customer industry-related details.
class CustomerInfoState {
  /// Creates an instance of [CustomerInfoState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  /// Other parameters control user name update loading and
  /// industry-related values.
  CustomerInfoState({
    required this.loaderStatus,
    this.userNameChangeLoader,
    this.isPolicyDeviation = false,
    this.industrySicCode = "",
    this.industrySicCodeDesc = "",
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status for user name change operation.
  LoadingStatus? userNameChangeLoader = LoadingStatus.loaded;

  /// Indicates whether policy deviation is applied.
  bool? isPolicyDeviation;

  /// Stores the industry SIC code.
  String? industrySicCode;

  /// Stores the description of the industry SIC code.
  String? industrySicCodeDesc;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CustomerInfoState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? userNameChangeLoader,
    bool? isPolicyDeviation,
    String? industrySicCode,
    String? industrySicCodeDesc,
  }) {
    return CustomerInfoState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      userNameChangeLoader: userNameChangeLoader ?? this.userNameChangeLoader,
      isPolicyDeviation: isPolicyDeviation ?? this.isPolicyDeviation,
      industrySicCode: industrySicCode ?? this.industrySicCode,
      industrySicCodeDesc: industrySicCodeDesc ?? this.industrySicCodeDesc,
    );
  }
}
