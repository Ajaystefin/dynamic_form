import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class DeferredTill extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const DeferredTill({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'security.createSecurity.deferredTill'.tr(),
          exponent: "#",
          child: CustomDatePicker(firstDate: DateTime.now(), // Disables all past dates
            onSubmit2: (DateTime? selectedDate) {
              viewModel.security.deferredDate = selectedDate;
            },
          ),
        )
      ],
    );
  }
}
