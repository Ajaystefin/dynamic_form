import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Dialog for allocating limits to a customer or facility.
class AllocateLimitDialogBox extends StatefulWidget {
  /// Creates an allocate limit dialog box.
  const AllocateLimitDialogBox({
    required this.viewModel,
    required this.rowIndex,
    super.key,
  });

  /// View model containing limit allocation data and actions.
  final CreateFacilityViewModel viewModel;

  /// Index of the row being edited or allocated.
  final int rowIndex;

  @override
  State<AllocateLimitDialogBox> createState() => _AllocateLimitDialogBoxState();
}

class _AllocateLimitDialogBoxState extends State<AllocateLimitDialogBox> {
  int _mainAllocationCapFor(Reference borrower) {
    final String key = (borrower.id?.toString() ?? borrower.name ?? "").trim();
    if (key.isEmpty) {
      return 0;
    }

    final Reference? mainRow =
        widget.viewModel.borrowersByRimInTable.cast<Reference?>().firstWhere(
      (r) {
        final String rKey = (r?.id?.toString() ?? r?.name ?? "").trim();
        return rKey.isNotEmpty && rKey == key;
      },
      orElse: () => null,
    );

    final String raw = (mainRow?.description ?? "").replaceAll(",", "").trim();
    return int.tryParse(raw) ?? 0;
  }

  bool get _isSharedLimitYes =>
      widget.viewModel.getFacility.sharedLimit?.id ==
      ServerConstants.optionYESid;

  bool get _shouldBlockCurrentRim =>
      widget.viewModel.isAnnualReview && _isSharedLimitYes;

  String get _blockedRim => (widget.viewModel.rimNo?.toString() ?? "").trim();

  bool _isBlockedRim(Reference borrowerRef) {
    final String idStr = (borrowerRef.id?.toString() ?? "").trim();
    final String nameStr = (borrowerRef.name ?? "").trim();
    return _blockedRim.isNotEmpty &&
        (idStr == _blockedRim || nameStr == _blockedRim);
  }

  final Key _chipsKey = UniqueKey();
  Key _tableKey = UniqueKey();
  List<Reference> _selectedForRow = [];
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _amountFocusNodes = {};

  int _rowScopedInputKey(Reference b) =>
      (b.id ?? b.name).hashCode ^ widget.rowIndex.hashCode;

  TextEditingController _amountControllerFor(Reference b) =>
      _controllers.putIfAbsent(
        _rowScopedInputKey(b),
        () => TextEditingController(text: b.description ?? ""),
      );

  FocusNode _focusNodeFor(Reference b) =>
      _amountFocusNodes.putIfAbsent(_rowScopedInputKey(b), FocusNode.new);

  @override
  void initState() {
    super.initState();

    final List<Reference> initialRowSelections =
        widget.viewModel.subLimitBorrowersByIndex[widget.rowIndex] ??
            const <Reference>[];
    _selectedForRow = initialRowSelections
        .map(
          (r) => Reference(id: r.id, name: r.name, description: r.description),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _amountFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool _canSave(List<Reference> list) {
    if (list.isEmpty) {
      return false;
    }
    for (final Reference b in list) {
      final String value = (b.description ?? "").replaceAll(",", "").trim();
      if (value.isEmpty || int.tryParse(value) == null) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController chipsScrollCtrl = ScrollController();
    return BlocBuilder<CreateFacilityViewModel, CreateFacilityState>(
      builder: (context, state) {
        final CreateFacilityViewModel viewModel =
            context.read<CreateFacilityViewModel>();

        final bool canSave = _canSave(_selectedForRow);

        final List<Reference> borrowersItems = _shouldBlockCurrentRim
            ? viewModel.borrowersMap.where((b) => !_isBlockedRim(b)).toList()
            : viewModel.borrowersMap;

        // also ensure already-selected chips don’t include blocked rim
        final List<Reference> selectedItemsFiltered = _shouldBlockCurrentRim
            ? _selectedForRow.where((b) => !_isBlockedRim(b)).toList()
            : _selectedForRow;
        bool capToastVisible = false;

        bool shouldShowCapToastOnce() {
          if (capToastVisible) {
            return false;
          }
          capToastVisible = true;
          Future.delayed(const Duration(milliseconds: 1200), () {
            capToastVisible = false;
          });
          return true;
        }

        return Column(
          children: [
            FormRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelWidget(
                  label: "facilities.createFacility.borrowerRim".tr(),
                  child: CustomMultiSelectDropdown<Reference>(
                    key: _chipsKey,
                    semanticLabel: "facilities.createFacility.borrowerRim".tr(),
                    items: borrowersItems,
                    selectedItems: selectedItemsFiltered,
                    compareFn: (Reference leftItem, Reference rightItem) {
                      final String leftKey =
                          (leftItem.id?.toString() ?? leftItem.name ?? "")
                              .trim();
                      final String rightKey =
                          (rightItem.id?.toString() ?? rightItem.name ?? "")
                              .trim();
                      return leftKey.isNotEmpty && leftKey == rightKey;
                    },
                    onSelected: (selectedValue) {
                      final Map<String, String?> priorAmountByBorrowerKey = {
                        for (final Reference row in _selectedForRow)
                          (row.id ?? row.name).toString(): row.description,
                      };

                      final List<Reference> effectiveSelection =
                          _shouldBlockCurrentRim
                              ? selectedValue
                                  .where((b) => !_isBlockedRim(b))
                                  .toList()
                              : selectedValue;

                      _selectedForRow = effectiveSelection
                          .map(
                            (r) => Reference(
                              id: r.id,
                              name: r.name,
                              description: priorAmountByBorrowerKey[
                                  (r.id ?? r.name).toString()],
                            ),
                          )
                          .toList();

                      setState(() {
                        _tableKey = UniqueKey();
                      });
                    },
                    itemBuilder: (context, item, {isDisabled, isSelected}) {
                      return dropdownItemBuildWidget(
                        item.name ?? "",
                        isSelected: isSelected ?? false,
                      );
                    },
                    dropdownBuilder: (context, data) {
                      return multiSelectDropDownBuilderWidget(
                        data: data ?? [],
                        controller: chipsScrollCtrl,
                        itemBuilder: (index) {
                          final borrower = data?[index];
                          return Container(
                            margin: const EdgeInsets.all(4),
                            child: buildMultiSelectChip(
                              label: buildItemText(
                                borrower?.name ?? "",
                                FontSizeHelper(size: FontSize.small),
                              ),
                              onDeleted: () {
                                setState(() {
                                  _selectedForRow.removeAt(index);
                                  _tableKey = UniqueKey();
                                });
                              },
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
                        key: _tableKey,
                        columns: [
                          TableColumn(
                            label: Text(
                              "facilities.createFacility.customerRIM".tr(),
                            ),
                          ),
                          TableColumn(
                            label: Text(
                              "facilities.createFacility.amountAed".tr(),
                            ),
                          ),
                        ],
                        rows: _selectedForRow.map((borrower) {
                          return [
                            Center(child: Text(borrower.name ?? "")),
                            Center(
                              child: CustomTextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(15),
                                  FilteringTextInputFormatter.digitsOnly,
                                  ThousandsSeparatorFormatter(),
                                ],
                                initialValue: borrower.description,
                                controller: _amountControllerFor(borrower),
                                focusNode: _focusNodeFor(borrower),
                                keyboardType: TextInputType.number,
                                onChanged: (allocationAmount) {
                                  final String cleaned = allocationAmount
                                      .replaceAll(",", "")
                                      .trim();
                                  final int entered =
                                      int.tryParse(cleaned) ?? 0;

                                  final int cap =
                                      _mainAllocationCapFor(borrower);

                                  // If cap is 0, user should not exceed 0.
                                  if (entered > cap) {
                                    // revert to cap
                                    final String capText = cap
                                        .toString(); // keep digits only, formatter will display separators
                                    borrower.description = capText;

                                    // final controller =
                                    //     _amountControllerFor(borrower)
                                    //       ..value = TextEditingValue(
                                    //         text: capText,
                                    //         selection: TextSelection.collapsed(
                                    //             offset: capText.length),
                                    //       );

                                    if (shouldShowCapToastOnce()) {
                                      AlertManager().showFailureToast(
                                        "Allocation cannot exceed the main Limit Allocation amount",
                                      );
                                    }
                                  } else {
                                    borrower.description = allocationAmount;
                                  }

                                  setState(() {});
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
                  onPressed: canSave
                      ? () {
                          viewModel.setSubLimitAllocations(
                            widget.rowIndex,
                            _selectedForRow
                                .map(
                                  (r) => Reference(
                                    id: r.id,
                                    name: r.name,
                                    description: r.description,
                                  ),
                                )
                                .toList(),
                          );
                          context.pop();
                        }
                      : null,
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  label: "Cancel",
                  onPressed: () {
                    context.pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
