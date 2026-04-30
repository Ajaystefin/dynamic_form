import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";

class CustomDropdownButton extends StatefulWidget {
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

  // NEW: include roleCode
  final void Function(String value, String? headerName, String? roleCode)?
      callBackWithHeader;

  final Function((String, void Function()?)?)? validation;
  final bool showValueWithLabel;

  final VoidCallback? onButtonPressed;

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  late final ValueNotifier<CustomDropdownItem?> selectedButtonModelVN;
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
      valueListenable: selectedButtonModelVN,
      builder: (context, selected, _) {
        final bool hasSelected = selected?.value?.trim().isNotEmpty == true;

        final String baseLabel = widget.label;
        final String selectedLabel = selected?.label ?? "";

        final String label = hasSelected
            ? (widget.showValueWithLabel
                ? "$baseLabel : $selectedLabel"
                : selectedLabel)
            : baseLabel;

        return Semantics(
          label: label,
          button: true,
          child: CompositedTransformTarget(
            link: _layerLink,
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
              onPressed: () => widget.onButtonPressed?.call(), // unchanged
              trailingIcon: GestureDetector(
                onTap: () => _openDropdown(context),
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

  // -------------------------------------------------------------------
  // OPEN DROPDOWN
  // -------------------------------------------------------------------

  void _openDropdown(BuildContext context) {
    if (_overlayEntry != null) {
      _removeDropdown();
      return;
    }

    final OverlayState overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
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
                      isSearchable: widget.isSearchable,
                      onSelected: (item, parentHeader, roleCode) {
                        if (item.isHeader) return;

                        selectedButtonModelVN.value = item;

                        final String valueStr = item.value?.toString() ?? "";
                        widget.callBack?.call(valueStr);

                        // now pass the roleCode too
                        widget.callBackWithHeader
                            ?.call(valueStr, parentHeader, roleCode);

                        _removeDropdown();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// =====================================================================
// POPUP COMPONENT — with Header Support, Group Filter, Option 1 Mapping
// =====================================================================
class _DropdownPopup extends StatefulWidget {
  const _DropdownPopup({
    required this.items,
    required this.onSelected,
    required this.isSearchable,
  });
  final List<CustomDropdownItem> items;
  final bool isSearchable;

  ///Sends (item, parentHeaderLabel)
  final void Function(
    CustomDropdownItem item,
    String? parentHeader,
    String? roleCode,
  ) onSelected;

  @override
  State<_DropdownPopup> createState() => _DropdownPopupState();
}

class _DropdownPopupState extends State<_DropdownPopup> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = _filterItems();

    return Column(
      children: [
        if (widget.isSearchable)
          Padding(
            padding: const EdgeInsets.all(6),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];

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
                onTap: () =>
                    widget.onSelected(item, item.headerName, item.roleCode),
              );
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------
  // HEADER FILTERING + ASSIGN PARENT HEADER (Option 1)
  // --------------------------------------------------------------
  List<CustomDropdownItem> _filterItems() {
    // When not searching, still attach headerName/roleCode to children
    if (query.isEmpty) {
      CustomDropdownItem? currentHeader;
      for (final item in widget.items) {
        if (item.isHeader) {
          currentHeader = item;
          continue;
        }
        // mutate in place (no copyWith)
        item.headerName ??= currentHeader?.label;
        item.roleCode ??= currentHeader?.roleCode;
      }
      return widget.items;
    }

    // Searching path:
    final List<CustomDropdownItem> result = [];
    CustomDropdownItem? currentHeader;
    List<CustomDropdownItem> matched = [];

    for (final item in widget.items) {
      if (item.isHeader) {
        if (matched.isNotEmpty && currentHeader != null) {
          result.add(currentHeader);
          result.addAll(matched);
        }
        currentHeader = item;
        matched = [];
        continue;
      }

      final lbl = (item.label ?? "").toLowerCase();
      if (lbl.contains(query.toLowerCase())) {
        // mutate in place (no copyWith)
        item.headerName ??= currentHeader?.label;
        item.roleCode ??= currentHeader?.roleCode;
        matched.add(item);
      }
    }

    if (matched.isNotEmpty && currentHeader != null) {
      result.add(currentHeader);
      result.addAll(matched);
    }

    return result;
  }
}
