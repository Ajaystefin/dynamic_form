import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';

class AddGuarantorSection extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;

  const AddGuarantorSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GuarantorFinancialViewModel>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButton(
          label: 'remarks.guarantorFinancials.addGuarantor'.tr(),
          semanticLabel: 'remarks.guarantorFinancials.addGuarantor'.tr(),
          leadingIcon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            viewModel.onAddTap();
          },
        ),
        const Gap(size: GapSize.medium),
        // When nextCanDelete is true, show the Entity‐ID + Search row below
        if (state.nextCanDelete)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSelectableText(
                text: 'remarks.guarantorFinancials.entityId'.tr(),
                semanticsLabel: 'remarks.guarantorFinancials.entityId'.tr(),
                style: AppStyle.tableHeaderStyle,
              ),
              const Gap(size: GapSize.small),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextField(
                    width: AppStyle.groupBorrowersTextField,
                    initialValue: state.currentEntityId.toString(),
                    semanticLabel: state.currentEntityId.toString(),
                    onChanged: viewModel.updateEntityId,
                    fillColor: AppColors.textFieldDisabledFill,
                  ),
                  const Gap(direction: Axis.horizontal),
                  // Search button
                  CustomButton(
                    key: UniqueKey(),
                    label: 'remarks.guarantorFinancials.search'.tr(),
                    semanticLabel: 'remarks.guarantorFinancials.search'.tr(),
                    onPressed: () async {
                      await viewModel.searchOnAddGuarantor();
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
