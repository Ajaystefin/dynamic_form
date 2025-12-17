import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';



class FacilitySicCode extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilitySicCode({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // NEW: compute filtered SICs based on selected sector
    final Reference? selectedSector = viewModel.facility.sector;
    final String? sectorIdStr = selectedSector?.id?.toString();
    final List<Reference> filteredSicCodes = (sectorIdStr == null || sectorIdStr.trim().isEmpty)
        ? <Reference>[]
        : viewModel.sicCodes.where((s) => (s.reference1 ?? '').trim() == sectorIdStr).toList();

    return LabelWidget(
      label: 'facilities.createFacility.sicCode'.tr(),
      isRequired: selectedSector != null,
      showLabel: true,
      child: CustomDropdown<Reference>(
        isEnabled: selectedSector != null,
        items: filteredSicCodes,
        selectedItems: !viewModel.showCreateFacilityForm &&
                viewModel.facility.sicCode != null &&
                filteredSicCodes.any((s) => s.id == viewModel.facility.sicCode!.id)
            ? [viewModel.facility.sicCode!]
            : null,
        validationMessage: selectedSector != null ? "common.validation.emptyField".tr() : null,
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.facility.sicCode = (selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            "${item.name} : ${item.description}",
            isSelected: isSelected,
            isListTile: false,
          );
        },
        dropdownBuilder: (context, data) {
          final label = (data == null)
              ? ''
              : [
                  data.name ?? '',
                  data.description ?? '',
                ].where((part) => part.trim().isNotEmpty).join(' : ');

          return  Text(label, style: const TextStyle(fontSize: 14));
        },
      ),
    );
  }
}
