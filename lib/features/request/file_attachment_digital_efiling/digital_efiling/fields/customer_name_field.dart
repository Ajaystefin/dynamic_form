import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/textfield_with_button.dart";

/// CustomerNameField stateless widget
class CustomerNameField extends StatelessWidget {
  /// Creates [CustomerNameField] instance
  const CustomerNameField({required this.viewModel, super.key});

  /// DigitalEfilingViewModel view model to handle actions
  final DigitalEfilingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      readOnly: viewModel.isSearched ||
          (viewModel.fieldCntrl.value[ControlFields.customerName] ?? false),
      isRequired: true,
      showAsteric: false,
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
      buttonOnPressed: viewModel.onCustomerNameSearchPressed,
      onSubmit: (value) => viewModel.onCustomerNameSearchPressed(),
    );
  }
}
