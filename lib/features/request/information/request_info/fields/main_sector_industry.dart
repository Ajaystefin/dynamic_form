import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class MainSectorIndustry extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const MainSectorIndustry({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.applicationDetails?.mainSectorIndustry ?? "";
    bool isValid = viewModel.canEdit
        ? viewModel.viewAccessRolesCheck()
            ? true
            : false
        : false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label:
              'requestInformation.requestInformation.mainSectorIndustry'.tr(),
          isRequired: true,
          showLabel: true,
          child: CustomTextField(
            controller: viewModel.controllerMainSec,
            key: const ValueKey("mainSectorIndustry"),
            filled: !isValid,
            readOnly: !isValid,
            maxLength: 50,
            semanticLabel:
                'requestInformation.requestInformation.mainSectorIndustry'.tr(),
            initialValue: initialValue,
            // hintText: initialValue,
            validator: viewModel.isCheckCancellationAT()
                ? null
                : CustomValidator.requiredField,
            onSaved: (String? value) {
              viewModel.applicationDetails?.mainSectorIndustry = value;
            },
          ),
        )
      ],
    );
  }
}
