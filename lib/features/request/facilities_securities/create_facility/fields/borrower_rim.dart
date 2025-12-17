import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/facility_security/borrower_facility.dart';

class BorrowerRim extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  BorrowerRim({super.key, required this.viewModel});

  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.borrowerRim'.tr(),
      isRequired: !viewModel.showFacilityFi,
      child: Utils.isGroupApplication()
          ? viewModel.facility.sharedLimit?.id == ServerConstants.optionYESid
              ? CustomMultiSelectDropdown<Reference>(
                  key: UniqueKey(),
                  semanticLabel: 'facilities.createFacility.borrowerRim'.tr(),
                  validationMessage: !viewModel.showFacilityFi
                      ? "common.validation.emptyField".tr()
                      : null,
                  items: viewModel.borrowersMap, // List<Reference>
                  selectedItems: viewModel.borrowersByRimInTable.isEmpty
                      ? null
                      : viewModel.borrowersByRimInTable,
                  onSelected: (selectedValue) {
                    viewModel.addBorrowertoTable(selectedValue);
                  },
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return dropdownItemBuildWidget(
                      item.name ?? '', // show the borrower/project name
                      isSelected: isSelected,
                    );
                  },
                  dropdownBuilder: (context, data) {
                    return dropdownMultiItemBuildScrollWidget(
                      data,
                      (index) => Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle:
                            const TextStyle(fontSize: AppStyle.columnName),
                        label: Text("${data?[index].name}"),
                      ),
                    );
                  },
                )
              : viewModel.facility.sharedLimit?.id == ServerConstants.optionNOid
                  ? CustomTextField(
                      semanticLabel:
                          'facilities.createFacility.borrowerRim'.tr(),
                      readOnly: true,
                      filled: true,
                      initialValue: viewModel.rimNo != null
                          ? viewModel.rimNo!.toString()
                          : (viewModel.borrowers.isNotEmpty
                              ? (viewModel.borrowers.first.customerRimNo
                                  .toString())
                              : ''),
                    )
                  : CustomDropdown<Borrower>(
                      validationMessage: "common.validation.emptyField".tr(),
                      semanticLabel:
                          'facilities.createFacility.borrowerRim'.tr(),
                      items: viewModel.borrowers, // List<Borrower>
                      selectedItems: !viewModel.showCreateFacilityForm &&
                              viewModel.borrowers.isNotEmpty
                          ? [
                              viewModel.borrowers.firstWhere(
                                (b) =>
                                    b.customerRimNo ==
                                    (viewModel.facility.rimNo ??
                                        viewModel.selectedRim),
                                orElse: () => viewModel.borrowers.first,
                              )
                            ]
                          : null,
                      onSelected: (selectedValue) {
                        if (selectedValue.isNotEmpty) {
                          final borrower = selectedValue.first; // Borrower
                          viewModel.changeBorrower(borrower);
                        }
                      },
                      itemBuilder: (context, item, isDisabled, isSelected) {
                        return dropdownMultiItemBuildWidget(
                          item.customerRimNo.toString(),
                          isSelected: isSelected,
                        );
                      },
                      dropdownBuilder: (context, data) {
                        return Text(
                          data?.customerRimNo.toString() ?? '',
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    )
          : CustomTextField(
              semanticLabel: 'facilities.createFacility.borrowerRim'.tr(),
              readOnly: true,
              filled: true,
              initialValue: viewModel.borrowersByRim.first.name,
            ),
    );
  }
}
