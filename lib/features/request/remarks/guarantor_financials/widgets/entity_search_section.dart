import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/state.dart';

class EntitySearchSection extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;
  final GuarantorFinancialState state;
  final bool showDeleteButton;
  final FocusNode entityFocus;

  const EntitySearchSection(
      {super.key,
      required this.viewModel,
      required this.entityFocus,
      required this.state,
      required this.showDeleteButton});

  @override
  Widget build(BuildContext context) {
    final canDeleteSection = showDeleteButton && state.canDeleteSection;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSelectableText(
          text: 'remarks.guarantorFinancials.entityId'.tr(),
          semanticsLabel: 'remarks.guarantorFinancials.entityId'.tr(),
          style: AppStyle.tableHeaderStyle,
        ),
        const Gap(size: GapSize.small),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              focusNode: entityFocus,
              width: AppStyle.groupBorrowersTextField,
              onChanged: viewModel.updateEntityId,
              fillColor: AppColors.textFieldDisabledFill,
            ),
            const Gap(direction: Axis.horizontal),
            // Search
            CustomButton(
                key: UniqueKey(),
                label: 'remarks.guarantorFinancials.search'.tr(),
                semanticLabel: 'remarks.guarantorFinancials.search'.tr(),
                onPressed: () async {
                  await viewModel.searchEntity();
                }),

            const Spacer(),

            CustomButton(
              label: 'remarks.guarantorFinancials.goToSpreadSmart'.tr(),
              semanticLabel: 'remarks.guarantorFinancials.goToSpreadSmart'.tr(),
              onPressed: () async {
                // 1. Grab the latest list
                final list = state.guarantors;

                final urlString = list.first.spreadsmartUrl;
                final uri = Uri.tryParse(urlString);
                if (uri == null || !uri.hasScheme) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      'remarks.guarantorFinancials.invalidUrl$urlString'.tr(),
                      semanticsLabel:
                          'remarks.guarantorFinancials.invalidUrl$urlString'
                              .tr(),
                    )),
                  );
                  return;
                }

                if (!await canLaunchUrl(uri)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'remarks.guarantorFinancials.cannotLaunchUrl'
                                  .tr(),
                              semanticsLabel:
                                  'remarks.guarantorFinancials.cannotLaunchUrl'
                                      .tr())),
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
                onPressed: () {
                  final index = state.guarantors
                      .indexWhere((guarantor) => guarantor.canDelete);
                  if (index != -1) {
                    viewModel.removeGuarantor(index);
                  }
                },
                backgroundColor: Colors.red,
              ),
          ],
        ),
      ],
    );
  }
}
