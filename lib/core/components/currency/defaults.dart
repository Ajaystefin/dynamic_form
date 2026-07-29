import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Signature of `CustomDropdown.itemBuilder` specialised to [Reference].
///
/// Declared here so callers can hand a builder to `CurrencyAmountField` /
/// `ConvertedAmountField` without restating the four-parameter shape.
typedef CurrencyItemBuilder = Widget Function(
  BuildContext context,
  Reference item, {
  bool? isSelected,
  bool? isDisabled,
});

/// Formatters used by the `create_facility` currency amount fields:
/// length-capped, digits only, with thousands separators inserted as you type.
///
/// Deliberately a function rather than a `const` list — [ThousandsSeparatorFormatter]
/// is not const-constructible, and each field needs its own instance.
///
/// Note the ordering: [LengthLimitingTextInputFormatter] runs **before**
/// [ThousandsSeparatorFormatter], so the cap applies to the raw digits rather
/// than to the comma-grouped text. A field that needs the opposite ordering
/// must pass its own list rather than calling this helper.
List<TextInputFormatter> currencyAmountFormatters({int maxLength = 15}) {
  return <TextInputFormatter>[
    LengthLimitingTextInputFormatter(maxLength),
    FilteringTextInputFormatter.digitsOnly,
    ThousandsSeparatorFormatter(),
  ];
}

/// Formatters used by the `create_security` amount fields.
///
/// Intentionally omits [ThousandsSeparatorFormatter]: those fields insert their
/// own commas inside `onChanged` by writing a formatted value straight back to
/// the controller. Adding the formatter here would double up that work.
List<TextInputFormatter> securityAmountFormatters({int maxLength = 15}) {
  return <TextInputFormatter>[
    LengthLimitingTextInputFormatter(maxLength),
    FilteringTextInputFormatter.digitsOnly,
  ];
}

/// The value to write back to the model for an amount field whose display is
/// rounded.
///
/// Amount fields show `NumberFormat("#,###")` of a rounded value, so parsing the
/// field's own text on save would push that rounding into the payload — an API
/// value of `1234.6` would be saved as `1235`. When [text] still equals the
/// formatted [original] the user has not edited the field, so the untouched API
/// value is returned instead. Otherwise the text is parsed as usual.
///
/// Mirrors `_amountForEmit` in the dynamic form's `CurrencyDropdown`. Only
/// meaningful for fields backed by a fractional model property; the
/// `create_facility` amounts are all `int?` and need no such guard.
double? amountForEmit(String? text, num? original) {
  final String raw = text ?? "";

  if (original != null &&
      NumberFormat("#,###").format(original.round()) == raw) {
    return original.toDouble();
  }

  return double.tryParse(raw.replaceAll(",", ""));
}

/// Default dropdown item builder — the selection-aware list row used by every
/// `create_facility` currency field.
Widget currencyDropdownItemBuilder(
  BuildContext context,
  Reference item, {
  bool? isSelected,
  bool? isDisabled,
}) {
  return dropdownMultiItemBuildWidget(
    item.name,
    isSelected: isSelected ?? false,
  );
}

/// Plain [ListTile] dropdown item builder, preserving the look of the
/// `create_security` currency dropdowns (which never showed selection state).
Widget currencyListTileItemBuilder(
  BuildContext context,
  Reference item, {
  bool? isSelected,
  bool? isDisabled,
}) {
  return ListTile(title: Text(item.name ?? ""));
}

/// Builds the collapsed display for the currency dropdown — the bare ISO code.
///
/// A top-level function rather than an inline closure so it does not defeat
/// const-ness at the call site.
Widget currencyDropdownValueBuilder(BuildContext context, Reference? data) {
  return Text(data?.name ?? "", style: const TextStyle(fontSize: 12));
}
