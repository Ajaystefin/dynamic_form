import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/textfield_with_button.dart";

/// Displays the customer name field with a search button for CCSYS requests.
class CustomerNameField extends StatelessWidget {
  /// Creates the customer name field widget.
  const CustomerNameField({required this.viewModel, super.key});

  /// View model used to manage customer name input and search actions.
  final CcsysCreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      readOnly: viewModel.fieldCntrl.value[ControlFields.customerName] ?? false,
      isRequired: true,
      isLoading: viewModel.customerNameLoadingStatus == LoadingStatus.loading,
      semanticLabel: "requestInformation.createRequest.customerName".tr(),
      validator: (value) {
        return CustomValidator.requiredFieldCustomMsg(
          value,
          "common.validation.pleaseEnter".tr() +
              "requestInformation.createRequest.customerName".tr(),
        );
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9- -]")),
      ],
      value: viewModel.customerName,
      viewModel: viewModel,
      label: "requestInformation.createRequest.customerName".tr(),
      onChanged: (value) {
        viewModel.customerName = value;
        viewModel.handleFieldControl(ControlFields.customerName, value);
      },
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.customerName == null
          ? null
          : viewModel.onCustomerNameSearchPressed,
      onSubmit: (value) => viewModel.onCustomerNameSearchPressed(),
    );
  }
}
