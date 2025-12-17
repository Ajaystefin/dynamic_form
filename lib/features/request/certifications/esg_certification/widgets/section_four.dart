import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/model.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart';
import 'package:wcas_frontend/models/request/esg_certification.dart';

import 'label_radio_button.dart';

class SectionFour extends StatelessWidget {
  final EsgCertificationViewModel viewModel;
  const SectionFour({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final String adverseMediaSummary = viewModel.adverseMediaSummary;
    final bool isAdverse = viewModel.isAdverseMedia == true;
    final String selectedAdverseLabel = isAdverse
        ? "certification.esgCertification.yes".tr()
        : "certification.esgCertification.no".tr();

    List<List<Widget>> dynamicRows = [];
    if (viewModel.facilitiesRiskRatings.isNotEmpty) {
      Map<String, List<FacilityRiskRating>> grouped = {};
      for (var risk in viewModel.facilitiesRiskRatings) {
        grouped.putIfAbsent(risk.borrowerRim!, () => []).add(risk);
      }
      grouped.forEach((rimName, facilities) {
        dynamicRows.add([
          Center(
              child: Text(rimName,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ]);
        for (var facility in facilities) {
          dynamicRows.add([
            Center(child: Text(facility.facilityName!.capitalizeFirstLetter())),
            Center(child: Text(facility.sicCode!.capitalizeFirstLetter())),
            Center(child: Text(facility.esRating!.capitalizeFirstLetter())),
            Center(
                child: Text('${facility.pctTotalLimit!.toStringAsFixed(2)}%')),
          ]);
        }
      });
    }

    final String headerTitle = viewModel.sectionTitles!.length > 3
        ? viewModel.sectionTitles![3].name!.tr()
        : '';

    final String sectionGuidelines = viewModel.additionalGuidelines!.length > 1
        ? viewModel.additionalGuidelines![3].name!
        : '';
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(title: headerTitle),
          const Gap(),

          // Part 1
          Text(
            '${viewModel.additionalGuidelines![3].reference1}',
            semanticsLabel: 'certification.esgCertification.partOne'.tr(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Gap(size: GapSize.small),

          //part 1 ---table
          CustomRawTable(
            key: UniqueKey(),
            rowHeight: 48,
            columns: [
              TableColumn(
                  label:
                      Text('certification.esgCertification.facilityName'.tr())),
              TableColumn(
                  label: Text('certification.esgCertification.sic'.tr())),
              TableColumn(
                  label:
                      Text('certification.esgCertification.eandSRating'.tr())),
              TableColumn(
                  label: Text(
                      'certification.esgCertification.totalProposedFacilityLimit'
                          .tr())),
            ],
            rows: dynamicRows,
          ),

          GuidelinesSection(
            headerText:
                'certification.esgCertification.additionalGuidnaceText'.tr(),
            guidelines: sectionGuidelines,
          ),
          const Gap(),
          // Part 2
          Text(
            '${viewModel.additionalGuidelines![4].reference1}',
            semanticsLabel: 'certification.esgCertification.partTwo'.tr(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Gap(
            size: GapSize.medium,
          ),
          LabeledRadioButton(
            enabled: !viewModel.isReadOnly,
            label: 'certification.esgCertification.adverseMedia'.tr(),
            options: [
              "certification.esgCertification.yes".tr(),
              "certification.esgCertification.no".tr()
            ],
            selectedValue: selectedAdverseLabel,
            onChanged: (value) {
              viewModel.updateAdverseMedia(value);
              if (value == "certification.esgCertification.no".tr()) {
                viewModel.updateAdverseMediaSummary('');
              }
            },
          ),
          const Gap(),
          // <-- only show this when Adverse = Yes -->
          if (isAdverse)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LabelWidget(
                    label: 'certification.esgCertification.summaryDetails'.tr(),
                    isRequired: true),
                const Gap(size: GapSize.large),
                CustomTextArea(
                  readOnly: viewModel.isReadOnly,
                  semanticLabel:
                      'certification.esgCertification.summaryDetails'.tr(),
                  validator: CustomValidator.requiredField,
                  width: MediaQuery.of(context).size.width * .8,
                  maxLength: 2000,
                  initialValue: adverseMediaSummary.capitalizeFirstLetter(),
                  onChanged: viewModel.updateAdverseMediaSummary,
                  maxLines: 8,
                  minLines: 4,
                ),
              ],
            ),
          GuidelinesSection(
            headerText:
                'certification.esgCertification.additionalGuidnaceText'.tr(),
            guidelines: viewModel.additionalGuidelines!.length > 1
                ? viewModel.additionalGuidelines![4].name!
                : '',
          ),
          const Gap(),
        ],
      ),
    );
  }
}
