import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/features/request/information/create_request/widgets/textfield_with_button.dart";

/// Displays the Customer RIM Number field used during request creation.
///
/// The field is bound to the provided [CreateRequestViewModel] and
/// allows users to enter or view the customer RIM number associated
/// with the request.
class CustomerRimNoField extends StatelessWidget {
  /// Creates a [CustomerRimNoField].
  const CustomerRimNoField({
    required this.viewModel,
    super.key,
  });

  /// View model that supplies data and manages interactions
  /// for the Customer RIM Number field.
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      readOnly: viewModel.isSearched ||
          (viewModel.fieldCntrl.value[ControlFields.customerRim] ?? false),
      isRequired: true,
      inputFormatters:
          (viewModel.fieldCntrl.value[ControlFields.customerRim] ?? false)
              ? null
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
      validator: (value) {
        return CustomValidator.requiredFieldCustomMsg(
          value,
          "common.validation.pleaseEnter".tr() +
              "requestInformation.createRequest.customerRimNo".tr(),
        );
      },
      maxLength: 10,
      isLoading: viewModel.customerRimNoLoadingStatus == LoadingStatus.loading,
      value: viewModel.customerRimNo,
      viewModel: viewModel,
      label: "requestInformation.createRequest.customerRimNo".tr(),
      onChanged: (value) {
        viewModel.customerRimNo = value;
        viewModel.handleFieldControl(ControlFields.customerRim, value);
      },
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.onCustomerRimNoSearchPressed,
      onSubmit: (value) => viewModel.onCustomerRimNoSearchPressed,
    );
  }
}
