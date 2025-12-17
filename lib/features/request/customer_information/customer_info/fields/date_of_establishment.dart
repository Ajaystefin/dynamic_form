import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class DateOfEstablishmentField extends StatelessWidget {
  const DateOfEstablishmentField({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.establishmentDate ?? '';
    //final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;
    return LabelWidget(
      label: "customerInformation.customerInformation.dateOfEstablishment".tr(),
      child: CustomTextField(
          semanticLabel:
              "customerInformation.customerInformation.dateOfEstablishment"
                  .tr(),
          initialValue: DateTimeUtils.getDateAsString(initialValue),
          filled: true,
          readOnly: true,
          onSaved: (value) {
            viewModel.customerInformation?.establishmentDate =
                DateTimeUtils.convertUIDateToISO(value);
          }),
    );
  }
}
