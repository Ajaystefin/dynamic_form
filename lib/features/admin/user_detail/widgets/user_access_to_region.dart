import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays and manages region access for a user.
class UserAccessToRegion extends StatelessWidget {
  /// Creates a [UserAccessToRegion] widget.
  UserAccessToRegion({required this.viewModel, super.key});

  /// View model used to manage selected region access values.
  final UserDetailViewModel viewModel;

  final ScrollController _scrollController = ScrollController();

  /// Builds the region access multi-select dropdown.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "admin.userManagementDetail.accessToRegion".tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          child: CustomMultiSelectDropdown<Reference>(
            key: ValueKey(
              viewModel.userAccessToRegionValues?.map((e) => e.name).join("|"),
            ),
            semanticLabel: "admin.userManagementDetail.accessToRegion".tr(),
            filterFn: (Reference item, String filter) {
              return (item.name ?? item.toString())
                  .toLowerCase()
                  .contains(filter.toLowerCase());
            },
            compareFn: (a, b) {
              final String? filterItemOld = a.name?.trim().toLowerCase();
              final String? filterItemNew = b.name?.trim().toLowerCase();
              return filterItemOld == filterItemNew;
            },
            showClear: true,
            isMultiLine: true,
            validationMessage: "common.validation.emptyField".tr(),
            items: viewModel.referenceData[ReferenceDataKeys.regionList] ?? [],
            onSelected: (selectedValue) {
              viewModel.userAccessToRegionValues = selectedValue;
              viewModel.onSelectedRegion(selectedValue); // update regions
            },
            itemBuilder: (context, item, {isDisabled, isSelected}) {
              return ListTile(
                title: buildItemText(
                  item.name,
                  FontSizeHelper(size: FontSize.medium),
                ),
              );
            },
            dropdownBuilder: (context, data) {
              return multiSelectDropDownBuilderWidget(
                data: data!,
                controller: _scrollController,
                key: ValueKey(
                  viewModel.userAccessToRegionValues
                      ?.map((e) => e.name)
                      .join("|"),
                ),
                itemBuilder: (index) {
                  final item = data[index];
                  return Container(
                    margin: const EdgeInsets.all(4),
                    child: buildMultiSelectChip(
                      label: buildItemText(
                        item.name ?? "",
                        FontSizeHelper(size: FontSize.small),
                      ),
                      onDeleted: () => viewModel.onUserRegionDeleted(index),
                    ),
                  );
                },
              );
            },
            isSearchable: true,
            selectedItems: viewModel.userAccessToRegionValues,
          ),
        ),
      ],
    );
  }
}
