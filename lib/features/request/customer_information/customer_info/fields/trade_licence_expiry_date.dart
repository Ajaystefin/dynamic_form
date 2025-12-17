import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class TradeLicenceExpiryDateField extends StatelessWidget {
  const TradeLicenceExpiryDateField({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    // final bool isValid = !viewModel.canEdit &&
    //     viewModel.customerInformation?.tlExpiryDate != null;
    return LabelWidget(
      label: "customerInformation.customerInformation.tlExpiryDate".tr(),
      child: CustomDatePicker(
          semanticLabel:
              "customerInformation.customerInformation.tlExpiryDate".tr(),
          initialDateTime: DateTimeUtils.parseDateTime(
            viewModel.customerInformation?.tlExpiryDate ?? "",
            format: 'yyyy-MM-ddTHH:mm:ss',
          ),
          // isEnabled: isValid,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          onSubmit: (value) {
            viewModel.customerInformation?.tlExpiryDate =
                DateTimeUtils.convertUIDateToISO(value);
            viewModel.isDateValid;
          },
          validator: (value) {
            final error = viewModel.checkTlDateAlert(value);
            return error; // If null, validation passes; if not null, shows error message
          }),
    );
  }
}
