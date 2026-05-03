import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";

class CustomDropdownMenuButton extends StatefulWidget {
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
  final String label;
  final bool? isLoading;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  final CustomDropdownItem? initialOption;
  final List<CustomDropdownItem>? options;
  final bool isSearchable;
  final Function(String)? callBack;
  final Function((String, void Function()?)?)? validation;
  final bool showValueWithLabel;
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
            selectedButtonModel?.value.trim().isNotEmpty == true;
        final String baseLabel = widget.label;
        final String selectedLabel = selectedButtonModel?.label ?? "";
        final String label = hasSelected
            ? (widget.showValueWithLabel
                ? "$baseLabel : $selectedLabel"
                : selectedLabel)
            : baseLabel;
        final GlobalKey buttonKey = GlobalKey();
        return Semantics(
          label: label,
          button: true,
          child: CompositedTransformTarget(
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
                          if (item.isHeader) return;
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
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
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

              return ListTile(
                title: Text(item.label ?? ""),
                onTap: () => widget.onSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }

  List<CustomDropdownItem> _filterItems() {
    if (query.isEmpty) return widget.items;

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
