import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class PolicyDeviations extends StatelessWidget {
  PolicyDeviations({required this.viewModel, super.key});

  final CustomerInfoViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double largeExposureAmtLimit = viewModel
        .calculateLargeExposureLimitAmountValues(viewModel.referenceData);
    final double largeExposurePercentage = viewModel
        .calculateLargeExposureLimitPercentageValues(viewModel.referenceData);
    // final double largeExposureLimit =
    // viewModel.calculateLargeExposureLimit(viewModel.referenceData);
    final List<Reference> selected =
        viewModel.customerInformation?.policyDeviations ?? const <Reference>[];

    final Set<String> normalized = selected
        .map((e) => e.name?.trim().toLowerCase())
        .whereType<String>()
        .toSet();

    return LabelWidget(
      label: "customerInformation.customerInformation.policyDeviations".tr(),
      child: CustomMultiSelectDropdown<Reference>(
        semanticLabel:
            "customerInformation.customerInformation.policyDeviations".tr(),
        filterFn: (item, filter) {
          final String name = (item.name ?? "").toLowerCase();
          final String selectedFilter = filter.toLowerCase();
          return name.contains(selectedFilter);
        },
        compareFn: (a, b) {
          final String? filterItemOld = a.name?.trim().toLowerCase();
          final String? filterItemNew = b.name?.trim().toLowerCase();
          return filterItemOld == filterItemNew;
        },
        key: ValueKey(viewModel.customerInformation?.policyDeviations?.length),
        isSearchable: true,
        isEnabled: viewModel.canEdit,
        items: viewModel.policyDeviation
            .distinctBy((e) => e.name?.trim().toLowerCase())
            .toList(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            controller: _scrollController,
            key: ValueKey(
              viewModel.customerInformation?.policyDeviations?.length,
            ),
            itemBuilder: (index) {
              final item = data[index];
              final bool isLargeExposure = item.name?.toLowerCase() ==
                  ServerConstants.largeExposureBreachName;
              return isLargeExposure
                  ? CustomTooltip(
                      message: "customerInformation.customerInformation."
                              "largeExposureLimitTooltip"
                          .tr(
                        namedArgs: {
                          "amount": largeExposureAmtLimit.toStringAsFixed(2),
                          "percentage":
                              largeExposurePercentage.toStringAsFixed(2),
                        },
                      ),
                      // message: '${'customerInformation.customerInformation.largeExposureLimit'.tr()}\n'
                      //     'AED ${largeExposureLimit.toStringAsFixed(2)}\n'
                      //     '(${largeExposureAmtLimit.toStringAsFixed(2)} x '
                      //     '${largeExposurePercentage.toStringAsFixed(2)}%)',
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
        selectedItems: viewModel.policyDeviation
            .where((opt) => normalized.contains(opt.name?.trim().toLowerCase()))
            .toList(),
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

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
