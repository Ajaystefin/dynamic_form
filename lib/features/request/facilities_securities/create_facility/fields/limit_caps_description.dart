import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class LimitCapsDescription extends StatelessWidget {
  const LimitCapsDescription({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: viewModel.showCreateFacilityForm && (!viewModel.isFIFlow),
      label: "facilities.createFacility.descriptions".tr(),
      child: viewModel.showCreateFacilityForm
          ? CustomTextField(
              controller: viewModel.limitDescriptionController,
              readOnly: true,
              filled: true,
            )
          : CustomDropdown<Reference>(
              isEnabled: false,
              semanticLabel: "facilities.createFacility.descriptions".tr(),
              validationMessage: "validation.emptyField".tr(),
              items: viewModel.isProductTypeIslamic
                  ? viewModel.facilityDescriptions
                      .where(
                        (e) => (e.reference1 ?? "").trim().toUpperCase() == "I",
                      )
                      .toList()
                  : viewModel.facilityDescriptions
                      .where(
                        (e) => (e.reference1 ?? "").trim().toUpperCase() == "C",
                      )
                      .toList(),
              selectedItems: viewModel.getFacility.facilityDescription == null
                  ? null
                  : [viewModel.getFacility.facilityDescription],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel
                      .facilityTypeDescriptionsSelected(selectedValue.first);
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownItemBuildWidget(
                  item.name,
                  isSelected: isSelected,
                  isListTile: false,
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
