import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_detail.dart';

class FeeDefaultRateTable extends StatefulWidget {
  final CreateFacilityViewModel viewModel;
  final List<FeeRate> feeDefualtRateTableRows;

  const FeeDefaultRateTable({
    super.key,
    required this.viewModel,
    required this.feeDefualtRateTableRows,
  });

  @override
  State<FeeDefaultRateTable> createState() => _FeeDefaultRateTableState();
}

class _FeeDefaultRateTableState extends State<FeeDefaultRateTable> {
  late final int _seedCount;
  final Map<int, TextEditingController> _feeTypeCtrls = {};

  final Map<int, TextEditingController> _amountCtrls = {};
  final Map<int, TextEditingController> _percentCtrls = {};
  final Map<int, TextEditingController> _commentCtrls = {};
  final Map<int, Reference?> _selectedFreq = {};

  List<Reference> get _feeTypes => widget.viewModel.facilityFeeTypes;
  List<Reference> get _freqItems => widget.viewModel.facilityTypesFeeFrequency;

  @override
  void initState() {
    super.initState();
    final int seedCount = (_feeTypes.length >= 3) ? 3 : _feeTypes.length;
    _seedCount = seedCount;

    if (widget.viewModel.feeDefualtRate.isEmpty) {
      for (var i = 0; i < seedCount; i++) {
        final ft = _feeTypes[i];
        widget.viewModel.feeDefualtRate.add(FeeRate(
          feeRateId: null,
          feeType: ft.name, // seeded label
          amount: null,
          percentage: null,
          frequency: null,
          comment: '',
        ));
      }
    }

    // existing controller init for amount/percent/comment...
    for (var i = 0; i < widget.viewModel.feeDefualtRate.length; i++) {
      final row = widget.viewModel.feeDefualtRate[i];
      final a = TextEditingController(text: _numToText(row.amount));
      final p = TextEditingController(text: _numToText(row.percentage));
      final c = TextEditingController(text: row.comment ?? '');
      a.addListener(() => _applyAmount(i, a.text));
      p.addListener(() => _applyPercentage(i, p.text));
      c.addListener(() => _applyComment(i, c.text));
      _amountCtrls[i] = a;
      _percentCtrls[i] = p;
      _commentCtrls[i] = c;
      if (i >= _seedCount) {
        final ftCtrl = TextEditingController(text: row.feeType ?? '');
        ftCtrl.addListener(() => _applyFeeType(i, ftCtrl.text));
        _feeTypeCtrls[i] = ftCtrl;
      }
      _selectedFreq[i] = _resolveFreqRef(row.frequency);
    }
  }

  @override
  void dispose() {
    for (final ctrl in _amountCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in _percentCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in _commentCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in _feeTypeCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = <TableColumn>[
      TableColumn(forcedWidth: 170.w, label: const Text('Fee type')),
      TableColumn(forcedWidth: 80.w, label: const Text('Amount')),
      TableColumn(forcedWidth: 80.w, label: const Text('Percentage')),
      TableColumn(forcedWidth: 140.w, label: const Text('Frequency')),
      TableColumn(forcedWidth: 320.w, label: const Text('Comments')),
      TableColumn(forcedWidth: 80.w, label: const Text('Action')), // <- NEW
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRawTable(
          key: UniqueKey(),
          showPagination: true,
          rowsPerPage: 5,
          columns: columns,
          autoFitWidth: true,
          rows: _buildRows(),
        ),
        FormField<bool>(
          validator: (_) => _hasEmptyRequiredAmount()
              ? 'Either Amount or Percentage is required for mandatory fee rows'
              : null,
          builder: (state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    state.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const Gap(size: GapSize.medium),
        AddItemButton(
          isLeftSided: true,
          onTap: _addFeeRow,
          child: const Text("Add Fee"),
        ),
        const Gap(size: GapSize.medium),
      ],
    );
  }

  List<List<Widget>> _buildRows() {
    final rows = <List<Widget>>[];
    final list = widget.viewModel.feeDefualtRate;
    for (var i = 0; i < list.length; i++) {
      final row = list[i];
      final feeTypeLabel = ((row.feeType ?? '').isNotEmpty
          ? row.feeType!
          : (_feeTypes.asMap()[i]?.name ?? ''));

      rows.add([
        // Text(feeTypeLabel),

        (i < _seedCount)
            ? Text(feeTypeLabel)
            : CustomTextField(
                maxLength: 20,
                controller: _feeTypeCtrls[i],
                // optional extras:
                // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'.{0,50}'))],
                // hintText: 'Enter fee type',
              ),

        // Amount
        CustomTextField(
          validator: (widget.viewModel.isFeeRowMandatory)
              ? CustomValidator.requiredField
              : null,
          controller: _amountCtrls[i],
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^\d{0,21}(\.\d{0,6})?$')),
          ],
        ),

        // Percentage
        CustomTextField(
          controller: _percentCtrls[i],
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?$')),
          ],
        ),
        CustomDropdown<Reference>(
          items: _freqItems,
          selectedItems:
              (_selectedFreq[i] != null) ? [_selectedFreq[i]!] : null,
          onSelected: (selected) {
            final name =
                (selected.isNotEmpty ? (selected.first.name ?? '').trim() : '');
            _selectedFreq[i] = selected.isNotEmpty ? selected.first : null;
            _applyFrequency(i, name.isEmpty ? null : name);
            setState(() {}); // update dropdown display
          },
          itemBuilder: (context, item, isDisabled, isSelected) =>
              dropdownItemBuildWidget(item.name, isSelected: isSelected),
          dropdownBuilder: (context, data) =>
              Text(data?.name ?? "", style: const TextStyle(fontSize: 14)),
        ),
        CustomTextField(
          maxLength: 100,
          controller: _commentCtrls[i],
        ),
        (i >= _seedCount)
            ? IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeFeeRow(i),
              )
            : const SizedBox.shrink(),
      ]);
    }
    return rows;
  }

  void _removeFeeRow(int index) {
    widget.viewModel.feeDefualtRate.removeAt(index);
    _amountCtrls[index]?.dispose();
    _percentCtrls[index]?.dispose();
    _commentCtrls[index]?.dispose();
    _amountCtrls.remove(index);
    _percentCtrls.remove(index);
    _commentCtrls.remove(index);
    _selectedFreq.remove(index);
    _reindexControllers();

    setState(() {});
  }

  void _reindexControllers() {
    final newAmount = <int, TextEditingController>{};
    final newPercent = <int, TextEditingController>{};
    final newComment = <int, TextEditingController>{};
    final newFreq = <int, Reference?>{};

    for (var i = 0; i < widget.viewModel.feeDefualtRate.length; i++) {
      newAmount[i] = _amountCtrls[i] ?? TextEditingController();
      newPercent[i] = _percentCtrls[i] ?? TextEditingController();
      newComment[i] = _commentCtrls[i] ?? TextEditingController();
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
    _selectedFreq
      ..clear()
      ..addAll(newFreq);
  }

  void _applyAmount(int index, String raw) {
    final v = raw.trim().replaceAll(',', '');
    final double? parsed = v.isEmpty ? null : double.tryParse(v);
    final row = widget.viewModel.feeDefualtRate[index];
    widget.viewModel.feeDefualtRate[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: parsed,
      percentage: row.percentage,
      frequency: row.frequency,
      comment: row.comment,
    );
  }

  void _applyFeeType(int index, String text) {
    final row = widget.viewModel.feeDefualtRate[index];
    widget.viewModel.feeDefualtRate[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: text.trim().isEmpty ? null : text.trim(),
      amount: row.amount,
      percentage: row.percentage,
      frequency: row.frequency,
      comment: row.comment,
    );
  }

  void _applyPercentage(int index, String raw) {
    final v = raw.trim().replaceAll(',', '');
    final double? parsed = v.isEmpty ? null : double.tryParse(v);
    final row = widget.viewModel.feeDefualtRate[index];
    widget.viewModel.feeDefualtRate[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: row.amount,
      percentage: parsed,
      frequency: row.frequency,
      comment: row.comment,
    );
  }

  void _applyFrequency(int index, String? freq) {
    final row = widget.viewModel.feeDefualtRate[index];
    widget.viewModel.feeDefualtRate[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: row.amount,
      percentage: row.percentage,
      frequency: (freq == null || freq.isEmpty) ? null : freq,
      comment: row.comment,
    );
  }

  void _applyComment(int index, String text) {
    final row = widget.viewModel.feeDefualtRate[index];
    widget.viewModel.feeDefualtRate[index] = FeeRate(
      feeRateId: row.feeRateId,
      feeType: row.feeType,
      amount: row.amount,
      percentage: row.percentage,
      frequency: row.frequency,
      comment: text.trim(),
    );
  }

  Reference? _resolveFreqRef(String? freq) {
    final f = (freq ?? '').trim();
    if (f.isEmpty) return null;
    return _freqItems.firstWhere(
      (r) => (r.name ?? '').trim().toLowerCase() == f.toLowerCase(),
      orElse: () => Reference(name: freq),
    );
  }

  String _numToText(num? n) => (n == null) ? "" : n.toString();

  void _addFeeRow() {
    widget.viewModel.feeDefualtRate.add(FeeRate(
      feeRateId: null,
      feeType: null, // let user choose or keep null label
      amount: null,
      percentage: null,
      frequency: null,
      comment: '',
    ));

    final i = widget.viewModel.feeDefualtRate.length - 1;

    _amountCtrls[i] = TextEditingController()
      ..addListener(() => _applyAmount(i, _amountCtrls[i]!.text));
    _percentCtrls[i] = TextEditingController()
      ..addListener(() => _applyPercentage(i, _percentCtrls[i]!.text));
    _commentCtrls[i] = TextEditingController()
      ..addListener(() => _applyComment(i, _commentCtrls[i]!.text));
    _selectedFreq[i] = null;

    setState(() {});
  }

  bool _hasEmptyRequiredAmount() {
    if (!(widget.viewModel.isFeeRowMandatory)) return false;
    if (widget.viewModel.feeDefualtRate.isEmpty) return true;
    for (final ctrl in _amountCtrls.values) {
      if ((ctrl.text).trim().isEmpty) {
        return true;
      }
    }
    return false;
  }
}
