import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/features/request/projects/link_contract/state.dart";

class PaymasterNameHasRimSelect extends StatelessWidget {
  const PaymasterNameHasRimSelect({
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
      child: CustomTextField(
        key: const ValueKey("PaymasterNameHasRim"),
        semanticLabel: "project.linkContract.paymasterName".tr(),
        controller: viewModel.paymasterNameController,
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
          v,
          "project.linkContract.pleaseEnterPaymasterName".tr(),
        ),
        maxLength: 50,
        filled: true,
        readOnly: true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9 ]")),
          LengthLimitingTextInputFormatter(50),
        ],
        onSaved: (val) => viewModel.contract.paymasterName = val,
        onChanged: (val) => viewModel.contract.paymasterName = val,
      ),
    );
  }
}
