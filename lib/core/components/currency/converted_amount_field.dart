import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// The AED-equivalent companion field rendered beneath a
/// `CurrencyAmountField` when the selected currency is not AED.
///
/// Like its input counterpart this widget is purely presentational: the AED
/// value is pushed in by the view model through [controller], and nothing here
/// converts, fetches a rate or touches a model. Its currency dropdown is
/// locked to AED and has no `onSelected`, so it is a display affordance only.
///
/// Replaces the former `CommonCurrencyConvertField` (which reached into
/// `CreateFacilityViewModel` just to read its currency list) and the two
/// per-field read-only widgets in `create_security`.
///
/// Unlike all three of those, the AED lookup here cannot throw: they used
/// `.where((c) => c.name == "AED").first`, which raises a `StateError` when the
/// currency list is empty or has not loaded AED yet. See [_aedOrFallback].
class ConvertedAmountField extends StatelessWidget {
  /// Creates a [ConvertedAmountField].
  const ConvertedAmountField({
    required this.currencies,
    required this.controller,
    super.key,
    this.isDropdownEnabled = true,
    this.dropdownItemBuilder,
    this.dropdownWidth,
    this.inputFormatters,
    this.readOnly = true,
    this.filled = true,
    this.initialValue = "0",
  });

  /// Currency options for the dropdown — in practice `viewModel.currencyCodes`.
  final List<Reference> currencies;

  /// Controller holding the converted AED amount, written by the view model.
  final TextEditingController controller;

  /// Whether the (AED-locked) dropdown is interactive.
  final bool isDropdownEnabled;

  /// Builder for the dropdown list rows. Defaults to
  /// [currencyDropdownItemBuilder].
  final CurrencyItemBuilder? dropdownItemBuilder;

  /// Width of the currency dropdown. Defaults to `70.w`.
  final double? dropdownWidth;

  /// Input formatters for the amount field.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field rejects input. Defaults to true; the present-security
  /// call site passes false to preserve its long-standing editable behaviour.
  final bool readOnly;

  /// Whether the field paints a fill colour. Defaults to true, for the same
  /// reason as [readOnly].
  final bool filled;

  /// Initial text for the amount field.
  final String? initialValue;

  /// Resolves the AED entry without ever throwing: a blank [Reference] when the
  /// list is empty, the AED entry when present, otherwise the first currency.
  Reference _aedOrFallback() {
    if (currencies.isEmpty) {
      return Reference();
    }
    return currencies.firstWhere(
      (Reference code) => code.name == ServerConstants.aedCurrency,
      orElse: () => currencies.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      initialValue: initialValue,
      readOnly: readOnly,
      filled: filled,
      inputFormatters: inputFormatters,
      prefixIcon: CustomDropdown<Reference>(
        width: dropdownWidth ?? 70.w,
        height: null,
        isEnabled: isDropdownEnabled,
        validationMessage: "validation.emptyField".tr(),
        items: currencies,
        selectedItems: <Reference>[_aedOrFallback()],
        itemBuilder: dropdownItemBuilder ?? currencyDropdownItemBuilder,
        dropdownBuilder: currencyDropdownValueBuilder,
      ),
    );
  }
}
