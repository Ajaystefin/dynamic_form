import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/textfield_with_button.dart";

/// CustomerRimNoField stateless widget
class CustomerRimNoField extends StatelessWidget {
  /// Creates [CustomerRimNoField] instance
  const CustomerRimNoField({
    required this.viewModel,
    super.key,
  });

  /// DigitalEfilingViewModel view model to handle actions
  final DigitalEfilingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      readOnly: viewModel.isSearched ||
          (viewModel.fieldCntrl.value[ControlFields.customerRim] ?? false),
      isRequired: true,
      showAsteric: false,
      inputFormatters:
          (viewModel.fieldCntrl.value[ControlFields.customerRim] ?? false)
              ? null
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
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
      label: "requestInformation.createRequest.customerRimNo".tr(),
      onChanged: (value) {
        viewModel.customerRimNo = value;
        viewModel.handleFieldControl(ControlFields.customerRim, value);
      },
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.onCustomerRimNoSearchPressed,
      onSubmit: (value) => viewModel.onCustomerRimNoSearchPressed(),
    );
  }
}
