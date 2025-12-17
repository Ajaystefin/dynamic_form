import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class TenorDays extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final Facility? facility;
  const TenorDays({super.key, required this.facility, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: CustomDropdown<Reference>(
            validationMessage: "validation.emptyField".tr(),
            items: viewModel.tenorDays,
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
        ),
        Expanded(
            flex: 2,
            child: CustomTextField(
                initialValue: "${facility?.tenorDays ?? ""}",
                validator: CustomValidator.requiredField,
                onSaved: (String? value) {
                  facility?.proposedLimits = int.tryParse(value ?? '');
                })),
      ],
    );
  }
}
