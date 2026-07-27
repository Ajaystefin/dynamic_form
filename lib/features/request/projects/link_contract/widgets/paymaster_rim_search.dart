// import "package:easy_localization/easy_localization.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/checkbox.dart";

import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/features/request/projects/link_contract/state.dart";

class PaymasterRimSearch extends StatelessWidget {
  const PaymasterRimSearch({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final LinkContractViewModel viewModel;
  final LinkContractState state;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      label: "project.linkContract.searchPaymasterNameRIM".tr(),
      isRequired: state.hasRim,
      child: Row(
        children: [
          CustomCheckbox(
            key: const ValueKey("hasRimSelection"),
            value: state.hasRim,
            onChange: ({value}) {
              viewModel.hasRimSelected(isChecked: value);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomTextField(
              key: const ValueKey("paymasterRimSelection"),
              readOnly: !state.hasRim,
              filled: !state.hasRim,
              initialValue: "",
              controller: viewModel.paymasterRimSearchController,
              inputFormatters: [
                ThousandsWithMaxDigitsFormatter(maxDigits: 15),
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSaved: (value) {
                viewModel.contract.paymasterRimSearch = value;
              },
              suffixIcon: Padding(
                padding: const EdgeInsets.all(4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final String rimNo =
                          viewModel.paymasterRimSearchController.text;
                      await viewModel.updateRimNo(rimNo);
                    },
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              validator: CustomValidator.requiredField,
            ),
          ),
        ],
      ),
    );
  }
}
