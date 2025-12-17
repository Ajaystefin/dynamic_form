import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class CompletionPercent extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const CompletionPercent({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "project.linkContract.completionpercent".tr(),
      child: CustomTextField(
        keyboardType: TextInputType.number,
        semanticLabel: "project.linkContract.completionpercent".tr(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
            v, "project.linkContract.pleaseEnterCompletion".tr()),
      ),
    );
  }
}
