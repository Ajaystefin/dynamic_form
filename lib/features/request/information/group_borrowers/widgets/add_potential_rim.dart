import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/model.dart";

class AddRimSection extends StatelessWidget {
  const AddRimSection({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupBorrowersViewModel viewModel =
        context.watch<GroupBorrowersViewModel>();

    final String rimInput = viewModel.addRimInput ?? "";
    return BoxLayout(
      child: SectionBackground(
        child: ConstrainedBox(
          // ← limit max width
          constraints: const BoxConstraints(
            maxWidth: AppStyle.groupBorrowersRimSection,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: LabelWidget(
                      label:
                          "requestInformation.groupBorrowers.customerRim".tr(),
                      isRequired: true,
                      child: CustomTextField(
                        width: AppStyle.groupBorrowersTextField,
                        initialValue: viewModel.addRimInput ?? "",
                        maxLength: 15,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: CustomValidator.requiredField,
                        fillColor: AppColors.textFieldDisabledFill,
                        onChanged: viewModel.updateAddRimInput,
                      ),
                    ),
                  ),
                  const Gap(size: GapSize.large),
                  const Gap(
                    direction: Axis.horizontal,
                  ), // stays the same fixed gap
                  Flexible(
                    fit: FlexFit.loose,
                    child: LabelWidget(
                      label:
                          "requestInformation.groupBorrowers.customerName".tr(),
                      child: CustomTextField(
                        width: AppStyle.groupBorrowersTextField,
                        controller: viewModel.customerNameController,
                        readOnly: true,
                        filled: true,
                        fillColor: AppColors.tableActivatedColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(size: GapSize.medium),

              // Search button
              CustomButton(
                label: "requestInformation.groupBorrowers.search".tr(),
                onPressed: () async {
                  await viewModel.searchCustomerByRim(rimInput);
                },
              ),
              const Gap(size: GapSize.medium),
              // Add / Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Add button
                  CustomButton(
                    label: "requestInformation.groupBorrowers.add".tr(),
                    onPressed: viewModel.canAddPotentialBorrower
                        ? viewModel.addPotentialBorrower
                        : null, // disabled state
                  ),
                  const Gap(direction: Axis.horizontal),
                  CustomButton(
                    label: "requestInformation.groupBorrowers.cancel".tr(),
                    onPressed: () {
                      viewModel.cancelAddPotentialRimSection();
                    },
                  ),
                ],
              ),
              const Gap(size: GapSize.medium),
            ],
          ),
        ),
      ),
    );
  }
}
