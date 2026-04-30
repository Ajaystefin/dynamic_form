import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

class SecurityExpireDate extends StatelessWidget {
  const SecurityExpireDate({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "security.createSecurity.securityExpireDate".tr(),
          exponent: "#",
          isRequired: !viewModel.isFIFlow,
          child: CustomDatePicker(
            initialDateTime:
                //   (viewModel.security.isSecurityExpiryOpenEnded ?? false)
                // ?
                viewModel.security.securityExpireDate ?? DateTime(2099, 12, 30),
            //: viewModel.security.securityExpireDate,
            firstDate: DateTime.now(),
            isEnabled:
                !(viewModel.security.isSecurityExpiryOpenEnded ?? false) ||
                    viewModel.isCmoUpdate(),
            onSubmit2: (DateTime? selectedDate) {
              viewModel.security.securityExpireDate = selectedDate;
            },
            onSubmit: (value) {
              final DateFormat format = DateFormat("dd/MM/yyyy");
              viewModel.security.securityExpireDate = format.parse(value!);
              logger.f(
                "Selected Expiry Date: "
                "${viewModel.security.securityExpireDate}",
              );
            },
            validator: CustomValidator.date,
          ),
        ),
      ],
    );
  }
}
