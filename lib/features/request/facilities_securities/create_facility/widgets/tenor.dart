import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class TenorDays extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  final FacilitySubTypes? facilitySubType;
  const TenorDays(
      {super.key, required this.facilitySubType, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          validationMessage: "",
          items: viewModel.purposes,
          selectedItems: [viewModel.tenorDays.first],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              // viewModel.proposedSecurityAmountSelected(selectedValue.first);
            }
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.name,
                isListTile: true, isSelected: isSelected);
          },
          dropdownBuilder: (context, data) {
            return Text(
              data?.name ?? "",
              style: const TextStyle(fontSize: 14),
            );
          },
        ),
        initialValue: "${facilitySubType?.tenor ?? ""}",
        onSaved: (String? value) {
          facilitySubType?.tenor = int.tryParse(value ?? '');
        });
  }
}
