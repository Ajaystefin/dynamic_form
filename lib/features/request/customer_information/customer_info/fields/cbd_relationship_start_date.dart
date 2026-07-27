import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// CBD relationship start date field for the customer information screen.
class CBDRelationshipStartDateField extends StatelessWidget {
  /// Creates a CBD relationship start date field.
  const CBDRelationshipStartDateField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.relatnStartDate ?? "";
    //final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;
    return LabelWidget(
      label: "customerInformation.customerInformation.cbdRelationshipStartDate"
          .tr(),
      child: CustomTextField(
        key: const ValueKey("cbdRelationshipStartDate"),
        semanticLabel:
            "customerInformation.customerInformation.cbdRelationshipStartDate"
                .tr(),
        initialValue: DateTimeUtils.getDateAsString(initialValue),
        filled: true,
        readOnly: true,
        onSaved: (value) {
          viewModel.customerInformation?.relatnStartDate =
              DateTimeUtils.convertUIDateToISO(value);
        },
      ),
    );
  }
}
