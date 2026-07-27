import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// FI country rank field for the customer information screen.
class FiCountryRank extends StatelessWidget {
  /// Creates an FI country rank field.
  const FiCountryRank({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? countryRank = viewModel.customerInformation?.countryRank;

    final bool isCountry =
        viewModel.selectedCustomer?.type == CustomerType.country;

    String initialValue;

//Valid rank: not null, not "null", not 0
    final bool hasValidRank = countryRank != null &&
        countryRank.toString().trim().toLowerCase() != "null" &&
        countryRank.toString() != "0";

    if (hasValidRank) {
      initialValue = countryRank.toString();
    } else if (isCountry) {
      initialValue = "NA";
    } else {
      initialValue = "";
    }
    final bool isValid = !viewModel.canEdit;
    // initialValue.trim().isNotEmpty;

    return LabelWidget(
      isRequired: !isCountry, // Not mandatory for country
      label: "customerInformation.customerInformation.fiCountryRank".tr(),
      child: CustomTextField(
        key: const ValueKey("fiCountryRank"),
        maxLength: 10,
        semanticLabel:
            "customerInformation.customerInformation.fiCountryRank".tr(),
        filled: isValid,
        readOnly: isValid,
        // Mandatory only when NOT country AND FI flow
        // validator: (viewModel.isFI && !isCountry)
        //     ? CustomValidator.requiredField
        //     : null,
        validator: (value) {
          final text = value?.trim() ?? "";

          if (viewModel.isFI && !isCountry && text.isEmpty) {
            return CustomValidator.requiredField(text);
          }

          if (isCountry) {
            if (text.isEmpty) {
              return null;
            }

            // Allow only NA or number
            final isValid =
                text.toUpperCase() == "NA" || int.tryParse(text) != null;

            if (!isValid) {
              return "Only numeric or NA allowed";
            }
          }

          return null;
        },

        initialValue: initialValue,
        //  Formatter logic based on type
        inputFormatters: isCountry
            ?
            // Allow alphanumeric (for NA, etc.)
            // FilteringTextInputFormatter.allow(
            //  RegExp(r"^(NA|na|Na|nA)$"),
            // ),
            null
            : [
                //  Only digits for non-country
                FilteringTextInputFormatter.digitsOnly,
              ],

        keyboardType: isCountry ? TextInputType.text : TextInputType.number,

        onSaved: (value) {
          final text = value?.trim() ?? "";

          if (isCountry) {
            // Store as entered (NA or any alphanumeric)
            viewModel.customerInformation?.countryRank =
                (text == "NA") ? 0 : int.tryParse(text);
          } else {
            // Store numeric value only
            viewModel.customerInformation?.countryRank = int.tryParse(text);
          }
        },
      ),
    );
  }
}
