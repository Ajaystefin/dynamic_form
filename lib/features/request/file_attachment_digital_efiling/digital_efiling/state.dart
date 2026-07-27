import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Digital E‑Filing feature.
///
/// Manages loading states, search operations, and selected
/// group/customer details along with dialog visibility.
class DigitalEfilingState {
  /// Creates an instance of [DigitalEfilingState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [searchLoaderStatus] represents the loading state
  /// for search operations.
  DigitalEfilingState({
    required this.loaderStatus,
    required this.searchLoaderStatus,
    this.groupName,
    this.groupRim,
    this.customerName,
    this.customerRim,
    this.showSelectDialog = false,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status for search operations.
  LoadingStatus searchLoaderStatus = LoadingStatus.loaded;

  /// Stores the selected group name.
  final String? groupName;

  /// Stores the selected group RIM.
  final String? groupRim;

  /// Stores the selected customer name.
  final String? customerName;

  /// Stores the selected customer RIM.
  final String? customerRim;

  /// Controls whether the selection dialog is visible.
  bool showSelectDialog;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  DigitalEfilingState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? searchLoaderStatus,
    String? groupName,
    String? groupRim,
    String? customerName,
    String? customerRim,
    bool? showSelectDialog,
  }) {
    return DigitalEfilingState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      searchLoaderStatus: searchLoaderStatus ?? this.searchLoaderStatus,
      groupName: groupName ?? this.groupName,
      groupRim: groupRim ?? this.groupRim,
      customerName: customerName ?? this.customerName,
      customerRim: customerRim ?? this.customerRim,
      showSelectDialog: showSelectDialog ?? this.showSelectDialog,
    );
  }
}
