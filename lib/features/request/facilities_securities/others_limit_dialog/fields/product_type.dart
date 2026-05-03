import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProductType extends StatelessWidget {
  const ProductType({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasOptions = viewModel.productTypeOptions.isNotEmpty;

    return LabelWidget(
      label: "facilities.createFacility.productType".tr(),
      isRequired: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomRadioButton<Reference?>(
          isEnabled: hasOptions && (viewModel.isProductTyopeEnabled ?? false),
          options: viewModel.productTypeOptions,
          // Bind to VM (fallback only if not set yet)
          selectedValue: hasOptions
              ? (viewModel.selectedProductTypeOption ??
                  viewModel.productTypeOptions.first)
              : null,
          onChanged: (selectedValue) {
            if (selectedValue != null) {
              viewModel.changeProductTypeOptions(selectedValue);
            }
          },
          itemBuilder: (context, item, isSelected, isEnabled) =>
              Text(item?.name ?? ""),
          validator: (value) =>
              CustomValidator.requiredField(value?.name ?? ""),
          isRequired: true,
          scrollDirection: Axis.horizontal,
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
