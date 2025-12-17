import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class AllocateLimitDialogBox extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const AllocateLimitDialogBox({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final ScrollController contrlr = ScrollController();
    return BlocBuilder<CreateFacilityViewModel, CreateFacilityState>(
      builder: (context, state) {
        final viewModel = context.read<CreateFacilityViewModel>();
        return Column(
          children: [
            FormRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelWidget(
                  label: "Borrower Rim",
                  child: CustomMultiSelectDropdown<Reference>(
                    key: UniqueKey(),
                    semanticLabel: 'facilities.createFacility.borrowerRim'.tr(),
                    items: viewModel.borrowersByRim,
                    selectedItems: viewModel.borrowersByRimInTable,
                    onSelected: (selectedValue) {
                      viewModel.addBorrowertoTable(selectedValue);
                    },
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return dropdownItemBuildWidget(
                        "${item.name ?? ""} : ${item.id}",
                        isSelected: isSelected,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return multiSelectDropDownBuilderWidget(
                        data: data ?? [],
                        controller: contrlr,
                        itemBuilder: (index) {
                          final borrower = data?[index];
                          return Container(
                            margin: const EdgeInsets.all(4),
                            child: buildMultiSelectChip(
                              label: buildItemText(
                                borrower?.name ?? '',
                                FontSizeHelper(size: FontSize.small),
                              ),
                              onDeleted: () =>
                                  viewModel.onBorrowerChipDeleted(index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                LabelWidget(
                  label: "facilities.createFacility.limitAllocation".tr(),
                  child: SizedBox(
                    height: 0.3.h,
                    child: SingleChildScrollView(
                      child: CustomRawTable(
                        key: UniqueKey(),
                        columns: [
                          TableColumn(
                              label: Text(
                                  'facilities.createFacility.customerRIM'
                                      .tr())),
                          TableColumn(
                              label: Text(
                                  'facilities.createFacility.amount'.tr())),
                        ],
                        rows: (viewModel.borrowersByRimInTable).map((borrower) {
                          return [
                            Center(child: Text(borrower.name ?? "")),
                            Center(
                              child: CustomTextField(
                                initialValue: borrower.description,
                                keyboardType: TextInputType.number,
                                onChanged: (allocationAmount) {
                                  borrower.description = allocationAmount;
                                },
                              ),
                            ),
                          ];
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                    label: "Save",
                    onPressed: () {
                      context.pop();
                    }),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                    label: "Cancel",
                    onPressed: () {
                      context.pop();
                    })
              ],
            )
          ],
        );
      },
    );
  }
}
