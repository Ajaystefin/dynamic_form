import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Policy Deviations field on the Request Information screen.
///
/// Allows users to view, select, or manage policy deviations
/// applicable to the current request.
class PolicyDeviations extends StatelessWidget {
  /// Creates a [PolicyDeviations].
  PolicyDeviations({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages policy deviation-related operations.
  final RequestInfoViewModel viewModel;

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final double largeExposureAmtLimit = viewModel
        // .calculateLargeExposureLimit(viewModel.referenceData);
        .calculateLargeExposureLimitAmountValues(viewModel.referenceData);
    final double largeExposurePercentage = viewModel
        .calculateLargeExposureLimitPercentageValues(viewModel.referenceData);
    final List<Reference> selected =
        viewModel.applicationDetails?.policyDeviations ?? const <Reference>[];

    ///SUPPORT BOTH ID + NAME
    final Set<String> normalizedIds =
        selected.map((e) => e.id?.toString()).whereType<String>().toSet();

    final Set<String> normalizedNames = selected
        .map((e) => e.name?.trim().toLowerCase())
        .whereType<String>()
        .toSet();

    return LabelWidget(
      label: "requestInformation.requestInformation.policyDeviations".tr(),
      infoContent: "common.deviationInfo".tr(),
      child: CustomMultiSelectDropdown<Reference>(
        /// Search by name (UI remains same)
        filterFn: (item, filter) {
          final String name = (item.name ?? "").toLowerCase();
          return name.contains(filter.toLowerCase());
        },

        ///Compare by ID (fix selection consistency)
        compareFn: (a, b) => a.id == b.id,

        key: ValueKey(viewModel.applicationDetails?.policyDeviations?.length),
        isSearchable: true,
        isEnabled: viewModel.canEdit,

        /// Remove duplicates using ID
        items: viewModel.policyDeviationItems
            .distinctBy((e) => e.id?.toString())
            .toList(),

        /// UI shows name
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            controller: _scrollController,
            key: ValueKey(
              viewModel.applicationDetails?.policyDeviations?.length,
            ),
            itemBuilder: (index) {
              final item = data[index];
              final bool isLargeExposure =
                  item.id == ServerConstants.largeExposureBreachId;
              return isLargeExposure
                  ? CustomTooltip(
                      textAlign: TextAlign.left,
                      message: "customerInformation.customerInformation."
                              "largeExposureLimitTooltip"
                          .tr(
                        namedArgs: {
                          "amount": largeExposureAmtLimit.toStringAsFixed(0),
                          "percentage":
                              largeExposurePercentage.toStringAsFixed(0),
                        },
                      ),
                      child: _buildChipWithInfoIcon(item.name ?? "", index),
                    )
                  : Container(
                      margin: const EdgeInsets.all(4),
                      child: buildMultiSelectChip(
                        label: buildItemText(
                          item.name ?? "",
                          FontSizeHelper(size: FontSize.small),
                        ),
                        onDeleted: () => viewModel.onPolicyChipDeleted(index),
                      ),
                    );
            },
          );
        },

        ///MAIN FIX: Match using ID OR NAME
        selectedItems: viewModel.policyDeviationItems.where((opt) {
          final idMatch = normalizedIds.contains(opt.id?.toString());
          final nameMatch =
              normalizedNames.contains(opt.name?.trim().toLowerCase());
          return idMatch || nameMatch;
        }).toList(),

        onSelected: (selectedValue) {
          viewModel.onPolicyDeviationSelected(selectedValue);
        },
      ),
    );
  }

  Widget _buildChipWithInfoIcon(String label, int index) {
    return buildMultiSelectChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildItemText(
            label,
            FontSizeHelper(size: FontSize.small),
          ),
          const Gap(direction: Axis.horizontal),
          const Icon(Icons.info_rounded, size: 16, color: AppColors.primary),
        ],
      ),
      onDeleted: () => viewModel.onPolicyChipDeleted(index),
    );
  }
}

/// Extension that provides utility methods for filtering
/// collections based on unique property values.
extension DistinctBy<T> on Iterable<T> {
  /// Returns the distinct elements in this iterable based on
  /// the value returned by the provided [keySelector].
  ///
  /// Only the first occurrence of each key is retained.
  /// Subsequent elements with the same key are excluded.
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
