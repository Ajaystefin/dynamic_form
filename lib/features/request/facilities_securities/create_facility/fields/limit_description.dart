import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class LimitDescription extends StatelessWidget {
  const LimitDescription({
    required this.viewModel,
    super.key,
  });

  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String label = "facilities.createFacility.descriptions".tr();

    // Prefer the “actual saved/selected” value if available
    final String displayText =
        (viewModel.getFacility.facilityDescription?.name ?? "").trim();

    // - In create flow you already set controller.text from previous screen.
    // - In existing flow after save, controller can be stale; sync it from
    // facilityDescription.
    // Read-only field -> no cursor issues.
    if (!viewModel.showCreateFacilityForm) {
      if (viewModel.limitDescriptionController.text.trim() != displayText) {
        viewModel.limitDescriptionController.text = displayText;
      }
    }

    final bool showRequiredStar = !viewModel.isFIFlow && displayText.isEmpty;

    return LabelWidget(
      label: label,
      isRequired: showRequiredStar,
      child: CustomTextField(
        controller: viewModel.limitDescriptionController,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
