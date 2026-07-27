import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Available font size options.
enum FontSize {
  /// Small font size.
  small,

  /// Medium font size.
  medium,

  /// Large font size.
  large,

  /// Custom font size.
  custom,
}

/// Helper for resolving font sizes.
class FontSizeHelper {
  /// Creates a [FontSizeHelper].
  FontSizeHelper({required this.size, this.customValue});

  /// Selected font size option.
  final FontSize size;

  /// Custom font size value.
  final double? customValue;

  /// Returns the resolved font size value.
  double get sizeValue {
    switch (size) {
      case FontSize.small:
        return AppStyle.fontSizeSmall;
      case FontSize.medium:
        return AppStyle.fontSizeMedium;
      case FontSize.large:
        return AppStyle.fontSizeLarge;
      case FontSize.custom:
        return customValue ?? AppStyle.fontSizeSmall; // fallback to default
    }
  }
}

/// Builds a text widget with the configured font size.
Widget buildItemText(String? description, FontSizeHelper fontSizeHelper) {
  return Text(
    description ?? "",
    style: TextStyle(
      fontSize: fontSizeHelper.sizeValue,
      color: AppColors.black,
    ),
  );
}

/// Builds a multi-select dropdown item widget.
Widget dropdownMultiItemBuildWidget(
  String? text, {
  bool? isSelected = false,
  bool isListTile = true,
}) {
  return isListTile
      ? ListTile(
          dense: true,
          minVerticalPadding: 0,
          textColor: isSelected ?? false ? AppColors.black : null,
          // tileColor: isSelected ? AppColors.darkGrey : null,
          splashColor: AppColors.darkGrey,
          minTileHeight: 32,
          title: Text("$text"),
        )
      : Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          // color: isSelected ? AppColors.black : null,
          child: Text(
            "$text",
            style: const TextStyle(fontSize: 12),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        );
}

/// Builds a horizontally scrollable collection of widgets.
Widget dropdownMultiItemBuildScrollWidget<T>(
  List<T>? data,
  Function(int) widget,
) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      spacing: 2,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(data?.length ?? 0, (index) {
        return widget(index);
      }),
    ),
  );
}

/// Builds the dropdown selection display area.
Widget multiSelectDropDownBuilderWidget({
  required List<dynamic> data,
  required Widget Function(int index) itemBuilder,
  ScrollController? controller,
  double height = AppStyle.multiSelectDropdownHeight,
  double spacing = AppStyle.multiSelectDropdownSpacing,
  double runSpacing = AppStyle.multiSelectDropdownRunSpacing,
  Key? key,
}) {
  return SizedBox(
    height: height,
    child: Theme(
      data: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.goldenYellow),
          trackColor: WidgetStateProperty.all(AppColors.textFieldDisabledFill),
          thickness: WidgetStateProperty.all(5),
          radius: const Radius.circular(4),
          thumbVisibility: WidgetStateProperty.all(true),
          trackVisibility: WidgetStateProperty.all(false),
        ),
      ),
      child: Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          child: Wrap(
            key: key,
            spacing: spacing,
            runSpacing: runSpacing,
            children: List.generate(data.length, itemBuilder),
          ),
        ),
      ),
    ),
  );
}

/// Builds a removable multi-select chip.
Widget buildMultiSelectChip({
  required Widget label,
  required VoidCallback onDeleted,
  Color backgroundColor = AppColors.textFieldDisabledFill, // Default fill
  Color borderColor = AppColors.textFieldBorder, // Default border
}) {
  return Chip(
    deleteIcon: const Icon(Icons.clear, size: 16),
    onDeleted: onDeleted,
    label: label,
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(2),
      side: BorderSide(
        color: borderColor,
      ),
    ),
  );
}

/// A customizable multi-select dropdown widget.
class CustomMultiSelectDropdown<T> extends StatefulWidget {
  /// Creates a [CustomMultiSelectDropdown].
  const CustomMultiSelectDropdown({
    required this.items,
    super.key,
    this.onSelected,
    this.semanticLabel,
    this.isFilterField = false,
    this.filterFn,
    this.selectedItems,
    this.dropdownBuilder,
    this.compareFn,
    this.validationMessage,
    this.isSearchable = false,
    this.hintText,
    this.isEnabled = true,
    this.showClear = false,
    this.maxValueSelection,
    this.width,
    this.isMultiLine = false,
    this.itemBuilder,
    this.isLoading = false,
    this.dropdownMenuAlign,
    this.fillColor,
    this.border,
    this.showHoverColor = true,
  });

  /// Dropdown items.
  final List<T> items;

  /// Item comparison function.
  final bool Function(T item1, T item2)? compareFn;

  /// Search filter function.
  final bool Function(T, String)? filterFn;

  /// Builder for selected items display.
  final Widget Function(BuildContext context, List<T>? items)? dropdownBuilder;

  /// Selected items.
  final List<T>? selectedItems;

  /// Selection callback.
  final Function(List<T> selectedValue)? onSelected;

  /// Enables search.
  final bool isSearchable;

  /// Hint text.
  final String? hintText;

  /// Accessibility label.
  final String? semanticLabel;

  /// Whether the dropdown is enabled.
  final bool isEnabled;

  /// Shows clear button.
  final bool showClear;

  /// Maximum selection count.
  final int? maxValueSelection;

  /// Validation message.
  final String? validationMessage;

  /// Dropdown width.
  final double? width;

  /// Indicates whether this is used as a filter field.
  final bool isFilterField;

  /// Displays selected items on multiple lines.
  final bool? isMultiLine;

  /// Loading state.
  final bool isLoading;

  /// Fill color.
  final Color? fillColor;

  /// Item widget builder.
  final Widget Function(
    BuildContext context,
    T item, {
    bool? isDisabled,
    bool? isSelected,
  })? itemBuilder;

  /// Dropdown menu alignment.
  final MenuAlign? dropdownMenuAlign;

  /// Input border.
  final InputBorder? border;

  /// Enables hover color.
  final bool showHoverColor;

  @override
  CustomMultiSelectDropdownState createState() =>
      CustomMultiSelectDropdownState<T>();
}

/// State for [CustomMultiSelectDropdown].
class CustomMultiSelectDropdownState<T>
    extends State<CustomMultiSelectDropdown<T>> {
  /// Validation error message notifier.
  ValueNotifier<String?> errorMessage = ValueNotifier(null);

  /// Currently selected items.
  late List<T> _selectedItems;

  /// Disabled background color.
  Color disabledColor = AppColors.textFieldDisabledFill;

  @override
  void initState() {
    super.initState();
    _selectedItems = List<T>.from(widget.selectedItems ?? []);
  }

  /// Returns dropdown decoration properties.
  DropDownDecoratorProps dropDownDecoratorProps(InputBorder? border) {
    return DropDownDecoratorProps(
      decoration: InputDecoration(
        hintText: widget.hintText,
        enabledBorder: border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(
                color: AppColors.textFieldBorder,
              ),
            ),
        filled: widget.fillColor != null || !widget.isEnabled,
        fillColor: widget.fillColor ?? disabledColor,
        isDense: true,
        border: border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(
                color: AppColors.textFieldBorder,
              ),
            ),
        iconColor: AppColors.accordionPrimary,
      ),
    );
  }

  /// Builds a loading indicator.
  Widget loadingWidget() {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.hintText,
      enabled: widget.isEnabled,
      child: ValueListenableBuilder<String?>(
        valueListenable: errorMessage,
        builder: (BuildContext context, String? errorText, _) {
          return SizedBox(
            width: widget.width,
            height: widget.isFilterField ? 36 : null,
            child: CustomTooltip(
              message: errorText ?? "",
              decoration: BoxDecoration(
                color: AppColors.lightFailure,
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(color: AppColors.failure),
              child: DropdownSearch<T>.multiSelection(
                onChanged: (value) {
                  // Optional: Keep this if external state needs notification
                  widget.onSelected?.call(value);
                },
                dropdownBuilder: widget.dropdownBuilder ??
                    (context, selectedItem) {
                      if (selectedItem.isEmpty) {
                        return const SizedBox();
                      }

                      final chips = List.generate(selectedItem.length, (index) {
                        return Chip(
                          deleteIconColor: widget.isEnabled
                              ? null
                              : AppColors.textFieldBorder,
                          onDeleted: widget.isEnabled
                              ? () {
                                  setState(() {
                                    _selectedItems.removeAt(index);
                                  });
                                  widget.onSelected?.call(_selectedItems);
                                }
                              : null,
                          label: Text(selectedItem[index].toString()),
                        );
                      });

                      if (widget.isMultiLine ?? false) {
                        return Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: chips,
                        );
                      } else {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: chips),
                        );
                      }
                    },
                suffixProps: DropdownSuffixProps(
                  clearButtonProps: ClearButtonProps(
                    icon: const Icon(Icons.clear, size: 16),
                    isVisible: widget.showClear,
                  ),
                  dropdownButtonProps: DropdownButtonProps(
                    iconClosed: widget.isLoading
                        ? loadingWidget()
                        : const Icon(Icons.expand_more, size: 20),
                    iconOpened: widget.isLoading
                        ? loadingWidget()
                        : const Icon(Icons.expand_less, size: 20),
                  ),
                ),
                decoratorProps: dropDownDecoratorProps(widget.border),
                enabled: widget.isEnabled,
                items: (f, cs) => widget.items,
                compareFn: widget.compareFn ?? (item1, item2) => item1 == item2,
                filterFn: widget.isSearchable ? widget.filterFn : null,
                selectedItems: _selectedItems,
                validator: (value) {
                  if ((value?.isEmpty ?? false) &&
                      widget.validationMessage != null) {
                    errorMessage.value = widget.validationMessage;
                  } else {
                    errorMessage.value = null;
                  }
                  return errorMessage.value;
                },
                popupProps: PopupPropsMultiSelection.menu(
                  showSearchBox: widget.isSearchable,
                  showSelectedItems: true,
                  fit: FlexFit.loose,

                  scrollbarProps: const ScrollbarProps(
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 5,
                    radius: Radius.circular(4),
                    thumbColor: AppColors.goldenYellow,
                    trackColor: AppColors.textFieldDisabledFill,
                  ),

                  itemClickProps: widget.showHoverColor
                      ? const ClickProps(
                          hoverColor: AppColors.textFieldDisabledFillDarker,
                          focusColor: AppColors.textFieldDisabledFillDarker,
                        )
                      : const ClickProps(),
                  menuProps: MenuProps(
                    align: widget.dropdownMenuAlign,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: const BorderSide(
                        color: AppColors.textFieldBorder,
                        width: 1.5,
                      ),
                    ),
                    backgroundColor: AppColors.white,
                    color: AppColors.white,
                  ),
                  itemBuilder: (context, item, isSelected, isDisabled) {
                    if (widget.itemBuilder != null) {
                      return widget.itemBuilder!(
                        context,
                        item,
                        isSelected: isSelected,
                        isDisabled: isDisabled,
                      );
                    }
                    return dropdownMultiItemBuildWidget(
                      item.toString(),
                      isSelected: isSelected,
                    );
                  },
                  searchFieldProps: TextFieldProps(
                    maxLength:
                        //If any specific requirement to change, can add this
                        //as parameter in widget
                        50,
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: AppColors.textFieldBorder,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  //Instant selection with state update
                  onItemAdded: (selectedItems, item) {
                    setState(() {
                      _selectedItems = List<T>.from(selectedItems);
                    });
                    widget.onSelected?.call(_selectedItems);
                  },
                  onItemRemoved: (selectedItems, item) {
                    setState(() {
                      _selectedItems = List<T>.from(selectedItems);
                    });
                    widget.onSelected?.call(_selectedItems);
                  },
                  validationBuilder: (context, items) =>
                      Container(), //to remove Okay button
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
