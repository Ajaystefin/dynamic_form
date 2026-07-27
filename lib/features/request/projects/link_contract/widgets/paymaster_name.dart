import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/features/request/projects/link_contract/state.dart";

/// Paymaster name field for the link contract screen.
class PaymasterName extends StatelessWidget {
  const PaymasterName({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final LinkContractViewModel viewModel;
  final LinkContractState state;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.paymasterName".tr(),
      isRequired: true,
      child: (!state.subContractor)
          ? CustomTextField(
              key: const ValueKey("PaymasterName"),
              semanticLabel: "project.linkContract.paymasterName".tr(),
              controller: viewModel.paymasterNameController,
              validator: (v) => CustomValidator.requiredFieldCustomMsg(
                v,
                "project.linkContract.pleaseEnterPaymasterName".tr(),
              ),
              maxLength: 50,
              filled: !viewModel.canEdit,
              readOnly: !viewModel.canEdit,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9 ]")),
                LengthLimitingTextInputFormatter(50),
              ],
              onChanged: (val) => viewModel.contract.paymasterName = val,
            )
          : CustomDropdown<String?>(
             key: const ValueKey("PaymasterNameDropdown"),
              items: viewModel.paymasterNameList,
              showEditIcon: true,
              editHintText: "project.linkContract.enterPaymasterName".tr(),
              editController: viewModel.paymasterNameController,
              editInputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9 ]")),
                LengthLimitingTextInputFormatter(50),
              ],
              /// Called when user clicks edit icon
              onEditModeActivated: () {
                viewModel.isLimitTypeInEditMode = true;
                viewModel.contract.paymasterName = "";
              },
              /// Called while user types in edit mode
              onTextChanged: (changedValue) {
                viewModel.contract.paymasterName = changedValue;
              },
              /// Called when user submits / completes edit mode text
              onEditComplete: (changedValue) {
                viewModel.isLimitTypeInEditMode = true;
                viewModel.contract.paymasterName = changedValue;
              },
              /// Keep built-in dropdown validation for normal dropdown mode
              editValidator: CustomValidator.requiredField,
              selectedItems: viewModel.paymasterNameController.text.isEmpty
                  ? null
                  : [
                      viewModel.paymasterNameController.text,
                    ],
              onSelected: (selectedValue) async {
                if (selectedValue.isNotEmpty) {
                  viewModel.contract.paymasterName = selectedValue.first;
                  viewModel.isLimitTypeInEditMode = false;
                } else {
                  viewModel.contract.paymasterName = "";
                }
              },
              itemBuilder: (context, item, {isDisabled, isSelected}) {
                return dropdownMultiItemBuildWidget(
                  item,
                  isSelected: isSelected ?? false,
                );
              },
              onClear: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel.contract.paymasterName = selectedValue.first;
                } else {
                  viewModel.contract.paymasterName = "";
                }
              },
              validationMessage:
                  "project.linkContract.pleaseSelectPaymaster".tr(),
              dropdownBuilder: (context, data) {
                return Text(
                  data ?? "",
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
    );
  }
}
