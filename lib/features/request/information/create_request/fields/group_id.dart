import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";
import "package:wcas_frontend/features/request/information/create_request/widgets/textfield_with_button.dart";

class GroupIdField extends StatelessWidget {
  GroupIdField({required this.viewModel, super.key});
  final CreateRequestViewModel viewModel;
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return TextfieldWithButton(
      key: ValueKey(viewModel.isResetPressed),
      focusNode: _focusNode,
      readOnly: viewModel.isSearched ||
          (viewModel.fieldCntrl.value[ControlFields.groupID] ?? false),
      isRequired: true,
      isLoading: viewModel.groupIdLoadingStatus == LoadingStatus.loading,
      inputFormatters:
          (viewModel.fieldCntrl.value[ControlFields.groupID] ?? false)
              ? null
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
      value: viewModel.groupId,
      viewModel: viewModel,
      label: "requestInformation.createRequest.groupId".tr(),
      onChanged: (value) {
        viewModel.groupId = value;
        viewModel.handleFieldControl(ControlFields.groupID, value);
      },
      validator: (value) {
        return viewModel.customer == null
            ? CustomValidator.requiredFieldCustomMsg(
                value,
                "common.validation.pleaseEnter".tr() +
                    "requestInformation.createRequest.groupId".tr(),
              )
            : null;
      },
      buttonLabel: "requestInformation.createRequest.search".tr(),
      buttonOnPressed: viewModel.onGroupIdSearchPressed,
      onSubmit: (value) => viewModel.onGroupIdSearchPressed(),
    );
  }
}
