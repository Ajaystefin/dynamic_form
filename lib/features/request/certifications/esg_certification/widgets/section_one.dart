import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart";

class SectionOne extends StatelessWidget {
  const SectionOne({required this.viewModel, super.key});
  final EsgCertificationViewModel viewModel;

  static List<String> excludedLabels = [
    "certification.esgCertification.yes".tr(),
    "certification.esgCertification.no".tr(),
    "certification.esgCertification.na".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isNtb = Utils.checkApplicationType(ApplicationType.newToBank);

    // For NTB only: if still unknown (NA from API / initial state), show YES immediately
    final bool? excludedFlag =
        (isNtb && viewModel.excludedStatus == ExclusionStatus.unknown)
            ? true
            : viewModel.excludedFlag;

    final String selectedExcludedLabel = excludedFlag == true
        ? "certification.esgCertification.yes".tr()
        : excludedFlag == false
            ? "certification.esgCertification.no".tr()
            : "certification.esgCertification.na".tr();

    final List<String> sicCodes = viewModel.sicCodeLists!
        .map((ref) => ref.name ?? "")
        .where((s) => s.isNotEmpty)
        .toList();

    final List<String> filteredExcludedActivities = viewModel.excludedActivities
        .where(sicCodes.contains)
        .toList();

    final int secId = viewModel.sectionIdAt(0);
    final String headerTitle =
        secId != 0 ? (viewModel.sectionTitles![0].name ?? "") : "";
    final String sectionGuidelines =
        (secId != 0) ? viewModel.guidelinesForSectionId(secId) : "";

    final double screenWidth = MediaQuery.of(context).size.width;
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(title: headerTitle),
          const Gap(),
          LabelWidget(
            label: "certification.esgCertification.excludedText".tr(),
            isRequired: !viewModel.isFI,
          ),
          CustomDropdown<String>(
            isEnabled: !viewModel.isReadOnly,
            semanticLabel: "certification.esgCertification.excludedText".tr(),
            width: screenWidth * 0.2,
            items: excludedLabels,
            hintText: "certification.esgCertification.selectOptionHint".tr(),
            selectedItems:
                // ignore: unnecessary_null_comparison
                selectedExcludedLabel != null ? [selectedExcludedLabel] : [],
            onSelected: (labels) {
              if (labels.isNotEmpty) {
                viewModel.updateExcludedValue(labels.first);
              }
            },
          ),
          const Gap(),
          if (excludedFlag == true && sicCodes.isNotEmpty) ...[
            LabelWidget(
              label: "certification.esgCertification.listExcludedText".tr(),
              isRequired: !viewModel.isFI,
            ),
            CustomMultiSelectDropdown<String>(
              hintText: "Select",
              isEnabled: !viewModel.isReadOnly,
              semanticLabel:
                  "certification.esgCertification.listExcludedText".tr(),
              width: screenWidth * 0.42,
              items: sicCodes,
              key: ValueKey(filteredExcludedActivities.join(",")),
              selectedItems: filteredExcludedActivities,
              onSelected: viewModel.updateExcludedActivities,
              dropdownBuilder: (context, selected) {
                if (selected == null || selected.isEmpty) {
                  return const SizedBox();
                }
                final ScrollController controller = ScrollController();
                return multiSelectDropDownBuilderWidget(
                  data: selected,
                  controller: controller,
                  height: 72,
                  spacing: 4,
                  runSpacing: 4,
                  itemBuilder: (index) {
                    final String label = selected[index];
                    return Chip(
                      label: Text(label),
                      onDeleted: () {
                        final List<String> newList =
                            List<String>.from(selected)..removeAt(index);
                        viewModel.updateExcludedActivities(newList);
                      },
                    );
                  },
                );
              },
            ),
            const Gap(
              size: GapSize.medium,
            ),
          ],
          GuidelinesSection(
            headerText:
                "certification.esgCertification.additionalGuidnaceText".tr(),
            guidelines: sectionGuidelines,
          ),
          const Gap(),
        ],
      ),
    );
  }
}
