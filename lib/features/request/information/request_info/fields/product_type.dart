import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProductType extends StatelessWidget {
  const ProductType({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    List<Reference> filteredProductOptions =
        viewModel.getFilteredProductOptions();

    if (Globals.user?.isIslamic == true &&
        Utils.checkRoles(
          [UserRole.relationshipManager, UserRole.relationshipOfficer],
        )) {
      filteredProductOptions = filteredProductOptions
          .where(
            (item) => item.reference1 == ServerConstants.productTypeIslamic,
          )
          .toList();
    }
    final selectedProduct = viewModel.getSelectedProductReference(
      selectedValue: viewModel.selectedProductType,
      showSelectAsDefault: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.productType".tr(),
          isRequired: (viewModel.isFI) ? false : true,
          showLabel: true,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //   ? viewModel.viewAccessRolesCheck()
            //       ? true
            //       : false
            //   : false,
            options: filteredProductOptions,
            selectedValue: selectedProduct,
            itemBuilder: (context, item, isSelected, isEnabled) =>
                Text(item.name ?? ""),
            validator: (viewModel.isFI)
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
