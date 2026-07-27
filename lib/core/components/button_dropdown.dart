import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// A customizable dropdown button that supports item selection,
/// searching, validation, and custom actions.
class CustomDropdownButton extends StatefulWidget {
  /// Creates a [CustomDropdownButton].
  ///
  /// The [label] parameter is required.
  const CustomDropdownButton({
    required this.label,
    super.key,
    this.isLoading,
    this.tooltip,
    this.backgroundColor,
    this.disabledColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.initialOption,
    this.options,
    this.isSearchable = true,
    this.showValueWithLabel = true,
    this.callBack,
    this.validation,
    this.callBackWithHeader,
    this.onButtonPressed,
  });

  /// Text displayed on the dropdown button.
  final String label;

  /// Indicates whether the button is in a loading state.
  final bool? isLoading;

  /// Tooltip displayed when hovering over the button.
  final String? tooltip;

  /// Background color of the button.
  final Color? backgroundColor;

  /// Background color when the button is disabled.
  final Color? disabledColor;

  /// Color of the button text.
  final Color? textColor;

  /// Width of the button.
  final double? width;

  /// Height of the button.
  final double? height;

  /// Border radius of the button.
  final double? borderRadius;

  /// Text style applied to the label.
  final TextStyle? textStyle;

  /// Initially selected dropdown option.
  final CustomDropdownItem? initialOption;

  /// Available dropdown options.
  final List<CustomDropdownItem>? options;

  /// Determines whether search is enabled.
  final bool isSearchable;

  /// Callback invoked when an item is selected.
  final Function(String)? callBack;

  /// Validation callback for the selected value.
  final Function((String, void Function()?)?)? validation;

  /// Determines whether the value is displayed together with its label.
  final bool showValueWithLabel;

  /// Optional callback that provides both the selected value
  /// and the corresponding header name (for example, a BPM role).
  final void Function(String value, String? headerName)? callBackWithHeader;

  /// Callback invoked when the button is pressed.
  final VoidCallback? onButtonPressed;

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  void Function()? _initialOnPressed;

  final dropdownKey =
      GlobalKey<DropdownSearchState<(String?, dynamic, Function()?)>>();
  ValueNotifier<CustomDropdownItem?>? selectedButtonModelVN =
      ValueNotifier(null);

  /// Maps item value -> header (e.g., bpmRole) computed from options.
  Map<String, String> _valueToHeader = {};

  bool get _hasSelection {
    final v = selectedButtonModelVN?.value?.value;
    return v != null && v.toString().trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

// IMPORTANT: Start with no selection state for your requirement
    // Do not force initialOption; only set if you truly want a prefill.
    if (widget.initialOption != null &&
        (widget.initialOption!.value?.toString().trim().isNotEmpty ?? false)) {
      selectedButtonModelVN?.value = widget.initialOption;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Capture late-arriving initial action (if options load async)
    if (_initialOnPressed == null && widget.initialOption?.onPressed != null) {
      _initialOnPressed = widget.initialOption!.onPressed;
    }

    // Ensure we always have a selected item, and re-sync when the parent
    // changes the selection programmatically (e.g. currency updated from
    // outside), not just when there was no prior selection.
    final bool selectionChanged =
        widget.initialOption?.value != oldWidget.initialOption?.value;
    if (widget.initialOption != null &&
        (selectedButtonModelVN?.value == null || selectionChanged)) {
      selectedButtonModelVN?.value = widget.initialOption;
    }
  }

  /// Build value -> header map from options list, based on header sentinel
  /// rows.
  /// Header rows follow the format: value starts with "__header__:" and label
  /// is the visible header text.
  Map<String, String> _makeHeaderMap(List<CustomDropdownItem> options) {
    final map = <String, String>{};
    String? currentHeader;

    for (final opt in options) {
      final valueStr = (opt.value ?? "").toString();
      final labelStr = opt.label ?? "";

      if (valueStr.startsWith("__header__:")) {
        // Treat this row as a header row.
        // Prefer the label as the visible header; fallback to value’s tail if
        // needed.
        currentHeader = labelStr.isNotEmpty
            ? labelStr
            : valueStr.substring("__header__:".length).trim();
        continue;
      }

      // Associate non-header items to the most recent header (if any).
      if (currentHeader != null && valueStr.isNotEmpty) {
        map[valueStr] = currentHeader;
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options ?? const <CustomDropdownItem>[];
    // Refresh header map per build; cheap and resilient to dynamic option
    // changes.
    _valueToHeader = _makeHeaderMap(options);

    final bool isProviderDisabled = FormAccessProvider.of(context);

    return ValueListenableBuilder<CustomDropdownItem?>(
      valueListenable: selectedButtonModelVN ?? ValueNotifier(null),
      builder: (context, selectedButtonModel, _) {
        // String labels = widget.showValueWithLabel
        //     ? "${widget.label} ${selectedButtonModel?.label ?? ""}"
        //     : selectedButtonModel?.label ?? widget.label;

        // Labeling:
        // - No selection: show base label only (e.g., "Return")
        // - With selection: show label + selected (if showValueWithLabel =
        // true)
        final base = widget.label;
        final selLabel = (selectedButtonModel?.label ?? "").trim();
        final String label = _hasSelection
            ? (widget.showValueWithLabel
                ? (selLabel.isEmpty ? base : "$base $selLabel")
                : (selLabel.isEmpty ? base : selLabel))
            : base;

        return Semantics(
          label: label,
          button: true,
          child: CustomButton(
            label: label,
            height: widget.height,
            width: widget.width,
            isLoading: widget.isLoading ?? false,
            textColor: widget.textColor,
            textStyle: widget.textStyle,
            tooltip: widget.tooltip,
            backgroundColor: widget.backgroundColor,
            disabledColor: widget.disabledColor,
            borderRadius: widget.borderRadius ?? 4.0,

// Core behavior:
            // - No selection => open dropdown
            // - With selection => run your provided action (e.g., onSavePress)
            onPressed: () {
              if (_hasSelection) {
                // Run the action if provided
                if (widget.onButtonPressed != null) {
                  widget.onButtonPressed!();
                } else {
                  // Fallback: open dropdown if no action wired
                  dropdownKey.currentState?.openDropDownSearch();
                }
              } else {
                // No selection yet: open dropdown
                dropdownKey.currentState?.openDropDownSearch();
              }
            },

            trailingIcon: DropdownSearch<(String?, dynamic, Function()?)>(
              key: dropdownKey,
              mode: Mode.custom,
              enabled: !isProviderDisabled &&
                  options.isNotEmpty &&
                  widget.options != null &&
                  (widget.callBack != null ||
                      widget.callBackWithHeader != null),
              popupProps: PopupProps.menu(
                showSearchBox: widget.isSearchable,
                fit: FlexFit.loose,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                itemBuilder: (context, item, isDisabled, isSelected) {
                  final String effectiveLabel = (item.$1 ?? "").trim();
                  final String effectiveValue = (item.$2 ?? "").toString();
                  final bool isHeader =
                      effectiveValue.startsWith("__header__:");

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      effectiveLabel.isEmpty ? "—" : effectiveLabel,
                      style: isHeader
                          ? const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )
                          : const TextStyle(fontSize: 13),
                    ),
                  );
                },
              ),
              onChanged: (selectedOption) {
                final value = selectedOption?.$2?.toString() ?? "";
                if (value.startsWith("__header__:")) {
                  return;
                }

                // The popup fires onChanged synchronously as part of its own
                // Navigator.pop() teardown. Updating state in that same frame
                // throws "widget tree was locked" (framework still finalizing
                // the popup's route). Defer to the next frame, once the popup
                // has fully closed.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) {
                    return;
                  }

                  // Keep your existing callbacks
                  widget.callBack?.call(value);
                  // If you added header mapping earlier:
                  widget.callBackWithHeader?.call(value, _valueToHeader[value]);

                  // IMPORTANT: Do not rely on $3 anymore
                  selectedButtonModelVN?.value = CustomDropdownItem(
                    label: selectedOption?.$1,
                    value: selectedOption?.$2,
                  );
                });
              },
              items: (f, cs) => options
                  .map(
                    (option) => (option.label, option.value, option.onPressed),
                  )
                  .toList(),
              compareFn: (item1, item2) => item1.$1 == item2.$1,
              dropdownBuilder: (ctx, selectedItem) => Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: widget.textColor ?? AppColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
