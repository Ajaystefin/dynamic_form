import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

/// Displays the audited financial statement date field for CCSYS customer information.
class DateAuditedFS extends StatelessWidget {
  /// Creates the audited financial statement date field widget.
  const DateAuditedFS({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage audited financial statement date and edit access.
  final CustomerInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    logger.i("DateAuditedFS build; VM date = "
        "${viewModel.customerInformation.dateAuditedFs?.toIso8601String()}");

    return CcsysTootltip(
      message: "ccsys.customerInformation.tooltip.dateofAuditedFSTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.dateAuditedFS".tr(),
        isRequired: viewModel.canEdit,
        child: CustomDatePicker(
          isEnabled: viewModel.canEdit,
          key: ValueKey(
            viewModel.customerInformation.dateAuditedFs
                    ?.millisecondsSinceEpoch ??
                -1,
          ),
          semanticLabel: "ccsys.customerInformation.dateAuditedFS".tr(),
          initialDateTime: viewModel.customerInformation.dateAuditedFs,
          isMaualEdit: true,
          lastDate: DateTime.now(),
          onSubmit2: (DateTime? selectedDate) {
            if (selectedDate == null) {
              return; // don't wipe a restored value
            }
            viewModel.customerInformation.dateAuditedFs = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
            );
          },
          onSaved: (DateTime? selectedDate) {
            if (selectedDate == null) {
              return; // don't wipe a restored value
            }
            viewModel.customerInformation.dateAuditedFs = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
            );
          },
          validator: (!viewModel.canEdit)
              ? null
              : (value) => viewModel.checkAuditedFsDate(
                    value,
                    isToday: true,
                    isDateFs: true,
                  ),
        ),
      ),
    );
  }
}
