import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing policy deviations.
class PolicyDeviations extends StatelessWidget {
  /// Creates a policy deviations widget.
  PolicyDeviations({required this.viewModel, super.key});

  /// View model containing policy deviation data and actions.
  final CreateFacilityViewModel viewModel;

  /// Controller used to manage scrolling within the policy deviations view.
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double largeExposureAmtLimit = viewModel
        .calculateLargeExposureLimitAmountValues(viewModel.referenceData);
    final double largeExposurePercentage = viewModel
        .calculateLargeExposureLimitPercentageValues(viewModel.referenceData);
    // final double largeExposureLimit =
    // viewModel.calculateLargeExposureLimit(viewModel.referenceData);

    return LabelWidget(
      label: "customerInformation.customerInformation.policyDeviations".tr(),
      infoContent: "common.deviationInfo".tr(),
      child: CustomMultiSelectDropdown<Reference>(
        key: ValueKey(viewModel.getFacility.policyDeviation?.length),
        semanticLabel:
            "customerInformation.customerInformation.policyDeviations".tr(),
        filterFn: (Reference item, String filter) {
          return (item.name ?? "").toLowerCase().contains(filter.toLowerCase());
        },
        isSearchable: true,
        isEnabled: viewModel.canEdit,
        items: viewModel.policyDeviations,
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            key: ValueKey(viewModel.getFacility.policyDeviation?.length),
            data: data!,
            controller: _scrollController,
            itemBuilder: (index) {
              final Reference item = data[index];
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
        onSelected: (selectedValue) {
          viewModel.onPolicyDeviationSelected(selectedValue);
        },
        selectedItems: viewModel.getFacility.policyDeviation,
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

/// Adds utility methods for filtering unique elements in an iterable.
extension DistinctBy<T> on Iterable<T> {
  /// Returns the first occurrence of each element based on the key returned
  /// by [keySelector].
  ///
  /// Elements with duplicate keys are excluded from the result.
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
