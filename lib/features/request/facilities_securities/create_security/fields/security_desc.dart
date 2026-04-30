import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class SecurityDescription extends StatelessWidget {
  const SecurityDescription({
    required this.viewModel,
    super.key,
  });
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Security Description",
      isRequired: !viewModel.isFIFlow,
      child: CustomTextField(
        initialValue: viewModel.security.securityType?.name ??
            viewModel.securityReferenceData
                .firstWhere(
                  (e) => e.reference3 == (viewModel.security.securityCode),
                  orElse: Reference.new,
                )
                .name ??
            "",
        readOnly: true,
        filled: true,
        onSaved: (String? value) {
          viewModel.security.securityType?.name = value;
        },
      ),
    );
  }
}
