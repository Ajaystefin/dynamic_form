import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart';

class FacilitiesWithCbdCommnets extends StatelessWidget {
  final FacilitiesWithOtherBanksViewModel viewModel;
  final FacilitiesWithOtherBanksState state;
  const FacilitiesWithCbdCommnets(
      {super.key, required this.viewModel, required this.state});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithCBD.comments".tr(),
      child: CustomTextArea(
        semanticLabel:"groupInformation.facilitiesWithCBD.comments".tr(),
        maxLines: 10,
        minLines: 8,
        maxLength: 5000,
        initialValue: viewModel.strategyComment,
        onSaved: (String? value) {
          viewModel.strategyComment = value;
        },
      ),
    );
  }
}
