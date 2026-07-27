import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";

/// A custom button widget with an attached dropdown menu.
///
/// The button displays a label and optionally shows the selected dropdown item
/// along with the label. The dropdown supports searchable options and grouped
/// header items.
class CustomDropdownMenuButton extends StatefulWidget {
  /// Creates a custom dropdown menu button.
  const CustomDropdownMenuButton({
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
    this.onButtonPressed,
  });

  /// The default label displayed on the button.
  final String label;

  /// Indicates whether the button should show a loading state.
  final bool? isLoading;

  /// Optional tooltip text for the button.
  final String? tooltip;

  /// Optional background color for the button.
  final Color? backgroundColor;

  /// Optional disabled color for the button.
  final Color? disabledColor;

  /// Optional text color for the button label.
  final Color? textColor;

  /// Optional width of the button.
  final double? width;

  /// Optional height of the button.
  final double? height;

  /// Optional border radius for the button.
  final double? borderRadius;

  /// Optional text style for the button label.
  final TextStyle? textStyle;

  /// The initially selected dropdown option.
  final CustomDropdownItem? initialOption;

  /// The list of dropdown options to display.
  final List<CustomDropdownItem>? options;

  /// Indicates whether the dropdown should show a search field.
  final bool isSearchable;

  /// Callback triggered when a dropdown item is selected.
  final Function(String)? callBack;

  /// Optional validation callback for the selected dropdown value.
  final Function((String, void Function()?)?)? validation;

  /// Indicates whether the button label should include both base label and selected value.
  final bool showValueWithLabel;

  /// Callback triggered when the main button area is pressed.
  final VoidCallback? onButtonPressed;

  @override
  State<CustomDropdownMenuButton> createState() =>
      _CustomDropdownMenuButtonState();
}

class _CustomDropdownMenuButtonState extends State<CustomDropdownMenuButton> {
  late final ValueNotifier<CustomDropdownItem?>? selectedButtonModelVN;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  @override
  void initState() {
    super.initState();
    selectedButtonModelVN =
        ValueNotifier<CustomDropdownItem?>(widget.initialOption);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CustomDropdownItem?>(
      valueListenable: selectedButtonModelVN ?? ValueNotifier(null),
      builder: (context, selectedButtonModel, _) {
        final bool hasSelected =
            selectedButtonModel?.value.trim().isNotEmpty ?? false;
        final String baseLabel = widget.label;
        final String selectedLabel = selectedButtonModel?.label ?? "";
        final String label = hasSelected
            ? (widget.showValueWithLabel
                ? "$baseLabel : $selectedLabel"
                : selectedLabel)
            : baseLabel;
        final GlobalKey buttonKey = GlobalKey();

        return CompositedTransformTarget(
          link: _layerLink,
          child: CustomButton(
            key: buttonKey,
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
            onPressed: () => widget.onButtonPressed!(),
            trailingIcon: GestureDetector(
              onTap: () {
                _openDropdown(context);
              },
              child: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDropdown(BuildContext context) async {
    if (_overlayEntry != null) {
      _removeDropdown();
      return;
    }

    final overlay = Overlay.of(context);
    //  if(overlay == null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeDropdown,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, -(widget.height ?? 100) - 100),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(6),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 300, maxWidth: 200),
                      child: _DropdownPopup(
                        items: widget.options ?? const [],
                        onSelected: (item) {
                          if (item.isHeader) {
                            return;
                          }
                          selectedButtonModelVN?.value = item;
                          widget.callBack?.call(item.value);
                          _removeDropdown();
                        },
                        isSearchable: widget.isSearchable,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _DropdownPopup extends StatefulWidget {
  const _DropdownPopup({
    required this.items,
    required this.onSelected,
    required this.isSearchable,
  });

  final List<CustomDropdownItem> items;
  final bool isSearchable;
  final ValueChanged<CustomDropdownItem> onSelected;

  @override
  State<_DropdownPopup> createState() => _DropdownPopupState();
}

class _DropdownPopupState extends State<_DropdownPopup> {
  String query = "";
  @override
  Widget build(BuildContext context) {
    final filteredItem = _filterItems();

    return Column(
      children: [
        if (widget.isSearchable)
          Padding(
            padding: const EdgeInsets.all(6),
            child: Semantics(
              label: "dropdown_search_field", //  automation ID
              textField: true,
              child: TextField(
                onChanged: (v) => setState(() => query = v),
                decoration:
                    const InputDecoration(prefixIcon: Icon(Icons.search)),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItem.length,
            itemBuilder: (context, index) {
              final item = filteredItem[index];

              if (item.isHeader) {
                return Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    item.label ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }

              return Semantics(
                label: item.value, // unique automation ID
                button: true,
                child: ListTile(
                  key: ValueKey(item.value), // important
                  title: Text(item.label ?? ""),
                  onTap: () => widget.onSelected(item),
                ),
              );

              // return ListTile(
              //   title: Text(item.label ?? ""),
              //   onTap: () => widget.onSelected(item),
              // );
            },
          ),
        ),
      ],
    );
  }

  List<CustomDropdownItem> _filterItems() {
    if (query.isEmpty) {
      return widget.items;
    }

    final List<CustomDropdownItem> result = [];

    CustomDropdownItem? currentHeader;
    final List<CustomDropdownItem> matchedChildren = [];

    for (final item in widget.items) {
      if (item.isHeader) {
        if (matchedChildren.isNotEmpty) {
          result
            ..add(currentHeader!)
            ..addAll(matchedChildren);
        }

        currentHeader = item;
        matchedChildren.clear();
      } else {
        if (item.label?.toLowerCase().contains(query.toLowerCase()) ?? false) {
          matchedChildren.add(item);
        }
      }
    }

    if (matchedChildren.isNotEmpty) {
      result
        ..add(currentHeader!)
        ..addAll(matchedChildren);
    }

    return result;
  }
}
