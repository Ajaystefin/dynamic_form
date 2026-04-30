import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";

class AddGuarantorSection extends StatelessWidget {
  const AddGuarantorSection({
    required this.viewModel,
    super.key,
  });
  final GuarantorFinancialViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GuarantorFinancialViewModel>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButton(
          label: "remarks.guarantorFinancials.addGuarantor".tr(),
          semanticLabel: "remarks.guarantorFinancials.addGuarantor".tr(),
          leadingIcon: const Icon(Icons.add, color: Colors.white),
          onPressed: viewModel.isReadOnlyMode
              ? null
              : viewModel.isFI
                  ? null
                  : viewModel.onAddTap,
        ),
        const Gap(size: GapSize.medium),
        if (state.nextCanDelete)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSelectableText(
                text: "remarks.guarantorFinancials.entityId".tr(),
                semanticsLabel: "remarks.guarantorFinancials.entityId".tr(),
                style: AppStyle.tableHeaderStyle,
              ),
              const Gap(size: GapSize.small),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextField(
                    readOnly: viewModel.isReadOnlyMode,
                    width: AppStyle.groupBorrowersTextField,
                    semanticLabel: state.currentEntityId.toString(),
                    onChanged: viewModel.updateEntityIdDraft,
                    fillColor: AppColors.textFieldDisabledFill,
                    initialValue: "",
                  ),
                  const Gap(direction: Axis.horizontal),
                  // Search button
                  CustomButton(
                    label: "remarks.guarantorFinancials.search".tr(),
                    semanticLabel: "remarks.guarantorFinancials.search".tr(),
                    onPressed: viewModel.isReadOnlyMode
                        ? null
                        : () async {
                            await viewModel.searchOnAddGuarantor();
                          },
                  ),
                  const Gap(direction: Axis.horizontal),
                  CustomButton(
                    label: "remarks.guarantorFinancials.cancel".tr(),
                    semanticLabel: "remarks.guarantorFinancials.cancel".tr(),
                    onPressed: () {
                      viewModel.cancelAddGuarantor(); //emit from ViewModel
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
