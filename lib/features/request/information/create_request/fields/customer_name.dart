import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/features/request/information/create_request/widgets/textfield_with_button.dart";

/// Displays the Customer Name field used during request creation.
///
/// The field is bound to the provided [CreateRequestViewModel] and
/// allows users to enter or view the customer name associated with
/// the request.
class CustomerNameField extends StatelessWidget {
  /// Creates a [CustomerNameField].
  const CustomerNameField({
    required this.viewModel,
    super.key,
  });

  /// View model that supplies data and manages interactions
  /// for the Customer Name field.
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      readOnly: viewModel.isSearched ||
          (viewModel.fieldCntrl.value[ControlFields.customerName] ?? false),
      isRequired: true,
      isLoading: viewModel.customerNameLoadingStatus == LoadingStatus.loading,
      validator: (value) {
        return CustomValidator.requiredFieldCustomMsg(
          value,
          "common.validation.pleaseEnter".tr() +
              "requestInformation.createRequest.customerName".tr(),
        );
      },
      inputFormatters:
          (viewModel.fieldCntrl.value[ControlFields.customerName] ?? false)
              ? null
              : [
                  LengthLimitingTextInputFormatter(122),
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9- -]")),
                ],
      value: viewModel.valueTruncateToMax(viewModel.customerName, 122),
      maxLength: 122,
      viewModel: viewModel,
      label: "requestInformation.createRequest.customerName".tr(),
      onChanged: (value) {
        viewModel.customerName = value;
        viewModel.requestCreate.customerName = value;
        viewModel.handleFieldControl(ControlFields.customerName, value);
      },
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.onCustomerNameSearchPressed,
      onSubmit: (value) => viewModel.onCustomerNameSearchPressed,
    );
  }
}
