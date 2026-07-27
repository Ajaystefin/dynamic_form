import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Add financial description view for the covenant edit dialog.
class AddFinancialDescriptionView extends StatefulWidget {
  /// Creates an add financial description view.
  const AddFinancialDescriptionView({
    required this.viewModel,
    required this.width,
    super.key,
    this.row,
    this.readOnly = false,
    this.filled = false,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant row data.
  final Covenant? row;

  /// Width of the description field.
  final double width;

  /// Whether the description field is read-only.
  final bool readOnly;

  /// Whether the description field is filled.
  final bool filled;

  @override
  State<AddFinancialDescriptionView> createState() =>
      _AddFinancialDescriptionViewState();
}

class _AddFinancialDescriptionViewState
    extends State<AddFinancialDescriptionView> {
  TextEditingController? _rowController;
  bool get _isRowMode => widget.row != null;

  @override
  void initState() {
    super.initState();
    if (_isRowMode) {
      final String seedText = (widget.viewModel.isNewCovenant)
          ? (widget.row!.description ?? "")
          : "";
      _rowController = TextEditingController(text: seedText);
    }
  }

  @override
  void didUpdateWidget(covariant AddFinancialDescriptionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isRowMode) {
      final String newText = widget.row!.description ?? "";
      if (_rowController?.text != newText) {
        _rowController?.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _rowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return SizedBox(
      child: CustomTextField(
        key: _isRowMode
            ? ValueKey(
                // include both subtype and description hash to reinit state
                // when needed
                "row-desc-${widget.row.hashCode}-"
                '${widget.row?.covenantSubType ?? 'none'}-'
                "${widget.row?.description?.hashCode ?? 0}",
              )
            : null,
        maxLines: 9,
        minLines: 3,
        readOnly: vm.isReadOnly && vm.isDescriptionReadOnly,
        width: widget.width,
        validator: CustomValidator.requiredField,

        // Row mode: own controller, no initialValue; Desktop: keep existing
        controller:
            _isRowMode ? _rowController : vm.financialDescriptionController,
        initialValue: _isRowMode
            ? null
            : (vm.isLinkFinancialView
                ? ""
                : (!vm.isNewCovenant ? (vm.covenant?.description ?? "") : "")),

        filled: widget.filled,
        onChanged: (value) {
          if (_isRowMode) {
            final Covenant row = widget.row!;
            final bool isStd = row.isStandard ?? true;

            if (isStd) {
              // Extract digits typed inside brackets, ignore everything else
              final RegExpMatch? m = RegExp(r"\[(.*?)\]").firstMatch(value);
              final String inside = m?.group(1) ?? "";

              final String digitsOnly = vm.sanitizeAndClampBracketInput(inside);
              final String rebuilt =
                  vm.buildStandardRowDescription(row, digitsOnly);

              if (_rowController != null && _rowController!.text != rebuilt) {
                final int currentCaret = _rowController!.selection.baseOffset;

                final int safeCaret = vm.calculateFinancialBracketCaretOffset(
                  inputText: value,
                  rebuiltText: rebuilt,
                  currentCaret: currentCaret,
                );

                _rowController!.value = TextEditingValue(
                  text: rebuilt,
                  selection: TextSelection.collapsed(offset: safeCaret),
                );
              }

              row.description = rebuilt;
              vm.applyThresholdFromDescription(
                rebuilt,
                target: row,
              );
            } else {
              // Custom rows: allow free typing (unchanged behavior)
              row.description = value;
            }
          } else {
            vm.onFinancialDescriptionChanged(value);
            vm.covenant?.description = vm.financialDescriptionController.text;
          }
        },
      ),
    );
  }
}
