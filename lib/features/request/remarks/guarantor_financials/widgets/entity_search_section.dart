import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/state.dart";

class EntitySearchSection extends StatelessWidget {
  const EntitySearchSection({
    required this.viewModel,
    required this.entityFocus,
    required this.state,
    required this.showDeleteButton,
    required this.entityId,
    required this.isFirstSection,
    super.key, // N, super.key,, super.key,
  });
  final GuarantorFinancialViewModel viewModel;
  final GuarantorFinancialState state;
  final bool showDeleteButton;
  final FocusNode entityFocus;
  final int entityId;
  final bool isFirstSection;
  @override
  Widget build(BuildContext context) {
    final bool canDeleteSection = (isFirstSection &&
            (viewModel.hasSavedAnalysisData || viewModel.hasCreditLensData)) ||
        (showDeleteButton && state.canDeleteSection);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSelectableText(
          text: "remarks.guarantorFinancials.entityId".tr(),
          semanticsLabel: "remarks.guarantorFinancials.entityId".tr(),
          style: AppStyle.tableHeaderStyle,
        ),
        const Gap(size: GapSize.small),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isFirstSection)
              CustomTextField(
                readOnly: viewModel.isFI ? true : viewModel.isReadOnlyMode,
                filled: viewModel.isFI ? true : viewModel.isReadOnlyMode,
                controller: viewModel.entityController,
                width: AppStyle.groupBorrowersTextField,
                onChanged: (txt) =>
                    viewModel.updateEntityId(txt, sectionEntityId: entityId),
                fillColor: AppColors.textFieldDisabledFill,
              )
            else
              CustomTextField(
                readOnly: viewModel.isFI ? true : false,
                filled: viewModel.isFI ? true : false,
                width: AppStyle.groupBorrowersTextField,
                controller: viewModel.textControllerForSection(entityId),
                fillColor: AppColors.textFieldDisabledFill,
                onChanged: (txt) =>
                    viewModel.updatePendingEntityId(entityId, txt), //
                //
              ),

            const Gap(direction: Axis.horizontal),
            // Search
            CustomButton(
              label: "remarks.guarantorFinancials.search".tr(),
              semanticLabel: "remarks.guarantorFinancials.search".tr(),
              onPressed: viewModel.isReadOnlyMode
                  ? null
                  : viewModel.isFI
                      ? null
                      : () async {
                          await viewModel.searchEntityForSection(
                            entityId, // this section
                            isFirstSection: isFirstSection, //  pass flag
                          );
                        },
            ),

            const Spacer(),

            CustomButton(
              label: "remarks.guarantorFinancials.goToSpreadSmart".tr(),
              semanticLabel: "remarks.guarantorFinancials.goToSpreadSmart".tr(),
              onPressed: viewModel.isReadOnlyMode
                  ? null
                  : () async {
                      // 1. Grab the latest list
                      final list = state.guarantors;

                      final urlString = list.first.spreadsmartUrl;
                      final uri = Uri.tryParse(urlString);
                      if (uri == null || !uri.hasScheme) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "remarks.guarantorFinancials.invalidUrl$urlString"
                                  .tr(),
                              semanticsLabel: "remarks.guarantorFinancials"
                                      ".invalidUrl$urlString"
                                  .tr(),
                            ),
                          ),
                        );
                        return;
                      }

                      if (!await canLaunchUrl(uri)) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "remarks.guarantorFinancials.cannotLaunchUrl"
                                    .tr(),
                                semanticsLabel: "remarks.guarantorFinancials."
                                        "cannotLaunchUrl"
                                    .tr(),
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
            ),
            const Gap(direction: Axis.horizontal),
            if (canDeleteSection)
              CustomButton(
                label: "remarks.guarantorFinancials.deleteGuarantor".tr(),
                semanticLabel:
                    "remarks.guarantorFinancials.deleteGuarantor".tr(),
                onPressed: () async {
                  final int sectionEntityId = entityId;
                  await viewModel.deleteGuarantorSection(sectionEntityId);
                },
                backgroundColor: Colors.red,
              ),
          ],
        ),
      ],
    );
  }
}
