import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PresentSecurityAmount extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const PresentSecurityAmount({super.key, required this.viewModel});

  @override
  @override
  Widget build(BuildContext context) {
    // Sort currencies to make AED appear first
    viewModel.currencyCodes.sort(
      (a, b) =>
          (b.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0) -
          (a.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0),
    );

    return LabelWidget(
      label: viewModel.securityProviderLabel(isPresent: true),
      child: CustomTextField(
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          // viewModel.security.isPariPassu?.id == ServerConstants.optionNOid,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.currencyCodes.isNotEmpty
                ? viewModel.security.presentSecurityAmtCurrency ??
                    viewModel.currencyCodes.first
                : Reference()
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.security.presentSecurityAmtCurrency =
                  selectedValue.first;
            }
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return ListTile(
              title: Text(item.name ?? ""),
            );
          },
          dropdownBuilder: (context, data) {
            return Text(
              data?.name ?? "",
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
        initialValue: viewModel.security.presentSecurityAmount?.toString(),
        hintText: '0',
        readOnly: true,
        filled: true,
        // validator: hasData ? null : CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.security.presentSecurityAmount =
              double.tryParse(value.toString());
        },
        textStyle: const TextStyle(fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
