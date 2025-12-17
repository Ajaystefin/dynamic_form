import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ContractAmount extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ContractAmount({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'project.linkContract.contractAmount'.tr(),
        isRequired: true,
        child: Column(
          children: [
            CustomTextField(
              semanticLabel: 'project.linkContract.contractAmount'.tr(),
              prefixIcon: CustomDropdown<Reference>(
                width: 70.w,
                height: null,
                validationMessage: "validation.emptyField".tr(),
                items: viewModel.safeCountryCodes,
                selectedItems: [viewModel.selectedRef],
                onSelected: (selectedValue) {
                  if (selectedValue.isNotEmpty) {
                    viewModel.onCurrencyChanged(selectedValue.first);
                  }
                },
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return ListTile(
                    title: Text(item.name ?? ""),
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.name ?? "",
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
              controller: viewModel.contractorValueController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,21}(\.\d{0,6})?$')),
              ],
              validator: (v) => CustomValidator.requiredFieldCustomMsg(
                  v, 'project.linkContract.pleaseEnterContractValue'.tr()),
              onChanged: viewModel.onContractValueChanged,
            ),
            if (viewModel.selectedCurrencyLabel != ServerConstants.aedCurrency)
              CustomTextField(
                prefixIcon: CustomDropdown<Reference>(
                  width: 70.w,
                  height: null,
                  items: const [],
                  isEnabled: false,
                  showClearIcon: false,
                  selectedItems: [viewModel.defaultCodes[0]],
                  onSelected: (selectedValue) {
                    if (selectedValue.isNotEmpty) {
                      viewModel.onCurrencyChanged(selectedValue.first);
                    }
                  },
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return ListTile(
                      title: Text(item.name ?? ""),
                    );
                  },
                  dropdownBuilder: (context, data) {
                    return Text(
                      data?.name ?? "",
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
                semanticLabel: 'project.linkContract.convertedAmount'.tr(),
                readOnly: true,
                filled: true,
                fillColor: AppColors.tableActivatedColor,
                controller: viewModel.convertedAmountController,
              ),
          ],
        ));
  }
}
