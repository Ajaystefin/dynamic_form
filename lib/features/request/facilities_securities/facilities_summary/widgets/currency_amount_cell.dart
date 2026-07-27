import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// A reusable "amount + currency" cell used across the facilities summary tables
/// (standard limits, FI trade, project specific / standby).
///
/// It renders an amount [CustomTextField] whose `prefixIcon` is a currency-code
/// [CustomDropdown]. These summary cells do **not** perform live AED conversion:
/// picking a currency or typing an amount simply reports back through
/// [onCurrencySelected] / [onAmountChanged], and the caller owns every model
/// write. This widget only owns the shared presentation.
///
/// Optionally, when [originalCurrencyCode] + [originalAmount] are supplied and
/// the original currency isn't AED, the cell starts read-only with a small
/// edit icon shown to the right of the field. Tapping it switches the field
/// to the original currency/value — exactly as if the user had picked that
/// currency and retyped that amount, by invoking [onCurrencySelected] /
/// [onAmountChanged] — and makes the cell editable.
class CurrencyAmountCell extends StatefulWidget {
  /// Creates a [CurrencyAmountCell].
  const CurrencyAmountCell({
    required this.currencies,
    required this.onCurrencySelected,
    super.key,
    this.selectedCurrencyCode,
    this.onAmountChanged,
    this.controller,
    this.initialAmount,
    this.tooltipMessage,
    this.originalCurrencyCode,
    this.originalAmount,
    this.dropdownWidth,
    this.inputFormatters,
    this.keyboardType,
    this.textAlign = TextAlign.end,
    this.isDropdownEnabled = true,
  });

  /// Currency options for the dropdown (typically `viewModel.currencyCodes`).
  final List<Reference> currencies;

  /// Called with the picked currency when the dropdown selection changes.
  final ValueChanged<Reference> onCurrencySelected;

  /// Currency code to pre-select (e.g. "AED", the row currency, or header code).
  final String? selectedCurrencyCode;

  /// Called with the raw field text whenever the amount changes. The caller
  /// cleans/parses the value exactly as before.
  final ValueChanged<String>? onAmountChanged;

  /// Optional external controller for the amount field. Mutually exclusive with
  /// [initialAmount].
  final TextEditingController? controller;

  /// Optional initial amount for an uncontrolled field. Formatted with thousands
  /// separators and rounded (never truncated).
  final num? initialAmount;

  /// Optional tooltip wrapping the cell (e.g. the "Initial Value" hint). When
  /// null the cell is not wrapped in a [CustomTooltip].
  final String? tooltipMessage;

  /// Optional original (non-AED-converted) currency code. When this differs
  /// from AED and from the currently shown currency, an edit icon is shown
  /// that switches the field to this currency + [originalAmount].
  final String? originalCurrencyCode;

  /// Optional value (in [originalCurrencyCode]) used when switching via the
  /// edit icon. Rounded when formatted.
  final num? originalAmount;

  /// Width of the currency dropdown. Defaults to `60.w`.
  final double? dropdownWidth;

  /// Amount field input formatters. Defaults to a 15-char, digits-only field with
  /// thousands separators.
  final List<TextInputFormatter>? inputFormatters;

  /// Keyboard type for the amount field.
  final TextInputType? keyboardType;

  /// Text alignment of the amount value. Defaults to [TextAlign.end].
  final TextAlign textAlign;

  /// Whether the currency dropdown is interactive.
  final bool isDropdownEnabled;

  @override
  State<CurrencyAmountCell> createState() => _CurrencyAmountCellState();
}

class _CurrencyAmountCellState extends State<CurrencyAmountCell> {
  static final NumberFormat _amountFormat = NumberFormat("#,###");

  late final TextEditingController _controller;

  /// Currency code currently shown, once the user interacts (via the
  /// dropdown or the switch-to-original icon). `null` until then, in which
  /// case `widget.selectedCurrencyCode` is used.
  String? _localSelectedCode;

  /// Becomes `true` once the switch-to-original icon has been pressed. Once
  /// unlocked the cell stays editable regardless of what currency is picked
  /// afterwards.
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(
          text: widget.initialAmount != null
              ? _amountFormat.format(widget.initialAmount!.round())
              : null,
        );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Mirrors `FacilitiesSummaryViewModel.matchOrFirstByName` for these call
  /// sites (the list is always the currency list): empty list -> blank guard,
  /// empty code -> first item, otherwise a case-insensitive name match
  /// falling back to the first item.
  Reference _findByCode(String? code) {
    if (widget.currencies.isEmpty) {
      return Reference();
    }
    final String trimmed = (code ?? "").trim().toLowerCase();
    if (trimmed.isEmpty) {
      return widget.currencies.first;
    }
    return widget.currencies.firstWhere(
      (Reference r) => (r.name ?? "").trim().toLowerCase() == trimmed,
      orElse: () => widget.currencies.first,
    );
  }

  String get _effectiveSelectedCode =>
      _localSelectedCode ?? widget.selectedCurrencyCode ?? "";

  bool get _showEditIcon {
    if (_unlocked) {
      return false;
    }
    final String original = (widget.originalCurrencyCode ?? "").trim();
    if (original.isEmpty || widget.originalAmount == null) {
      return false;
    }
    return original.toUpperCase() != ServerConstants.aedCurrency;
  }

  void _switchToOriginal() {
    final Reference originalRef = _findByCode(widget.originalCurrencyCode);
    final String formatted =
        _amountFormat.format(widget.originalAmount!.round());
    setState(() {
      _unlocked = true;
      _localSelectedCode = originalRef.name;
      _controller.text = formatted;
    });
    widget.onCurrencySelected(originalRef);
    widget.onAmountChanged?.call(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final CustomTextField field = CustomTextField(
      textAlign: widget.textAlign,
      controller: _controller,
      readOnly: _showEditIcon,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters ??
          <TextInputFormatter>[
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorFormatter(),
          ],
      prefixIcon: CustomDropdown<Reference>(
        showClearIcon: false,
        isEnabled: widget.isDropdownEnabled && !_showEditIcon,
        width: widget.dropdownWidth ?? 60.w,
        height: null,
        items: widget.currencies,
        selectedItems: <Reference>[_findByCode(_effectiveSelectedCode)],
        onSelected: (List<Reference> selected) {
          if (selected.isNotEmpty) {
            setState(() => _localSelectedCode = selected.first.name);
            widget.onCurrencySelected(selected.first);
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) =>
            dropdownMultiItemBuildWidget(
          item.name,
          isSelected: isSelected ?? false,
        ),
        dropdownBuilder: (context, data) =>
            Text(data?.name ?? "", style: const TextStyle(fontSize: 12)),
      ),
      suffixIcon: _showEditIcon
          ? IconButton(
              icon: const Icon(Icons.edit_outlined, size: 14),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              splashRadius: 14,
              tooltip: "${widget.originalCurrencyCode} "
                  "${_amountFormat.format(widget.originalAmount!.round())}",
              onPressed: _switchToOriginal,
            )
          : null,
      onChanged: widget.onAmountChanged,
    );

    if (widget.tooltipMessage == null) {
      return field;
    }
    return CustomTooltip(message: widget.tooltipMessage!, child: field);
  }
}
