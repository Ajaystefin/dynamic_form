import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';

class ProposedLimits extends StatelessWidget {
  final FacilitiesSummaryFiViewModel viewModel;

  final CustomerFacility customer;
  final Facility? facility;
  const ProposedLimits({
    super.key,
    required this.viewModel,
    required this.customer,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: CustomDropdown<Reference>(
            validationMessage: "validation.emptyField".tr(),
            items: viewModel.currencyCodes,
            selectedItems: [viewModel.currencyCodes.first],
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
                initialValue: facility?.proposedLimits.toString(),
                validator: CustomValidator.requiredField,
                onSaved: (String? value) {
                  facility?.proposedLimits = int.tryParse(value ?? '');
                })),
      ],
    );
  }
}
