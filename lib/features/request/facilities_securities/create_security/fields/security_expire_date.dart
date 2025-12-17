import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityExpireDate extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityExpireDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'security.createSecurity.securityExpireDate'.tr(),
          exponent: "#",
          isRequired: true,
          child: CustomDatePicker(
            initialDateTime:
                (viewModel.security.isSecurityExpiryOpenEnded ?? false)
                    ? DateTime(2099, 12, 30)
                    : viewModel.security.securityExpireDate,
            firstDate: DateTime.now(),
            isEnabled: !(viewModel.security.isSecurityExpiryOpenEnded ?? false),
            // onSaved: (DateTime? selectedDate) {
            //   // viewModel.security.securityExpireDate = selectedDate;
            // },
            validator: CustomValidator.date,
          ),
        )
      ],
    );
  }
}
