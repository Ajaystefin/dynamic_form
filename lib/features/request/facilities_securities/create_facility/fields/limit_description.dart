import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class LimitDescription extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const LimitDescription({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired:
          viewModel.showCreateFacilityForm && (!viewModel.showFacilityFi),
      label: 'facilities.createFacility.descriptions'.tr(),
      child: viewModel.showCreateFacilityForm
          ? CustomTextField(
              // initialValue:
              // (viewModel.showCreateFacilityForm) ?  viewModel.selectedDescriptionName: "",
              controller: viewModel.limitDescriptionController,
              // : (viewModel.facilityDetail.isNotEmpty
              //           ? viewModel.facilityDetail.first..toString()
              //           : ""),
              // viewModel.facility.facilityDescription?.name,
              readOnly: true,
              filled: true,
            )
          : CustomDropdown<Reference>(
              isEnabled: true,
              semanticLabel: 'facilities.createFacility.descriptions'.tr(),
              validationMessage: "validation.emptyField".tr(),
              items: viewModel.selectedProductType?.id ==
                      ServerConstants.productTypeIslamicID
                  ? viewModel.facilityDescriptions
                      .where((e) =>
                          (e.reference1 ?? "").trim().toUpperCase() == "I")
                      .toList()
                  : viewModel.facilityDescriptions
                      .where((e) =>
                          (e.reference1 ?? "").trim().toUpperCase() == "C")
                      .toList(),
              selectedItems: viewModel.facility.facilityDescription == null
                  ? null
                  : [viewModel.facility.facilityDescription],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel
                      .facilityTypeDescriptionsSelected(selectedValue.first);
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(item.name,
                    isSelected: isSelected, isListTile: false);
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
