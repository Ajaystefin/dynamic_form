import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";

class CustomerRimNoField extends StatelessWidget {
  const CustomerRimNoField({
    required this.viewModel,
    super.key,
  });
  final AdvancedSearchViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.customerRimNo".tr(),
      child: CustomTextField(
        initialValue: viewModel.customerRimNo,
        semanticLabel: "dashboard.advancedSearch.customerRimNo".tr(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          return CustomValidator.requiredCustomField(
            value,
            "dashboard.advancedSearch.customerRimNo".tr(),
          );
        },
        onChanged: (value) {
          viewModel.customerRimNo = value;
        },
      ),
    );
  }
}
