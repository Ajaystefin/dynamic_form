import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart";

/// CBRB comments field widget.
class CbrbCommnets extends StatelessWidget {
  /// Creates a [CbrbCommnets] widget.
  const CbrbCommnets({required this.viewModel, required this.state, super.key});

  /// View model used by the widget.
  final FacilitiesWithOtherBanksViewModel viewModel;

  /// State used by the widget.
  final FacilitiesWithOtherBanksState state;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithCBD.comments".tr(),
      child: CustomTextArea(
        readOnly: !viewModel.canEdit,
        maxLength: 5000,
        controller: viewModel.strategyCommentCBRBController,
        onSaved: (String? value) {
          viewModel.strategyCommentCBRB = value;
        },
      ),
    );
  }
}
