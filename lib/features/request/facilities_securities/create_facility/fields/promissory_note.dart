import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class PromissoryNote extends StatelessWidget {
  const PromissoryNote({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Resolve YES/NO refs by ID (don’t rely on list order)
    final Reference yesRef = viewModel.promissoryNoteOptions.firstWhere(
      (e) => e.id == ServerConstants.optionYESid,
      orElse: () => viewModel.promissoryNoteOptions.isNotEmpty
          ? viewModel.promissoryNoteOptions.first
          : Reference(),
    );
    final Reference noRef = viewModel.promissoryNoteOptions.firstWhere(
      (e) => e.id == ServerConstants.optionNOid,
      orElse: () => yesRef,
    );

    // Existing facility: derive from API boolean; Create: default to NO (or
    // VM’s selected)
    final Reference selected = viewModel.facilityDetail.isNotEmpty
        ? (viewModel.facilityDetail.first.promissoryNoteTaken == true
            ? yesRef
            : noRef)
        : (viewModel.getFacility.selectedpromissoryNoteValue ?? noRef);

    return LabelWidget(
      label: "facilities.createFacility.promissoryNote".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomRadioButton<Reference>(
        options: viewModel.promissoryNoteOptions,
        selectedValue: selected,
        onChanged: (value) {
          viewModel.changePromissoryNote(value);
        },
        itemBuilder: (context, item, isSelected, isEnabled) =>
            Text(item.name ?? ""),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
