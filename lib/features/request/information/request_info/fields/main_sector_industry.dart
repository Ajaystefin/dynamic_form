import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Main Sector/Industry field on the Request Information screen.
///
/// Allows users to view or select the primary sector and industry
/// associated with the current request.
class MainSectorIndustry extends StatelessWidget {
  /// Creates a [MainSectorIndustry].
  const MainSectorIndustry({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages sector and industry-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.applicationDetails?.mainSectorIndustry ?? "";
    final bool isValid = viewModel.canEdit;
    // bool isValid = viewModel.canEdit
    //     ? viewModel.viewAccessRolesCheck()
    //         ? true
    //         : false
    //     : false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label:
              "requestInformation.requestInformation.mainSectorIndustry".tr(),
          isRequired: !viewModel.isFI,
          child: CustomTextField(
            controller: viewModel.controllerMainSec,
            key: const ValueKey("mainSectorIndustry"),
            filled: !isValid,
            readOnly: !isValid,
            maxLength: 50,
            semanticLabel:
                "requestInformation.requestInformation.mainSectorIndustry".tr(),
            initialValue: initialValue,
            // hintText: initialValue,
            validator: viewModel.isCheckCancellationAT()
                ? null
                : (viewModel.isFI)
                    ? null
                    : CustomValidator.requiredField,
            onSaved: (String? value) {
              viewModel.applicationDetails?.mainSectorIndustry = value;
            },
          ),
        ),
      ],
    );
  }
}
