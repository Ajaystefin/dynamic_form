import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/borrower_facility.dart";

/// Widget for selecting and displaying borrower RIM information.
class BorrowerRim extends StatelessWidget {
  /// Creates a borrower RIM widget.
  BorrowerRim({required this.viewModel, super.key});

  /// View model containing borrower and facility data.
  final CreateFacilityViewModel viewModel;

  /// Controller used for scrolling.
  final ScrollController contrlr = ScrollController();

  /// Builds the display label for a borrower.
  ///
  /// Returns the customer name and RIM number when both are available.
  String borrowerLabel({
    String? customerName,
    int? rimNo,
  }) {
    final String name = (customerName ?? "").trim();
    final String rim = rimNo?.toString() ?? "";
    if (name.isNotEmpty && rim.isNotEmpty) {
      return "$name ($rim)";
    }
    return rim;
  }

  /// Finds a borrower using the provided RIM number.
  ///
  /// Returns `null` when no RIM is provided.
  Borrower? findBorrowerByRim(int? rim) {
    if (rim == null) {
      return null;
    }
    return viewModel.borrowers.firstWhere((b) => b.customerRimNo == rim);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSharedLimitYes =
        viewModel.getFacility.sharedLimit?.id == ServerConstants.optionYESid;

    // Annual review flag exists
    final bool shouldBlockCurrentRim =
        viewModel.isAnnualReview && isSharedLimitYes;

    final String blockedRim = (viewModel.rimNo?.toString() ?? "").trim();

    // Helper to check if a Reference matches the blocked rim
    bool isBlockedRim(Reference borrowerRef) {
      final String idStr = (borrowerRef.id?.toString() ?? "").trim();
      return blockedRim.isNotEmpty && idStr == blockedRim;
    }

    final List<Reference> borrowersItems = shouldBlockCurrentRim
        ? viewModel.borrowersMap.where((borrowerRef) {
            return !isBlockedRim(borrowerRef);
          }).toList()
        : viewModel.borrowersMap;

    // Selected items shown as chips
    final List<Reference>? selectedBorrowers = !viewModel.showCreateFacilityForm
        ? viewModel.selectedBorrowersForUi
        : viewModel.borrowersByRimInTable;

    final List<Reference>? selectedBorrowersFiltered = (shouldBlockCurrentRim &&
            selectedBorrowers != null &&
            selectedBorrowers.isNotEmpty)
        ? selectedBorrowers.where((borrowerRef) {
            return !isBlockedRim(borrowerRef);
          }).toList()
        : selectedBorrowers;

    final Borrower? currentBorrower = findBorrowerByRim(
      viewModel.getFacility.rimNo ?? viewModel.selectedRim ?? viewModel.rimNo,
    );

    return LabelWidget(
      label: "facilities.createFacility.borrowerRim".tr(),
      isRequired: !viewModel.isFIFlow,
      child: Utils.isGroupApplication()
          ? isSharedLimitYes
              ? CustomMultiSelectDropdown<Reference>(
                  key: const ValueKey("borrower_rim_multiselect"),
                  semanticLabel: "facilities.createFacility.borrowerRim".tr(),
                  validationMessage: !viewModel.isFIFlow
                      ? "common.validation.emptyField".tr()
                      : null,
                  items: borrowersItems,
                  selectedItems: selectedBorrowersFiltered,
                  compareFn: (Reference leftItem, Reference rightItem) {
                    final String leftKey =
                        (leftItem.id?.toString() ?? leftItem.name ?? "").trim();
                    final String rightKey =
                        (rightItem.id?.toString() ?? rightItem.name ?? "")
                            .trim();
                    return leftKey.isNotEmpty && leftKey == rightKey;
                  },
                  onSelected: (List<Reference> selectedValues) {
                    final List<Reference> effectiveSelection =
                        (shouldBlockCurrentRim && blockedRim.isNotEmpty)
                            ? selectedValues.where((borrowerRef) {
                                return !isBlockedRim(borrowerRef);
                              }).toList()
                            : selectedValues;

                    viewModel.addBorrowertoTable(effectiveSelection);
                  },
                  itemBuilder: (context, item, {isDisabled, isSelected}) {
                    return dropdownItemBuildWidget(
                      item.name ?? "",
                      isSelected: isSelected ?? false,
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
              : viewModel.getFacility.sharedLimit?.id ==
                      ServerConstants.optionNOid
                  ? CustomTextField(
                      semanticLabel:
                          "facilities.createFacility.borrowerRim".tr(),
                      readOnly: true,
                      filled: true,
                      initialValue: borrowerLabel(
                        customerName: currentBorrower?.preferredName,
                        rimNo:
                            currentBorrower?.customerRimNo ?? viewModel.rimNo,
                      ),
                    )
                  : CustomDropdown<Borrower>(
                      validationMessage: "common.validation.emptyField".tr(),
                      semanticLabel:
                          "facilities.createFacility.borrowerRim".tr(),
                      items: viewModel.borrowers,
                      selectedItems: !viewModel.showCreateFacilityForm &&
                              viewModel.borrowers.isNotEmpty
                          ? [
                              viewModel.borrowers.firstWhere(
                                (b) =>
                                    b.customerRimNo ==
                                    (viewModel.getFacility.rimNo ??
                                        viewModel.selectedRim),
                                orElse: () => viewModel.borrowers.first,
                              ),
                            ]
                          : null,
                      onSelected: (selectedValue) {
                        if (selectedValue.isNotEmpty) {
                          final borrower = selectedValue.first;
                          viewModel.changeBorrower(borrower);
                        }
                      },
                      itemBuilder: (context, item, {isDisabled, isSelected}) {
                        return dropdownMultiItemBuildWidget(
                          borrowerLabel(
                            customerName: item.preferredName,
                            rimNo: item.customerRimNo,
                          ),
                          isSelected: isSelected ?? false,
                        );
                      },
                      dropdownBuilder: (context, data) {
                        return Text(
                          borrowerLabel(
                            customerName: data?.preferredName,
                            rimNo: data?.customerRimNo,
                          ),
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    )
          : CustomTextField(
              semanticLabel: "facilities.createFacility.borrowerRim".tr(),
              readOnly: true,
              filled: true,
              initialValue: borrowerLabel(
                customerName: currentBorrower?.preferredName,
                rimNo: currentBorrower?.customerRimNo ?? viewModel.rimNo,
              ),
            ),
    );
  }
}
