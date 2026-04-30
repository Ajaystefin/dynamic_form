import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";

class DateAuditedFS extends StatelessWidget {
  const DateAuditedFS({
    required this.viewModel,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    debugPrint("DateAuditedFS build; VM date = "
        "${viewModel.customerInformation.dateAuditedFs?.toIso8601String()}");

    return LabelWidget(
      label: "ccsys.customerInformation.dateAuditedFS".tr(),
      isRequired: viewModel.canEdit,
      child: CustomDatePicker(
        key: ValueKey(
          viewModel.customerInformation.dateAuditedFs?.millisecondsSinceEpoch ??
              -1,
        ),
        semanticLabel: "ccsys.customerInformation.dateAuditedFS".tr(),
        initialDateTime: viewModel.customerInformation.dateAuditedFs,
        isMaualEdit: true,
        lastDate: DateTime.now(),
        onSubmit2: (DateTime? selectedDate) {
          if (selectedDate == null) return; // don't wipe a restored value
          viewModel.customerInformation.dateAuditedFs =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        },
        onSaved: (DateTime? selectedDate) {
          if (selectedDate == null) return; // don't wipe a restored value
          viewModel.customerInformation.dateAuditedFs =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        },
        validator: (!viewModel.canEdit)
            ? null
            : (value) => viewModel.checkAuditedFsDate(
                  value,
                  isToday: true,
                  isDateFs: true,
                ),
      ),
    );
  }
}
