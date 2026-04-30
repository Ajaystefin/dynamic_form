import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";

class OverrideDate extends StatelessWidget {
  const OverrideDate({required this.viewModel, required this.state, super.key});
  final RequestInfoViewModel viewModel;
  final RequestInfoState state;

  @override
  Widget build(BuildContext context) {
    final bool isValid = viewModel.otherRolesCheck() ? true : false;
    return LabelWidget(
      label: "",
      child: isValid
          ? CustomCheckbox(
              key: const ValueKey("overrideDate1"),
              width: 200,
              isEnabled: true,
              semanticsLabel:
                  "requestInformation.requestInformation.overrideDate".tr(),
              value: state.overrideDate,
              onChange: (val) {
                viewModel.overrideSelected(val);
              },
              child: Text(
                "requestInformation.requestInformation.overrideDate".tr(),
              ),
            )
          : CustomCheckbox(
              key: const ValueKey("overrideDate2"),
              width: 200,
              isEnabled: false,
              semanticsLabel:
                  "requestInformation.requestInformation.overrideDate".tr(),
              value: state.overrideDate,
              onChange: (val) {
                // viewModel.overrideSelected(val);
              },
              child: Text(
                "requestInformation.requestInformation.overrideDate".tr(),
              ),
            ),
    );
  }
}
