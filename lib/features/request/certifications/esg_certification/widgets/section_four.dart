import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/label_radio_button.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

class SectionFour extends StatelessWidget {
  const SectionFour({required this.viewModel, super.key});
  final EsgCertificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String adverseMediaSummary = viewModel.adverseMediaSummary;
    final bool isAdverse = viewModel.isAdverseMedia == true;
    final String selectedAdverseLabel = isAdverse
        ? "certification.esgCertification.yes".tr()
        : "certification.esgCertification.no".tr();

    // Build the table rows from the view model
    final List<List<Widget>> dynamicRows = [];

    final List<FacilityRiskRating> ratings = viewModel.facilitiesRiskRatings;
    if (ratings.isNotEmpty) {
      // Group by borrowerRim (string)
      final Map<String, List<FacilityRiskRating>> grouped = {};
      for (final FacilityRiskRating risk in ratings) {
        final String? rim = risk.borrowerRim;
        if (rim == null || rim.isEmpty) {
          // Skip if borrowerRim is missing
          continue;
        }
        grouped.putIfAbsent(rim, () => []).add(risk);
      }

      // Build rows: header per rim, then each facility under it
      grouped.forEach((rimName, riskItems) {
        // Rim header row (4 columns to align with detail rows)
        dynamicRows.add([
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              rimName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ]);

        for (final FacilityRiskRating riskItem in riskItems) {
          final List<EskRiskRatingFacilityDto> facilities =
              riskItem.eSRiskRatingFacilityDto ?? const [];

          for (final EskRiskRatingFacilityDto dto in facilities) {
            dynamicRows.add([
              Align(
                alignment: Alignment.centerRight,
                child: Text(dto.facilityName?.capitalizeFirstLetter() ?? "—"),
              ),
              Center(child: Text(dto.sicCode?.capitalizeFirstLetter() ?? "—")),
              Center(child: Text(dto.esRating?.capitalizeFirstLetter() ?? "—")),
              Center(
                child: Text(
                  dto.pctTotalLimit != null
                      ? "${dto.pctTotalLimit!.toStringAsFixed(2)}%"
                      : "—",
                ),
              ),
            ]);
          }
        }
      });
    }

    final int sec4Id = viewModel.sectionIdAt(3);
    final String headerTitle =
        sec4Id != 0 ? (viewModel.sectionTitles![3].name ?? "").tr() : "";

    // Titles for the two sub-parts (you already have 4 and 5 in sectionTitles)
    final String part1Title = (viewModel.sectionTitles!.length > 4)
        ? (viewModel.sectionTitles![4].name ?? "")
        : "";
    final String part2Title = (viewModel.sectionTitles!.length > 5)
        ? (viewModel.sectionTitles![5].name ?? "")
        : "";

    final String part1Guidelines =
        (sec4Id != 0) ? viewModel.guidelinesForSectionPart(sec4Id, "SEC1") : "";
    final String part2Guidelines =
        (sec4Id != 0) ? viewModel.guidelinesForSectionPart(sec4Id, "SEC2") : "";

    // Get guidance subsets by part key
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(title: headerTitle),
          const Gap(),

          // Part 1
          Text(
            part1Title,
            semanticsLabel: "certification.esgCertification.partOne".tr(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Gap(size: GapSize.small),

          //part 1 ---table
          CustomRawTable(
            key: UniqueKey(),
            rowHeight: 48,
            columns: [
              TableColumn(
                label: Text("certification.esgCertification.facilityName".tr()),
              ),
              TableColumn(
                label: Text("certification.esgCertification.sic".tr()),
              ),
              TableColumn(
                label: Text("certification.esgCertification.eandSRating".tr()),
              ),
              TableColumn(
                label: Text(
                  "certification.esgCertification.totalProposedFacilityLimit"
                      .tr(),
                ),
              ),
            ],
            rows: dynamicRows,
          ),

          GuidelinesSection(
            headerText:
                "certification.esgCertification.additionalGuidnaceText".tr(),
            guidelines: part1Guidelines,
          ),
          const Gap(),
          // Part 2
          Text(
            part2Title,
            semanticsLabel: "certification.esgCertification.partTwo".tr(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Gap(
            size: GapSize.medium,
          ),

          LabeledRadioButton(
            enabled: !viewModel.isReadOnly,
            isRequired: !viewModel.isFI,
            label: "certification.esgCertification.adverseMedia".tr(),
            options: [
              "certification.esgCertification.yes".tr(),
              "certification.esgCertification.no".tr(),
            ],
            selectedValue: selectedAdverseLabel,
            onChanged: (value) {
              viewModel.updateAdverseMedia(value);
              if (value == "certification.esgCertification.no".tr()) {
                viewModel.updateAdverseMediaSummary("");
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
                  label: "certification.esgCertification.summaryDetails".tr(),
                  isRequired: !viewModel.isFI,
                ),
                const Gap(size: GapSize.large),
                CustomTextArea(
                  readOnly: viewModel.isReadOnly,
                  semanticLabel:
                      "certification.esgCertification.summaryDetails".tr(),
                  validator:
                      (viewModel.isFI) ? null : CustomValidator.requiredField,
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
                "certification.esgCertification.additionalGuidnaceText".tr(),
            guidelines: part2Guidelines,
          ),
          const Gap(),
        ],
      ),
    );
  }
}
