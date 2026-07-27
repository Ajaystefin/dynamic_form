import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/widgets/textfield_with_button.dart";

/// Displays the customer RIM number field with a search button for CCSYS requests.
class CustomerRimNoField extends StatelessWidget {
  /// Creates the customer RIM number field widget.
  const CustomerRimNoField({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage customer RIM number input and search actions.
  final CcsysCreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      readOnly: viewModel.fieldCntrl.value[ControlFields.customerRim] ?? false,
      isRequired: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        return CustomValidator.requiredFieldCustomMsg(
          value,
          "common.validation.pleaseEnter".tr() +
              "requestInformation.createRequest.customerRimNo".tr(),
        );
      },
      isLoading: viewModel.customerRimNoLoadingStatus == LoadingStatus.loading,
      value: viewModel.customerRimNo,
      viewModel: viewModel,
      semanticLabel: "requestInformation.createRequest.customerRimNo".tr(),
      label: "requestInformation.createRequest.customerRimNo".tr(),
      onChanged: (value) {
        viewModel.customerRimNo = value;
        viewModel.handleFieldControl(ControlFields.customerRim, value);
      },
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.customerRimNo == null
          ? null
          : viewModel.onCustomerRimNoSearchPressed,
      onSubmit: (value) => viewModel.onCustomerRimNoSearchPressed,
    );
  }
}
