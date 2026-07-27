import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the facility SIC code.
class FacilitySicCode extends StatelessWidget {
  /// Creates a facility SIC code widget.
  const FacilitySicCode({
    required this.viewModel,
    super.key,
  });

  /// View model containing facility SIC code data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // NEW: compute filtered SICs based on selected sector
    final Reference? selectedSector = viewModel.getFacility.sector;
    final String? sectorIdStr = selectedSector?.id?.toString();
    final List<Reference> filteredSicCodes =
        (sectorIdStr == null || sectorIdStr.trim().isEmpty)
            ? <Reference>[]
            : viewModel.sicCodes
                .where((s) => (s.reference1 ?? "").trim() == sectorIdStr)
                .toList();

    final bool isSovereign = selectedSector != null &&
        ServerConstants.sovergianGroup == viewModel.getFacility.limitGroup;

    final bool isRequired = (selectedSector != null &&
            (selectedSector.name ?? "").isNotEmpty &&
            !viewModel.isFIFlow) ||
        isSovereign;

    return LabelWidget(
      key: ValueKey('sic-by-sector-${sectorIdStr ?? 'none'}'),
      label: "facilities.createFacility.sicCode".tr(),
      isRequired: isRequired && (selectedSector.name ?? "").isNotEmpty,
      child: CustomDropdown<Reference>(
        onClear: (selectedValue) => viewModel.getFacility.sicCode = null,
        isEnabled:
            selectedSector != null && (selectedSector.name ?? "").isNotEmpty,
        items: filteredSicCodes,
        selectedItems: (viewModel.getFacility.sicCode?.name ?? "").isEmpty
            ? null
            : [viewModel.getFacility.sicCode],
        //     : [
        //         filteredSicCodes.firstWhere(
        //           (s) => s.id == viewModel.getFacility.sicCode?.id,
        //          orElse: () => viewModel.sicCodes.first,
        //         ),
        //       ],
        // selectedItems: viewModel.getFacility.sicCode != null &&
        //         filteredSicCodes
        //             .any((s) => s.id == viewModel.getFacility.sicCode?.id)
        //     ? [viewModel.getFacility.sicCode]
        //     : null,
        validationMessage:
            isRequired ? "common.validation.emptyField".tr() : null,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.getFacility.sicCode = selectedValue.first;
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            "${item.name} : ${item.description}",
            isSelected: isSelected ?? false,
            isListTile: false,
          );
        },
        dropdownBuilder: (context, data) {
          final label = (data == null)
              ? ""
              : [
                  data.name ?? "",
                  data.description ?? "",
                ].where((part) => part.trim().isNotEmpty).join(" : ");

          return Text(label, style: const TextStyle(fontSize: 14));
        },
      ),
    );
  }
}
