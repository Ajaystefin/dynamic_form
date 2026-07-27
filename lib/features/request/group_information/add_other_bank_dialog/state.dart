import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Add Other Bank Dialog.
///
/// Manages loading status and customer name input
/// during the process of adding another bank.
class AddOtherBankDialogState {
  /// Creates an instance of [AddOtherBankDialogState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [customerName] stores the entered customer name.
  AddOtherBankDialogState({
    required this.loaderStatus,
    this.customerName = "",
  });

  /// Defines the overall loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loading;

  /// Stores the customer name entered by the user.
  String? customerName = "";

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  AddOtherBankDialogState copyWith({
    LoadingStatus? loaderStatus,
    String? customerName,
  }) {
    return AddOtherBankDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      customerName: customerName ?? this.customerName,
    );
  }
}
