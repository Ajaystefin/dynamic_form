import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/textfield_with_button.dart";

/// GroupNameField stateless widget
class GroupNameField extends StatelessWidget {
  /// Creates [GroupNameField] instance
  GroupNameField({required this.viewModel, super.key});

  /// DigitalEfilingViewModel view model to handle actions
  final DigitalEfilingViewModel viewModel;

  /// FocusNode instance
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      focusNode: _focusNode,
      readOnly: viewModel.isSearched ||
          (viewModel.fieldCntrl.value[ControlFields.groupName] ?? false),
      isLoading: viewModel.groupNameLoadingStatus == LoadingStatus.loading,
      isRequired: true,
      showAsteric: false,
      value: viewModel.groupName ?? viewModel.grpName,
      viewModel: viewModel,
      label: "requestInformation.createRequest.groupName".tr(),
      onChanged: (value) {
        viewModel.groupName = value;
        viewModel.handleFieldControl(ControlFields.groupName, value);
      },
      validator: (value) {
        return viewModel.customer == null
            ? CustomValidator.requiredFieldCustomMsg(
                value,
                "common.validation.pleaseEnter".tr() +
                    "requestInformation.createRequest.groupName".tr(),
              )
            : null;
      },
      inputFormatters:
          (viewModel.fieldCntrl.value[ControlFields.groupName] ?? false)
              ? null
              : [
                  LengthLimitingTextInputFormatter(50),
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9- -]")),
                ],
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.onGroupNameSearchPressed,
      onSubmit: (value) => viewModel.onGroupNameSearchPressed(),
    );
  }
}
