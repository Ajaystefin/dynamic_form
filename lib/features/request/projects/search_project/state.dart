import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Search Project feature.
///
/// Manages loading status and controls the visibility
/// of customer type field and data table.
class SearchProjectState {
  /// Creates an instance of [SearchProjectState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// while [showCustomerTypeField] and [showDataTable]
  /// control UI visibility.
  SearchProjectState({
    this.loaderStatus = LoadingStatus.loaded,
    this.showCustomerTypeField = false,
    this.showDataTable = false,
  });

  /// Defines the overall loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Controls whether the customer type field is visible.
  bool? showCustomerTypeField = false;

  /// Controls whether the data table is visible.
  bool? showDataTable = false;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  SearchProjectState copyWith({
    LoadingStatus? loaderStatus,
    bool? showCustomerTypeField,
    bool? showDataTable,
  }) {
    return SearchProjectState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      showCustomerTypeField:
          showCustomerTypeField ?? this.showCustomerTypeField,
      showDataTable: showDataTable ?? this.showDataTable,
    );
  }
}
