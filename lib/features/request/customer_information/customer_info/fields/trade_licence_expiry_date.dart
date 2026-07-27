import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Trade licence expiry date field for the customer information screen.
class TradeLicenceExpiryDateField extends StatelessWidget {
  /// Creates a trade licence expiry date field.
  const TradeLicenceExpiryDateField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool isValid = !viewModel.canEdit &&
    //     viewModel.customerInformation?.tlExpiryDate != null;
    return LabelWidget(
      label: "customerInformation.customerInformation.tlExpiryDate".tr(),
      child: CustomDatePicker(
        isEnabled: viewModel.canEdit,
        key: const ValueKey(
          "customerInformation.customerInformation.tlExpiryDate",
        ),
        semanticLabel:
            "customerInformation.customerInformation.tlExpiryDate".tr(),
        initialDateTime: DateTimeUtils.parseDateTime(
          viewModel.customerInformation?.tlExpiryDate ?? "",
          format: "yyyy-MM-ddTHH:mm:ss",
        ),
        // isEnabled: isValid,
        firstDate: DateTime.now().add(const Duration(days: 1)),
        onSubmit: (value) {
          viewModel.customerInformation?.tlExpiryDate =
              DateTimeUtils.convertUIDateToISO(value);
          // viewModel.isDateValid;
        },
        validator: (value) {
          if (!viewModel.isFI) {
            final error = viewModel.checkTlDateAlert(value);
            // If null, validation passes; if not null, shows error message
            return error;
          }
          return null;
        },
      ),
    );
  }
}
