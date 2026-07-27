import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Section 1 of ESG Certification.
///
/// This section captures `Excluded Activity` and, when applicable, the
/// corresponding list of excluded SIC activities.
///
/// Visibility rules:
/// - `Yes`  -> show SIC activity multiselect
/// - `No`   -> hide SIC activity multiselect
/// - `N/A`  -> hide SIC activity multiselect
///
/// For NTB applications:
/// - the dropdown may default to `Yes` only during initial load when no
///   persisted backend value exists yet
/// - once a value has been saved, the persisted backend value must be shown
///   exactly as returned
class SectionOne extends StatelessWidget {
  /// Creates section one.
  const SectionOne({required this.viewModel, super.key});

  /// ESG certification view model.
  final EsgCertificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String yesLabel = "certification.esgCertification.yes".tr();
    final String noLabel = "certification.esgCertification.no".tr();
    final String naLabel = "certification.esgCertification.na".tr();

    final List<String> excludedLabels = [
      yesLabel,
      noLabel,
      naLabel,
    ];
    final ExclusionStatus excludedStatus = viewModel.excludedStatus;

    // Show the excluded SIC list only when the current status is explicitly Yes.
    final bool showExcludedActivities =
        excludedStatus == ExclusionStatus.excluded;
    String selectedExcludedLabel = "";

    final String rawExcludedValue =
        (viewModel.isExcluded ?? "").trim().toUpperCase();

    if (rawExcludedValue == ServerConstants.esgExcludedActivityYes ||
        viewModel.excludedStatus == ExclusionStatus.excluded) {
      selectedExcludedLabel = yesLabel;
    } else if (rawExcludedValue == ServerConstants.esgExcludedActivityNo ||
        viewModel.excludedStatus == ExclusionStatus.included) {
      selectedExcludedLabel = noLabel;
    } else if (rawExcludedValue == ServerConstants.esgExcludedActivityNa) {
      selectedExcludedLabel = naLabel;
    }

    final List<String> sicCodes = viewModel.sicCodeLists!
        .map((Reference referenceItem) => referenceItem.name ?? "")
        .where((String sicCode) => sicCode.isNotEmpty)
        .toList();

    final List<String> filteredExcludedActivities =
        viewModel.excludedActivities.where(sicCodes.contains).toList();

    const int sectionId = ServerConstants.esgSection1Id;
    final String headerTitle = viewModel.sectionTitleById(sectionId);

    final String sectionGuidelines =
        (sectionId != 0) ? viewModel.guidelinesForSectionId(sectionId) : "";

    final double screenWidth = MediaQuery.of(context).size.width;
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(
            title: headerTitle,
            enableEllipsis: true,
            maxLines: 1,
            ellipsisCharLimit: 110,
          ),
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
                selectedExcludedLabel.isNotEmpty ? [selectedExcludedLabel] : [],
            onSelected: (labels) {
              if (labels.isEmpty) {
                return;
              }

              final String selected = labels.first;

              if (selected == yesLabel) {
                viewModel.updateExcludedValueApi(
                  ServerConstants.esgExcludedActivityYes,
                );
              } else if (selected == noLabel) {
                viewModel.updateExcludedValueApi(
                  ServerConstants.esgExcludedActivityNo,
                );
              } else if (selected == naLabel) {
                viewModel.updateExcludedValueApi(
                  ServerConstants.esgExcludedActivityNa,
                );
              }
            },
            onClear: (_) {
              viewModel.clearExcludedValue();
            },
          ),
          const Gap(),

          /// The SIC activity selector is relevant only when Excluded Activity = Yes.
          /// For No and N/A, the section must remain hidden.
          if (showExcludedActivities && sicCodes.isNotEmpty) ...[
            LabelWidget(
              label: "certification.esgCertification.listExcludedText".tr(),
              isRequired: !viewModel.isFI,
            ),
            CustomMultiSelectDropdown<String>(
              hintText:
                  "certification.esgCertification.selectSicDescription".tr(),
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
                  itemBuilder: (index) {
                    final String label = selected[index];
                    return Chip(
                      label: Text(label),
                      onDeleted: () {
                        final List<String> newList = List<String>.from(selected)
                          ..removeAt(index);
                        viewModel.updateExcludedActivities(newList);
                      },
                    );
                  },
                );
              },
            ),
            const Gap(),
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
