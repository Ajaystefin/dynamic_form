import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";

/// Displays the Override Date field on the Request Information screen.
///
/// Allows users to view or specify an override date associated
/// with the current request and its approval workflow.
class OverrideDate extends StatelessWidget {
  /// Creates an [OverrideDate].
  const OverrideDate({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model that provides request information data and
  /// manages override date-related operations.
  final RequestInfoViewModel viewModel;

  /// Current state of the Request Information screen.
  final RequestInfoState state;

  @override
  Widget build(BuildContext context) {
    final bool isValid = viewModel.isNewRequest ||
        viewModel.canEdit ||
        viewModel.otherRolesCheck();
    return LabelWidget(
      label: "",
      child: isValid
          ? CustomCheckbox(
              key: const ValueKey("overrideDate1"),
              width: 200,
              semanticsLabel:
                  "requestInformation.requestInformation.overrideDate".tr(),
              value: state.overrideDate,
              onChange: ({value}) {
                viewModel.overrideSelected(isChecked: value);
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
              onChange: ({value}) {
                // viewModel.overrideSelected(val);
              },
              child: Text(
                "requestInformation.requestInformation.overrideDate".tr(),
              ),
            ),
    );
  }
}
