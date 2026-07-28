import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// An amount input whose `prefixIcon` is a currency-code dropdown — the shared
/// composition behind every currency field in `create_facility` and
/// `create_security`.
///
/// This widget is deliberately **presentational**. It owns no state, creates no
/// [TextEditingController], performs no exchange-rate conversion and never
/// references a view model. Every model write, validation rule and conversion
/// trigger stays in the caller's callbacks. It exists solely to hold the
/// dropdown-inside-a-text-field composition in one place.
///
/// Three parameters carry that guarantee and should not be "simplified":
///
/// * [selectedCurrencies] is forwarded **verbatim**. Call sites differ in what
///   they produce when nothing is selected (an empty list, a list holding null,
///   a list holding a blank `Reference`, or the first currency) and those are
///   not interchangeable inputs to the
///   dropdown, so this widget does not normalise them to a code string.
/// * [inputFormatters] has **no default**. Several fields legitimately apply no
///   formatters at all, and a couple use a different formatter *ordering*;
///   defaulting here would silently change what those fields accept. Use
///   [currencyAmountFormatters] or [securityAmountFormatters] explicitly.
/// * [fieldKey] is applied to the inner [CustomTextField] rather than to this
///   widget, because a key there is what forces the field's cached
///   `initialValue` to be re-read.
///
/// The build output is intentionally just an optional [LabelWidget] wrapping a
/// [CustomTextField]. Do **not** introduce an `InheritedWidget`, `Provider`,
/// `Builder` or `Overlay` in between: [CustomTextField] and [CustomDropdown]
/// each resolve `FormAccessProvider.of(context)` from their own context, so
/// re-scoping would silently change every field's enabled state.
class CurrencyAmountField extends StatelessWidget {
  /// Creates a [CurrencyAmountField].
  const CurrencyAmountField({
    required this.currencies,
    required this.selectedCurrencies,
    super.key,
    this.label,
    this.isLabelRequired = false,
    this.isLabelEnabled = true,
    this.labelInfoContent,
    this.onCurrencySelected,
    this.isDropdownEnabled = true,
    this.isDropdownLoading = false,
    this.dropdownItemBuilder,
    this.dropdownWidth,
    this.fieldKey,
    this.controller,
    this.initialValue,
    this.hintText,
    this.readOnly = false,
    this.filled = false,
    this.fillColor,
    this.ignoreProvider = false,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
  });

  /// Currency options for the dropdown — in practice `viewModel.currencyCodes`.
  final List<Reference> currencies;

  /// Forwarded verbatim to the dropdown's selected items. Only the first entry
  /// is read. See the class doc for why this is not normalised.
  final List<Reference?> selectedCurrencies;

  /// Invoked with the picked currency, and **only** when the dropdown reports a
  /// non-empty selection — reproducing the `if (selectedValue.isNotEmpty)`
  /// guard present at every original call site.
  final ValueChanged<Reference>? onCurrencySelected;

  /// Label rendered above the field. When null the bare field is returned with
  /// no [LabelWidget] wrapper.
  final String? label;

  /// Renders the required asterisk on the label.
  final bool isLabelRequired;

  /// Enables or disables the label (which greys and blocks pointer input on
  /// its child).
  final bool isLabelEnabled;

  /// Optional info-icon tooltip content on the label.
  final String? labelInfoContent;

  /// Whether the currency dropdown is interactive.
  final bool isDropdownEnabled;

  /// Shows a spinner in place of the dropdown's chevron.
  final bool isDropdownLoading;

  /// Builder for the dropdown list rows. Defaults to
  /// [currencyDropdownItemBuilder]; pass [currencyListTileItemBuilder] to keep
  /// the plainer `create_security` styling.
  final CurrencyItemBuilder? dropdownItemBuilder;

  /// Width of the currency dropdown. Defaults to `70.w`.
  final double? dropdownWidth;

  /// Key applied to the inner [CustomTextField], not to this widget.
  final Key? fieldKey;

  /// Controller for the amount field.
  final TextEditingController? controller;

  /// Initial text for the amount field. Several call sites pass this alongside
  /// a [controller]; that combination is preserved deliberately.
  final String? initialValue;

  /// Placeholder shown when the amount field is empty.
  final String? hintText;

  /// Whether the amount field rejects input.
  final bool readOnly;

  /// Whether the amount field paints a fill colour.
  final bool filled;

  /// Fill colour for the amount field.
  final Color? fillColor;

  /// Opts the amount field out of the ambient form-access provider.
  final bool ignoreProvider;

  /// Keyboard type for the amount field.
  final TextInputType? keyboardType;

  /// Alignment of the amount text.
  final TextAlign textAlign;

  /// Text style for the amount value. Null falls through to
  /// [CustomTextField]'s own default.
  final TextStyle? textStyle;

  /// Input formatters. No default — see the class doc.
  final List<TextInputFormatter>? inputFormatters;

  /// Validator for the amount field.
  final String? Function(String?)? validator;

  /// Called with the raw field text on every change.
  final Function(String)? onChanged;

  /// Called with the raw field text when the enclosing form is saved.
  final Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    final Widget field = CustomTextField(
      key: fieldKey,
      controller: controller,
      initialValue: initialValue,
      hintText: hintText,
      readOnly: readOnly,
      filled: filled,
      fillColor: fillColor,
      ignoreProvider: ignoreProvider,
      keyboardType: keyboardType,
      textAlign: textAlign,
      textStyle: textStyle,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      prefixIcon: CustomDropdown<Reference>(
        width: dropdownWidth ?? 70.w,
        height: null,
        isEnabled: isDropdownEnabled,
        isLoading: isDropdownLoading,
        validationMessage: "validation.emptyField".tr(),
        items: currencies,
        selectedItems: selectedCurrencies,
        onSelected: (List<Reference> selectedValue) {
          if (selectedValue.isNotEmpty) {
            onCurrencySelected?.call(selectedValue.first);
          }
        },
        itemBuilder: dropdownItemBuilder ?? currencyDropdownItemBuilder,
        dropdownBuilder: currencyDropdownValueBuilder,
      ),
    );

    if (label == null) {
      return field;
    }

    return LabelWidget(
      label: label!,
      isRequired: isLabelRequired,
      isEnabled: isLabelEnabled,
      infoContent: labelInfoContent,
      child: field,
    );
  }
}
