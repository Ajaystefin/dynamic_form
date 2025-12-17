import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/features/request/information/request_info/state.dart';

class OverrideDate extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  final RequestInfoState state;
  const OverrideDate({super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    bool? isValid = viewModel.canEdit
        ? viewModel.otherRolesCheck()
            ? true
            : false
        : false;
    return LabelWidget(
      label: '',
      child: isValid
          ? CustomCheckbox(
              key: const ValueKey("overrideDate1"),
              width: 200,
              semanticsLabel:
                  'requestInformation.requestInformation.overrideDate'.tr(),
              value: state.overrideDate,
              onChange: (val) {
                viewModel.overrideSelected(val);
              },
              child: Text(
                  'requestInformation.requestInformation.overrideDate'.tr()),
            )
          : CustomCheckbox(
              key: const ValueKey("overrideDate2"),
              width: 200,
              semanticsLabel:
                  'requestInformation.requestInformation.overrideDate'.tr(),
              value: state.overrideDate,
              onChange: (val) {
                // viewModel.overrideSelected(val);
              },
              child: Text(
                  'requestInformation.requestInformation.overrideDate'.tr()),
            ),
    );
  }
}
