import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';

class DateAuditedFS extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const DateAuditedFS({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.dateAuditedFS'.tr(),
      isRequired: true,
      child: CustomDatePicker(
        semanticLabel: 'ccsys.customerInformation.dateAuditedFS'.tr(),
        onSubmit2: (DateTime? selectedDate) {
          viewModel.customerInformation.dateAuditedFS = DateTimeUtils.datetimeToInt(selectedDate);
        },
        validator: CustomValidator.date,
      ),
    );
  }
}
