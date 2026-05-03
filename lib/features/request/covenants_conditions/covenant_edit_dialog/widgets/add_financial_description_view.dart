import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class AddFinancialDescriptionView extends StatefulWidget {
  const AddFinancialDescriptionView({
    required this.viewModel,
    required this.width,
    super.key,
    this.row,
    this.readOnly = false,
    this.filled = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final Covenant? row;
  final double width;
  final bool readOnly;
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
            widget.row!.description = value; // update only this row
          } else {
            vm.onFinancialDescriptionChanged(value);
            vm.covenant?.description = vm.financialDescriptionController.text;
          }
        },
      ),
    );
  }
}
