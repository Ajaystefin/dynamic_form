import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Add CBRB Dialog.
///
/// Manages loading status and customer name input
/// during the CBRB addition process.
class AddCbrbDialogState {
  /// Creates an instance of [AddCbrbDialogState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [customerName] stores the entered customer name.
  AddCbrbDialogState({
    required this.loaderStatus,
    this.customerName = "",
  });

  /// Defines the overall loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Stores the customer name entered by the user.
  String? customerName = "";

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  AddCbrbDialogState copyWith({
    LoadingStatus? loaderStatus,
    String? customerName,
  }) {
    return AddCbrbDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      customerName: customerName ?? this.customerName,
    );
  }
}
