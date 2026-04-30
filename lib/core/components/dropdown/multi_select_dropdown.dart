import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";

enum FontSize { small, medium, large, custom }

class FontSizeHelper {
  FontSizeHelper({required this.size, this.customValue});
  final FontSize size;
  final double? customValue;

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

Widget buildItemText(String? description, FontSizeHelper fontSizeHelper) {
  return Text(
    description ?? "",
    style: TextStyle(
      fontSize: fontSizeHelper.sizeValue,
      color: AppColors.black,
    ),
  );
}

Widget dropdownMultiItemBuildWidget(
  String? text, {
  bool isSelected = false,
  bool isListTile = true,
}) {
  return isListTile
      ? ListTile(
          dense: true,
          minVerticalPadding: 0,
          textColor: isSelected ? AppColors.black : null,
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

Widget dropdownMultiItemBuildScrollWidget(dynamic data, Function(int) widget) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      spacing: 2,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(data.length, (index) {
        return widget(index);
      }),
    ),
  );
}

//Current UI change for country selection
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

//Current UI change for country selection

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
        width: 1,
      ),
    ),
  );
}

class CustomMultiSelectDropdown<T> extends StatefulWidget {
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
  final List<T> items;
  final bool Function(T item1, T item2)? compareFn;
  final bool Function(T, String)? filterFn;
  final Widget Function(BuildContext context, List<T>? items)? dropdownBuilder;
  final List<T>? selectedItems;
  final Function(List<T> selectedValue)? onSelected;
  final bool isSearchable;
  final String? hintText;
  final String? semanticLabel;
  final bool isEnabled;
  final bool showClear;
  final int? maxValueSelection;
  final String? validationMessage;
  final double? width;
  final bool isFilterField;
  final bool? isMultiLine;
  final bool isLoading;
  final Color? fillColor;
  final Widget Function(
    BuildContext context,
    T item,
    bool isDisabled,
    bool isSelected,
  )? itemBuilder;
  final MenuAlign? dropdownMenuAlign;
  final InputBorder? border;
  final bool showHoverColor;

  @override
  CustomMultiSelectDropdownState createState() =>
      CustomMultiSelectDropdownState<T>();
}

class CustomMultiSelectDropdownState<T>
    extends State<CustomMultiSelectDropdown<T>> {
  ValueNotifier<String?> errorMessage = ValueNotifier(null);
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List<T>.from(widget.selectedItems ?? []);
  }

  Color disabledColor = AppColors.textFieldDisabledFill;

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
        filled: widget.fillColor != null ? true : !widget.isEnabled,
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
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: DropdownSearch<T>.multiSelection(
                  onChanged: (value) {
                    // Optional: Keep this if external state needs notification
                    widget.onSelected?.call(value);
                  },
                  dropdownBuilder: widget.dropdownBuilder ??
                      (context, selectedItem) {
                        if (selectedItem.isEmpty) return const SizedBox();

                        final chips =
                            List.generate(selectedItem.length, (index) {
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
                  compareFn:
                      widget.compareFn ?? (item1, item2) => item1 == item2,
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

                    listViewProps: const ListViewProps(
                      padding: EdgeInsets.zero,
                    ),
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
                    itemBuilder: widget.itemBuilder ??
                        (context, T? value, bool isDisabled, bool isSelected) {
                          return dropdownMultiItemBuildWidget(
                            value.toString(),
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
                            width: 1,
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
            ),
          );
        },
      ),
    );
  }
}
