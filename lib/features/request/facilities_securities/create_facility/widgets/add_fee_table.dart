import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

/// Widget for displaying and managing fee default rate entries.
class FeeDefaultRateTable extends StatefulWidget {
  /// Creates a fee default rate table widget.
  const FeeDefaultRateTable({
    required this.viewModel,
    super.key,
  });

  /// View model containing fee default rate data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  State<FeeDefaultRateTable> createState() => _FeeDefaultRateTableState();
}

class _FeeDefaultRateTableState extends State<FeeDefaultRateTable> {
  late int _seedCount;

  final Map<int, TextEditingController> _feeTypeCtrls = {};
  final Map<int, TextEditingController> _amountCtrls = {};
  final Map<int, TextEditingController> _percentCtrls = {};
  final Map<int, TextEditingController> _commentCtrls = {};
  final Map<int, Reference?> _selectedFreq = {};
  final NumberFormat formatter = NumberFormat("#,###");
  List<Reference> get _feeTypes => widget.viewModel.facilityFeeTypes;
  List<Reference> get _freqItems => widget.viewModel.facilityTypesFeeFrequency;
  List<FeeRate> get _rates => widget.viewModel.feeDefualtRate;

  @override
  void initState() {
    super.initState();
    _seedCount =
        // (_feeTypes.length >= 3) ? 3 :
        _feeTypes.length;

    // If there is no data yet, seed minimal rows
    _initializeRowsIfNeeded();

    // Initialize controllers from current model
    _syncControllersFromModel();
  }

  @override
  void didUpdateWidget(covariant FeeDefaultRateTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the list identity or length changes (e.g., after API), resync
    // controllers
    final int oldLen = oldWidget.viewModel.feeDefualtRate.length;
    final int newLen = widget.viewModel.feeDefualtRate.length;

    if (oldLen != newLen) {
      _initializeRowsIfNeeded();
      _syncControllersFromModel();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposeAllControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If model changed outside lifecycle (rare), ensure controllers match list
    // length
    _ensureControllersUpToDate();

    final bool showAsterisk = widget.viewModel.isFeeRowMandatory;

    final List<TableColumn> columns = <TableColumn>[
      TableColumn(
        forcedWidth: 170.w,
        label: showAsterisk
            ? const Text.rich(
                TextSpan(
                  text: "Fee type",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Text("Fee type"),
      ),

      // Amount (with conditional asterisk)
      TableColumn(
        forcedWidth: 80.w,
        label: showAsterisk
            ? const Text.rich(
                TextSpan(
                  text: "Amount",
                  style:
                      TextStyle(color: Colors.black), // keep default text color
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Text("Amount"),
      ),

      TableColumn(
        forcedWidth: 80.w,
        label: showAsterisk
            ? const Text.rich(
                TextSpan(
                  text: "Percentage",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Text("Percentage"),
      ),
      TableColumn(
        forcedWidth: 140.w,
        label: showAsterisk
            ? const Text.rich(
                TextSpan(
                  text: "Frequency",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Text("Frequency"),
      ),
      TableColumn(
        forcedWidth: 320.w,
        label: showAsterisk
            ? const Text.rich(
                TextSpan(
                  text: "Comments",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Text("Comments"),
      ),
      TableColumn(forcedWidth: 80.w, label: const Text("Action")),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRawTable(
          key: ValueKey(_rates.length), // rebuild table when rows change
          rowsPerPage: 30,
          columns: columns,
          rows: _buildRows(),
        ),
        FormField<bool>(
          validator: (_) => _hasEmptyRequiredAmountOrPercent()
              ? "Either Amount or Percentage is required for mandatory fee rows"
              : null,
          builder: (state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    state.errorText ?? "",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const Gap(),
        if (widget.viewModel.canEdit)
          AddItemButton(
            isLeftSided: true,
            onTap: _addFeeRow,
            child: const Text("Add Fee"),
          ),
        const Gap(),
      ],
    );
  }

  List<List<Widget>> _buildRows() {
    final bool showAsterisk = widget.viewModel.isFeeRowMandatory;

    final List<List<Widget>> rows = <List<Widget>>[];

    for (int rowIndex = 0; rowIndex < _rates.length; rowIndex++) {
      final FeeRate row = _rates[rowIndex];

      // Fee type label: prefer model feeType; otherwise seed from fee types
      // list
      final String feeTypeLabel = ((row.feeType ?? "").isNotEmpty
          ? row.feeType!
          : (_feeTypes.asMap()[rowIndex]?.name ?? ""));

      rows.add([
        // Fee type (first _seedCount rows are readonly seeded labels)
        if (rowIndex < _seedCount)
          Text(key: ValueKey("fee_freq_row_$rowIndex "), feeTypeLabel)
        else
          CustomTextField(
            key: ValueKey("fee_freq_row_$rowIndex "),
            maxLength: 20,
            controller: _feeTypeCtrls[rowIndex],
            validator:

                //_feeTypeCtrls[rowIndex]?.text.trim().isEmpty ?? true    ?
                showAsterisk ? CustomValidator.requiredField : null,
            // : null,
          ),

        // Amount
        CustomTextField(
          key: ValueKey("fee_freq_row_$rowIndex "),
          validator: (value) {
            if (!showAsterisk) {
              return null;
            }
            final bool amountEmpty =
                _amountCtrls[rowIndex]?.text.trim().isEmpty ?? true;
            final bool percentEmpty =
                _percentCtrls[rowIndex]?.text.trim().isEmpty ?? true;
            return (amountEmpty && percentEmpty)
                ? CustomValidator.requiredField(value)
                : null;
          },
          controller: _amountCtrls[rowIndex],
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorFormatter(),
          ],
        ),

        // Percentage
        CustomTextField(
          key: ValueKey("fee_freq_row_$rowIndex "),
          validator: (value) {
            if (!showAsterisk) {
              return null;
            }
            final bool amountEmpty =
                _amountCtrls[rowIndex]?.text.trim().isEmpty ?? true;
            final bool percentEmpty =
                _percentCtrls[rowIndex]?.text.trim().isEmpty ?? true;
            return (amountEmpty && percentEmpty)
                ? CustomValidator.requiredField(value)
                : null;
          },
          controller: _percentCtrls[rowIndex],
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"^\d{0,3}(\.\d{0,2})?$")),
          ],
        ),

        // Frequency (wrapped in a StatefulWidget to survive CustomRawTable's
        // ignoring of updated rows)
        _FreqDropdownCell(
          key: ValueKey("fee_freq_cell_$rowIndex"),
          rowIndex: rowIndex,
          freqItems: _freqItems,
          showAsterisk: showAsterisk,
          rates: _rates,
          selectedFreqCache: _selectedFreq,
          onApplyFrequency: _applyFrequency,
          onResolveFreqRef: _resolveFreqRef,
          onRebuildParent: () => setState(() {}),
        ),

        // Comments
        CustomTextField(
          key: ValueKey("fee_freq_row_$rowIndex "),
          validator: showAsterisk ? CustomValidator.requiredField : null,
          maxLength: 100,
          controller: _commentCtrls[rowIndex],
        ),

        // Action
        if ((rowIndex >= _seedCount) && (widget.viewModel.canEdit))
          IconButton(
            key: ValueKey("fee_freq_row_$rowIndex "),
            tooltip: "Delete",
            icon: const Icon(
              Icons.delete_outline,
              color: Color.fromARGB(255, 80, 136, 153),
            ),
            onPressed: () => _removeFeeRow(rowIndex),
          )
        else
          const SizedBox.shrink(),
      ]);
    }
    return rows;
  }

  void _initializeRowsIfNeeded() {
    // Seed only if model has no rows yet and there are fee types to seed from
    if (_rates.isEmpty && _feeTypes.isNotEmpty) {
      for (int i = 0; i < _seedCount; i++) {
        final Reference ft = _feeTypes[i];
        _rates.add(
          FeeRate(
            feeType: ft.name, // seeded label
            comment: "",
          ),
        );
      }
    }
  }

  void _syncControllersFromModel() {
    _disposeAllControllers();
    for (int rowIndex = 0; rowIndex < _rates.length; rowIndex++) {
      final FeeRate row = _rates[rowIndex];

      final TextEditingController amountController =
          TextEditingController(text: _numToText(row.amount));
      final TextEditingController percentageController =
          TextEditingController(text: _numToText(row.percentage));
      final TextEditingController commentController =
          TextEditingController(text: row.comment ?? "");
      amountController
          .addListener(() => _applyAmount(rowIndex, amountController.text));
      percentageController.addListener(
        () => _applyPercentage(rowIndex, percentageController.text),
      );
      commentController
          .addListener(() => _applyComment(rowIndex, commentController.text));
      _amountCtrls[rowIndex] = amountController;
      _percentCtrls[rowIndex] = percentageController;
      _commentCtrls[rowIndex] = commentController;

      if (rowIndex >= _seedCount) {
        final TextEditingController feeTypeController =
            TextEditingController(text: row.feeType ?? "");
        feeTypeController
            .addListener(() => _applyFeeType(rowIndex, feeTypeController.text));
        _feeTypeCtrls[rowIndex] = feeTypeController;
      }

      // Use ??= so an existing user selection is never overwritten by a
      // model-resolved reference during a validation-triggered resync.
      _selectedFreq[rowIndex] ??= _resolveFreqRef(row.frequency);
    }
  }

  void _ensureControllersUpToDate() {
    // If model length changed without lifecycle (rare), resync
    if (_amountCtrls.length != _rates.length ||
        _percentCtrls.length != _rates.length ||
        _commentCtrls.length != _rates.length) {
      _syncControllersFromModel();
    }
  }

  void _disposeAllControllers() {
    for (final TextEditingController ctrl in _amountCtrls.values) {
      ctrl.dispose();
    }
    for (final TextEditingController ctrl in _percentCtrls.values) {
      ctrl.dispose();
    }
    for (final TextEditingController ctrl in _commentCtrls.values) {
      ctrl.dispose();
    }
    for (final TextEditingController ctrl in _feeTypeCtrls.values) {
      ctrl.dispose();
    }

    _amountCtrls.clear();
    _percentCtrls.clear();
    _commentCtrls.clear();
    _feeTypeCtrls.clear();
    // NOTE: _selectedFreq is intentionally NOT cleared here.
    // Clearing it would wipe user-selected dropdown values whenever
    // _syncControllersFromModel is triggered (e.g. on row-count change
    // or validation rebuild), causing the frequency dropdown to appear blank.
    // _selectedFreq is managed explicitly in _removeFeeRow and
    // _reindexControllers.
  }

  void _removeFeeRow(int index) {
    widget.viewModel.feeDefualtRate.removeAt(index);

    _amountCtrls[index]?.dispose();
    _percentCtrls[index]?.dispose();
    _commentCtrls[index]?.dispose();
    _feeTypeCtrls[index]?.dispose();

    _amountCtrls.remove(index);
    _percentCtrls.remove(index);
    _commentCtrls.remove(index);
    _feeTypeCtrls.remove(index);
    _selectedFreq.remove(index);

    _reindexControllers();
    setState(() {});
  }

  void _reindexControllers() {
    final Map<int, TextEditingController> newAmount =
        <int, TextEditingController>{};
    final Map<int, TextEditingController> newPercent =
        <int, TextEditingController>{};
    final Map<int, TextEditingController> newComment =
        <int, TextEditingController>{};
    final Map<int, TextEditingController> newFeeType =
        <int, TextEditingController>{};
    final Map<int, Reference?> newFreq = <int, Reference?>{};

    for (int i = 0; i < _rates.length; i++) {
      if (_amountCtrls.containsKey(i)) {
        newAmount[i] = _amountCtrls[i]!;
      } else {
        newAmount[i] = TextEditingController();
      }
      if (_percentCtrls.containsKey(i)) {
        newPercent[i] = _percentCtrls[i]!;
      } else {
        newPercent[i] = TextEditingController();
      }
      if (_commentCtrls.containsKey(i)) {
        newComment[i] = _commentCtrls[i]!;
      } else {
        newComment[i] = TextEditingController();
      }
      if (_feeTypeCtrls.containsKey(i)) {
        newFeeType[i] = _feeTypeCtrls[i]!;
      }
      newFreq[i] = _selectedFreq[i];
    }

    _amountCtrls
      ..clear()
      ..addAll(newAmount);
    _percentCtrls
      ..clear()
      ..addAll(newPercent);
    _commentCtrls
      ..clear()
      ..addAll(newComment);
    _feeTypeCtrls
      ..clear()
      ..addAll(newFeeType);
    _selectedFreq
      ..clear()
      ..addAll(newFreq);
  }

  void _applyAmount(int index, String raw) {
    final String v = raw.trim().replaceAll(",", "");
    final double? parsed = v.isEmpty ? null : double.tryParse(v);
    final FeeRate row = _rates[index];
    _rates[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: parsed,
      percentage: row.percentage,
      frequency: row.frequency,
      comment: row.comment,
    );
  }

  void _applyFeeType(int index, String text) {
    final FeeRate row = _rates[index];
    _rates[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: text.trim().isEmpty ? null : text.trim(),
      amount: row.amount,
      percentage: row.percentage,
      frequency: row.frequency,
      comment: row.comment,
    );
  }

  void _applyPercentage(int index, String raw) {
    final String v = raw.trim().replaceAll(",", "");
    final double? parsed = v.isEmpty ? null : double.tryParse(v);
    final FeeRate row = _rates[index];
    _rates[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: row.amount,
      percentage: parsed,
      frequency: row.frequency,
      comment: row.comment,
    );
  }

  void _applyFrequency(int index, String? freq) {
    final FeeRate row = _rates[index];
    _rates[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: row.amount,
      percentage: row.percentage,
      frequency: (freq == null || freq.isEmpty) ? null : freq,
      comment: row.comment,
    );
  }

  void _applyComment(int index, String text) {
    final FeeRate row = _rates[index];
    _rates[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: row.amount,
      percentage: row.percentage,
      frequency: row.frequency,
      comment: text.trim(),
    );
  }

  Reference? _resolveFreqRef(String? freq) {
    final String frequnecy = (freq ?? "").trim();
    if (frequnecy.isEmpty) {
      return null;
    }
    return _freqItems.firstWhere(
      (r) => (r.name ?? "").trim().toLowerCase() == frequnecy.toLowerCase(),
      orElse: () => Reference(name: freq),
    );
  }

  String _numToText(num? n) => (n == null) ? "" : formatter.format(n);

  void _addFeeRow() {
    _rates.add(
      FeeRate(
        comment: "",
      ),
    );

    final int i = _rates.length - 1;

    _amountCtrls[i] = TextEditingController()
      ..addListener(() => _applyAmount(i, _amountCtrls[i]!.text));
    _percentCtrls[i] = TextEditingController()
      ..addListener(() => _applyPercentage(i, _percentCtrls[i]!.text));
    _commentCtrls[i] = TextEditingController()
      ..addListener(() => _applyComment(i, _commentCtrls[i]!.text));
    _selectedFreq[i] = null;

    // For editable fee type rows (beyond seed)
    if (i >= _seedCount) {
      _feeTypeCtrls[i] = TextEditingController()
        ..addListener(() => _applyFeeType(i, _feeTypeCtrls[i]!.text));
    }

    setState(() {});
    widget.viewModel.formKey.currentState?.validate();
  }

  bool _hasEmptyRequiredAmountOrPercent() {
    if (!widget.viewModel.isFeeRowMandatory) {
      return false;
    }
    if (_rates.isEmpty) {
      return false; // do not block when table is untouched
    }

    bool anyRowTouched = false;
    for (int i = 0; i < _rates.length; i++) {
      final String amountTxt = (_amountCtrls[i]?.text ?? "").trim();
      final String percentTxt = (_percentCtrls[i]?.text ?? "").trim();
      final String commentTxt = (_commentCtrls[i]?.text ?? "").trim();
      final String freqTxt = (_rates[i].frequency ?? "").trim();
      final String feeTypeTxt = (_feeTypeCtrls[i]?.text ?? "").trim();

      final bool amountEmpty = amountTxt.isEmpty;
      final bool percentEmpty = percentTxt.isEmpty;
      final bool rowTouched = amountTxt.isNotEmpty ||
          percentTxt.isNotEmpty ||
          commentTxt.isNotEmpty ||
          freqTxt.isNotEmpty ||
          feeTypeTxt.isNotEmpty;

      anyRowTouched = anyRowTouched || rowTouched;
      if (rowTouched && amountEmpty && percentEmpty) {
        return true; // this touched row must have either amount or percent
      }
    }
    // If no row is touched, don't block save here
    return false;
  }
}

class _FreqDropdownCell extends StatefulWidget {
  const _FreqDropdownCell({
    required this.rowIndex,
    required this.freqItems,
    required this.showAsterisk,
    required this.rates,
    required this.selectedFreqCache,
    required this.onApplyFrequency,
    required this.onResolveFreqRef,
    required this.onRebuildParent,
    super.key,
  });
  final int rowIndex;
  final List<Reference> freqItems;
  final bool showAsterisk;
  final List<FeeRate> rates;
  final Map<int, Reference?> selectedFreqCache;
  final void Function(int, String?) onApplyFrequency;
  final Reference? Function(String?) onResolveFreqRef;
  final VoidCallback onRebuildParent;

  @override
  State<_FreqDropdownCell> createState() => _FreqDropdownCellState();
}

class _FreqDropdownCellState extends State<_FreqDropdownCell> {
  Reference? _localSelected;

  @override
  void initState() {
    super.initState();
    _initSelection();
  }

  void _initSelection() {
    final Reference? fromCache = widget.selectedFreqCache[widget.rowIndex];
    if (fromCache != null) {
      _localSelected = fromCache;
      return;
    }
    final Reference? fromModel =
        widget.onResolveFreqRef(widget.rates[widget.rowIndex].frequency);
    if (fromModel != null) {
      _localSelected = fromModel;
    }
  }

  @override
  void didUpdateWidget(covariant _FreqDropdownCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-hydrate if the instance reference completely changes
    // (though in CustomRawTable this won't happen unless row identity changes)
    if (oldWidget.rates[widget.rowIndex].frequency !=
        widget.rates[widget.rowIndex].frequency) {
      _initSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<Reference>(
      // We don't need a value key here because this is the state owner
      validationMessage: (widget.showAsterisk) ? "Frequency is required" : null,
      items: widget.freqItems,
      selectedItems: _localSelected != null ? [_localSelected] : null,

      onBeforeChange: (Reference? previous, Reference? current) async {
        if (previous != null && current == null) {
          return false; // veto implicit clear
        }
        return true;
      },

      onClear: (_) {
        final Reference? ref =
            widget.onResolveFreqRef(widget.rates[widget.rowIndex].frequency);
        if (ref != null) {
          widget.selectedFreqCache[widget.rowIndex] = ref;
          setState(() {
            _localSelected = ref;
          });
        }
      },

      compareFn: (Reference left, Reference right) {
        if (identical(left, right)) {
          return true;
        }
        final String? leftId = left.id?.toString();
        final String? rightId = right.id?.toString();
        if (leftId != null && rightId != null && leftId == rightId) {
          return true;
        }
        final String leftName = (left.name ?? "").trim().toLowerCase();
        final String rightName = (right.name ?? "").trim().toLowerCase();
        return leftName == rightName;
      },

      onSelected: (selected) {
        final String name =
            (selected.isNotEmpty ? (selected.first.name ?? "").trim() : "");
        final Reference? newRef = selected.isNotEmpty ? selected.first : null;

        setState(() {
          _localSelected = newRef;
        });

        widget.selectedFreqCache[widget.rowIndex] = newRef;
        widget.onApplyFrequency(widget.rowIndex, name.isEmpty ? null : name);
        widget.onRebuildParent();
      },

      itemBuilder: (context, item, {isDisabled, isSelected}) =>
          dropdownItemBuildWidget(item.name, isSelected: isSelected ?? false),

      dropdownBuilder: (context, data) =>
          Text(data?.name ?? "", style: const TextStyle(fontSize: 14)),
    );
  }
}
