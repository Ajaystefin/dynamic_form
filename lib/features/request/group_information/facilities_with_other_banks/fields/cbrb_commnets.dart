import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart';

class CbrbCommnets extends StatelessWidget {
  final FacilitiesWithOtherBanksViewModel viewModel;
  final FacilitiesWithOtherBanksState state;
  const CbrbCommnets({super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithCBD.comments".tr(),
      child: CustomTextArea(
        maxLength: 5000,
        initialValue: viewModel.strategyCommentCBRB,
        onSaved: (String? value) {
          viewModel.strategyCommentCBRB = value;
        },
      ),
    );
  }
}
