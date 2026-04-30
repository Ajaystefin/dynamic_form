import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProductType extends StatelessWidget {
  const ProductType({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.productType".tr(),
      isRequired: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomRadioButton<Reference>(
          isEnabled: viewModel.canEdit,
          options: viewModel.productTypeItems,
          selectedValue:
              viewModel.selectedProductType ?? viewModel.productTypeItems.first,
          itemBuilder: (context, item, isSelected, isEnabled) =>
              Text(item.name ?? ""),
          // validator: (viewModel.showCurrentFiCreditRisk)
          //     ? null
          //     : viewModel.validateProductTypeSelection,
          onChanged: (Reference selectedRef) {
            viewModel.onProductTypeSelected(selectedRef);
          },
          selectedColor: AppColors.primary,
          unselectedColor: Colors.grey,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
