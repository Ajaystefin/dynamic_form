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

/// Displays the Product Type field on the Request Information screen.
///
/// Allows users to view or select the product type associated
/// with the current request.
class ProductType extends StatelessWidget {
  /// Creates a [ProductType].
  const ProductType({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages product type-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    List<Reference> filteredProductOptions =
        viewModel.getFilteredProductOptions();

    if ((Globals.user?.isIslamic ?? false) &&
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

    final bool isValid;
    if (viewModel.isNewRequest) {
      if (Utils.checkApplicationType(ApplicationType.cancellation)) {
        isValid = false;
      } else {
        isValid = true;
      }
    } else {
      if (Utils.checkApplicationType(ApplicationType.cancellation)) {
        isValid = false;
      } else {
        isValid = viewModel.canEdit;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.productType".tr(),
          isRequired: !viewModel.isFI,
          child: CustomRadioButton<Reference>(
            isEnabled: isValid,
            options: filteredProductOptions,
            selectedValue: selectedProduct,
            itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
                Text(item.name ?? ""),
            validator: (viewModel.isFI)
                ? null
                : isValid
                    ? viewModel.validateProductTypeSelection
                    : null,
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
