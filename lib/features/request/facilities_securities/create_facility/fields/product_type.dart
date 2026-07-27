import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting and managing the facility product type.
class ProductType extends StatelessWidget {
  /// Creates a product type widget.
  const ProductType({required this.viewModel, super.key});

  /// View model containing product type data and actions.
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
          itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
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
