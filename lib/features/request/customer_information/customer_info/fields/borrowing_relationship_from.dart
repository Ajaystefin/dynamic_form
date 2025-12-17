import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class BorrowingRelationshipFromField extends StatelessWidget {
  const BorrowingRelationshipFromField({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    String initialValue = '';
    final rawDate = viewModel.customerInformation?.borrowRelationShipDate;

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        // Try parsing ISO format
        final date = DateTime.tryParse(rawDate);
        if (date != null) {
          initialValue = DateFormat('dd/MM/yyyy').format(date);
        } else {
          // Try parsing timestamp
          final timestamp = int.tryParse(rawDate);
          if (timestamp != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
            initialValue = DateFormat('dd/MM/yyyy').format(date);
          } else {
            initialValue = ''; // fallback
          }
        }
      } catch (e) {
        initialValue = '';
      }
    }

    return LabelWidget(
      label: "customerInformation.customerInformation.borrowingRelationshipFrom"
          .tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.borrowingRelationshipFrom"
                .tr(),
        initialValue: initialValue,
        // filled: viewModel.canEdit,
        // readOnly: viewModel.canEdit,
        onSaved: (value) {
          // Convert back to ISO format for validation
          try {
            final parsed = DateFormat('dd/MM/yyyy').parseStrict(value ?? '');
            viewModel.customerInformation?.borrowRelationShipDate =
                DateFormat('yyyy-MM-dd').format(parsed);
          } catch (e) {
            viewModel.customerInformation?.borrowRelationShipDate = value;
          }
        },
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : CustomValidator.requiredField,
      ),
    );
  }
}
