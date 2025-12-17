import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/admin/user_detail/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';

class UserAccessToCustomerSegment extends StatelessWidget {
  const UserAccessToCustomerSegment({super.key, required this.viewModel});
  final UserDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'admin.userManagementDetail.accessToCustomerSegment'.tr(),
          isRequired: false,
          showLabel: true,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            // color: AppColors.black,
          ),
          child: CustomMultiSelectDropdown<Reference>(
            semanticLabel:'admin.userManagementDetail.accessToCustomerSegment'.tr(),
              showClear: true,
              isMultiLine: true,
              validationMessage: "common.validation.emptyField".tr(),
              items: viewModel.referenceData[ReferenceDataKeys.segmentType] ?? [],
              onSelected: (selectedValue) {
                viewModel.userAccessToCustomerSegmentValues = selectedValue;
                viewModel.onSelectedSegments(selectedValue); // update segments
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  title: buildItemText(
                      item.name, FontSizeHelper(size: FontSize.medium)),
                );
              },
              dropdownBuilder: (context, data) {
                final chips = List.generate(data!.length, (index) {
                  return Chip(
                    deleteIcon: const Icon(Icons.clear, size: 16),
                    onDeleted: () {
                      viewModel.onUserRegionDeleted(index);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: 1,
                      ),
                    ),
                    backgroundColor: AppColors.textFieldDisabledFill,
                    label: buildItemText(
                        data[index].name, FontSizeHelper(size: FontSize.small)),
                  );
                });

                return Wrap(spacing: 4, runSpacing: 4, children: chips);
              },
              isSearchable: true,
              // isEnabled: viewModel.userAccessToCustomerSegments != null,
              selectedItems: viewModel.userAccessToCustomerSegmentValues),
        ),
      ],
    );
  }
}
