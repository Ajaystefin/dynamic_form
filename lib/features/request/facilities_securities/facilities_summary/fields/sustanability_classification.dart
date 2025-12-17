import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class SustanabilityClassificationField extends StatelessWidget {
  final FacilitiesSummaryViewModel viewModel;
  final List<Reference> sustanabilityClassification;
  final Facility? facility;
  const SustanabilityClassificationField(
      {super.key,
      required this.viewModel,
      required this.facility,
      required this.sustanabilityClassification});

  @override
  Widget build(BuildContext context) {
    return CustomMultiSelectDropdown<Reference>(
      validationMessage: "validation.emptyField".tr(),
      items: sustanabilityClassification,
      selectedItems: [
        facility?.selectedSustanabilityValue ??
            sustanabilityClassification.first
      ],
      onSelected: (selectedValue) {
        if (selectedValue.isNotEmpty) {
          facility?.selectedSustanabilityValue = (selectedValue.first);
        }
      },
      itemBuilder: (context, item, isDisabled, isSelected) {
        return dropdownItemBuildWidget(item.name,
            isListTile: true, isSelected: isSelected);
      },
      dropdownBuilder: (context, data) {
        return dropdownMultiItemBuildScrollWidget(
            data,
            (index) => Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: const TextStyle(fontSize: AppStyle.columnName),
                  label: Text("${data?[index].name}"),
                ));
      },
    );
  }
}
