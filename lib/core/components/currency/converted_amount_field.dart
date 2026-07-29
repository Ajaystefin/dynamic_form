import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
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
/// Used by every AED field in `create_facility` and `create_security`. The AED
/// lookup cannot throw whatever the caller passes — an empty currency list or
/// one that has not loaded AED yet still renders. See [_aedOrFallback].
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
    this.isLoadingListenable,
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
  /// call site passes false, where the AED box is editable.
  final bool readOnly;

  /// Whether the field paints a fill colour. Defaults to true, and is passed
  /// false alongside [readOnly] at that same call site.
  final bool filled;

  /// Initial text for the amount field.
  final String? initialValue;

  /// Drives a small spinner in the field's suffix while an exchange-rate fetch
  /// is pending (debouncing) or in flight.
  ///
  /// The view model owns the notifier; this widget only listens. When null no
  /// suffix is rendered at all, so call sites that never fetch a rate are
  /// unaffected.
  final ValueListenable<bool>? isLoadingListenable;

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

  /// The rate-fetch spinner.
  ///
  /// The [SizedBox] is rendered whether or not a fetch is running so the field
  /// does not shift when the spinner appears.
  Widget _loaderSuffix(ValueListenable<bool> listenable) {
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (BuildContext context, bool isLoading, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGrey),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ValueListenable<bool>? loading = isLoadingListenable;

    return CustomTextField(
      controller: controller,
      initialValue: initialValue,
      readOnly: readOnly,
      filled: filled,
      inputFormatters: inputFormatters,
      suffixIcon: loading == null ? null : _loaderSuffix(loading),
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
