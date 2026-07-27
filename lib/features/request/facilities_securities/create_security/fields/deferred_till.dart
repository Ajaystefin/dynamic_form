import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing the deferred till value.
class DeferredTill extends StatelessWidget {
  /// Creates a deferred till widget.
  const DeferredTill({
    required this.viewModel,
    super.key,
  });

  /// View model containing deferred till data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "security.createSecurity.deferredTill".tr(),
          exponent: "#",
          child: CustomDatePicker(
            ignoreProvider: viewModel.isCmoUpdate(),
            initialDateTime: viewModel.security.deferredDate,

            firstDate: DateTime.now(), // Disables all past dates
            onSubmit2: (DateTime? selectedDate) {
              viewModel.security.deferredDate = selectedDate;
            },
          ),
        ),
      ],
    );
  }
}
