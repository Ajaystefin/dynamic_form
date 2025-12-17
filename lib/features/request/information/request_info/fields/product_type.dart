import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ProductType extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const ProductType({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final filteredProductOptions = viewModel.getFilteredProductOptions();
    final selectedProduct = viewModel.getSelectedProductReference(
      selectedValue: viewModel.selectedProductType,
      showSelectAsDefault: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.productType'.tr(),
          isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
          showLabel: true,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false : false,
            options: filteredProductOptions,
            selectedValue: selectedProduct,
            itemBuilder: (context, item, isSelected, isEnabled) =>
                Text(item.name ?? ''),
            validator: (viewModel.showCurrentFiCreditRisk)
                ? null
                : viewModel.validateProductTypeSelection,
            onChanged: (Reference selectedRef) {
              viewModel.onProductTypeSelected(selectedRef);
            },
            selectedColor: AppColors.primary,
            unselectedColor: Colors.grey,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}
