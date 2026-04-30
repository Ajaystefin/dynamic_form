import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class LimitDescriptions extends StatelessWidget {
  const LimitDescriptions({required this.viewModel, super.key});
  final FacilitiesSummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Decide I/C from selected product type (NOT from facilityTypeSelectedValue.reference1 anymore)
    final bool isIslamic = viewModel.selectedProductTypeOption?.id ==
        ServerConstants.productTypeIslamicID;
    final String codeForDescriptions = isIslamic ? "I" : "C";

    // The chosen limit type label from LIMIT_TYPE (e.g., "Asset Backed Loan")
    final String selectedLimitTypeName =
        (viewModel.facility.facilityTypeSelectedValue?.reference1 ?? "")
            .trim()
            .toUpperCase();

    return LabelWidget(
      label: "facilities.facilitySummary.limitDescription".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.facility.facilityTypeSelectedValue != null,
        items: viewModel.facilityDescriptions
            // Accept the current product code or "B" (Both)
            .where((e) {
              final code = (e.reference1 ?? "").trim().toUpperCase();
              return code == codeForDescriptions || code == "B";
            })
            // Still ensure we are in the same limit type group
            .where(
              (e) =>
                  (e.reference4 ?? "").trim().toUpperCase() ==
                  selectedLimitTypeName,
            )
            // Keep explicit 935 exclusion
            .where((e) => e.id != 935)
            .toList(),
        validationMessage: "validation.emptyField".tr(),
        selectedItems: viewModel.facility.facilityDescription == null
            ? null
            : [viewModel.facility.facilityDescription],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facilityTypeDescriptionsSelected(selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: false,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
