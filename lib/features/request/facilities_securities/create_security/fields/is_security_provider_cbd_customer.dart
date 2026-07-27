import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the security provider CBD customer
/// selection.
class IsSecurityProviderCbdCustomer extends StatelessWidget {
  /// Creates a security provider CBD customer widget.
  const IsSecurityProviderCbdCustomer({
    required this.viewModel,
    super.key,
  });

  /// View model containing security provider CBD customer data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.isSecurityProviderCbdCustomer".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomRadioButton<Reference?>(
        validator: (value) {
          if ((viewModel.yesAndNo ?? []).contains(value)) {
            return null;
          }
          return "security.createSecurity.isSecurityProviderCbdCustomer".tr();
        },
        isEnabled: !viewModel.isCmoUpdate(),
        options: viewModel.yesAndNo ?? [],
        selectedValue: viewModel.yesAndNo?.firstWhere(
          (item) =>
              item.id ==
              (viewModel.security.selectedIsSecurityProviderCbdCustomerValue
                          ?.id ==
                      ServerConstants.optionNOid
                  ? ServerConstants.optionNOid
                  : ServerConstants.optionYESid),
        ),
        onChanged: (value) {
          viewModel.changeSecurityProviderCbdCustomerValue(value);
        },
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
            Text(item?.name ?? ""),
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.tableActivatedColor,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
