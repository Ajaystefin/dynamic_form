import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
// import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

Widget dropdownBuilderWidget(
    {required String? text, bool showToolTip = false}) {
  String? selectedText = text == "null" ? "" : text;
  Widget builderWidget = Text(
    selectedText ?? "",
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(fontSize: 13),
  );

  return ExcludeSemantics(
    child: ExcludeFocus(
        child: showToolTip
            ? CustomTooltip(message: "$selectedText", child: builderWidget)
            : builderWidget),
  );
}

Widget dropdownItemBuildWidget(String? text,
    {bool isSelected = false, bool isListTile = true}) {
  return isListTile
      ? ListTile(
          dense: true,
          minVerticalPadding: 0.0,
          textColor: isSelected ? AppColors.black : null,
          tileColor: isSelected ? AppColors.textFieldDisabledFillDarker : null,
          splashColor: AppColors.darkGrey,
          minTileHeight: 35,
          title: Text("$text"))
      : Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          color: isSelected ? AppColors.textFieldDisabledFillDarker : null,
          child: Text(
            "$text",
            style: const TextStyle(fontSize: 12),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        );
}

class CustomDropdown<T> extends StatefulWidget {
  ///List of items to be displayed in the dropdown
  final List<T>? items;
  final bool Function(T, String)? filterFn;
  final MenuAlign? dropdownMenuAlign;
  final String? semanticLabel;

  ///Compare Function
  final bool Function(T, T)? compareFn;

  final Widget Function(BuildContext context, T? item)? dropdownBuilder;

  final Widget Function(
          BuildContext context, T item, bool isDisabled, bool isSelected)?
      itemBuilder;

  final List<T?>? selectedItems;

  ///Callback from the selected items
  final Function(List<T> selectedValue)? onSelected;

  ///isSearchable should be true for the searchabled of the dropdown items
  final bool isSearchable;
  final String? hintText;
  final InputBorder? border;
  final DropdownSuffixProps? dropdownSuffixProps;

  ///Make [isEnabled] flag as false to disable the dropdown
  final bool isEnabled;

  ///The maximum number of selections allowed.
  final int? maxValueSelection;
  final String? validationMessage;

  ///Width of the whole dropdown textfield
  final double? width;
  final double? height;
  final Future<bool?> Function(T? previousValue, T? currentValue)?
      onBeforeChange;
  final bool showHoverColor;
  final Color? hoverColor;
  final bool isLoading;

  final bool showClearIcon;
  final double? maxDropdownHeight;
  const CustomDropdown({
    super.key,
    this.filterFn,
    this.semanticLabel,
    this.height = 50,
    required this.items,
    this.onSelected,
    this.dropdownMenuAlign,
    this.itemBuilder,
    this.selectedItems,
    this.dropdownBuilder,
    this.compareFn,
    this.validationMessage,
    this.isSearchable = false,
    this.hintText,
    this.isEnabled = true,
    this.maxValueSelection,
    this.onBeforeChange,
    this.width,
    this.isLoading = false,
    this.border,
    this.dropdownSuffixProps,
    this.showClearIcon = true,
    this.maxDropdownHeight,
    this.showHoverColor = true,
    this.hoverColor,
  });

  @override
  CustomDropdownState createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  final MultiSelectController<String> multiSelectController =
      MultiSelectController();

  final ValueNotifier<bool> selectAll = ValueNotifier(false);

  Color disabledColor = AppColors.textFieldDisabledFill;

  DropDownDecoratorProps dropDownDecoratorProps(
      InputBorder? border, String? errorMsg) {
    return DropDownDecoratorProps(
        decoration: InputDecoration(
      hintText: widget.hintText,
      enabledBorder: border ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(
              color: errorMsg != null
                  ? AppColors.failure
                  : AppColors.textFieldBorder,
            ),
          ),
      filled: !widget.isEnabled,
      fillColor: disabledColor,
      isDense: true,
      errorStyle: const TextStyle(fontSize: 0),
      border: border ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(
              color: errorMsg != null
                  ? AppColors.failure
                  : AppColors.textFieldBorder,
            ),
          ),
      iconColor: AppColors.accordionPrimary,
    ));
  }

  Widget loadingWidget() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(),
    );
  }

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: SizedBox(
          width: widget.width,
          height: 36,
          child: ValueListenableBuilder<String?>(
              valueListenable: _errorMessage,
              builder: (context, errMsg, _) {
                return CustomTooltip(
                  message: widget.isEnabled ? errMsg ?? "" : "",
                  decoration: BoxDecoration(
                      color: AppColors.lightFailure,
                      borderRadius: BorderRadius.circular(4)),
                  textStyle: const TextStyle(color: AppColors.failure),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: DropdownSearch<T>(
                      onChanged: (value) {
                        if (value != null && widget.onSelected != null) {
                          widget.onSelected!([value]);
                        }
                      },
                      onBeforeChange: widget.onBeforeChange,
                      dropdownBuilder: widget.dropdownBuilder ??
                          (context, T? value) {
                            return dropdownBuilderWidget(
                                text: value.toString());
                          },
                      decoratorProps:
                          dropDownDecoratorProps(widget.border, errMsg),
                      enabled: widget.isEnabled,
                      suffixProps: widget.dropdownSuffixProps ??
                          DropdownSuffixProps(
                            clearButtonProps: ClearButtonProps(
                                icon: const Icon(Icons.clear, size: 16),
                                padding: EdgeInsets
                                    .zero, // zero out the IconButton’s padding
                                constraints: const BoxConstraints(
                                  minWidth: 1,
                                  minHeight: 1,
                                ),
                                isVisible: widget.validationMessage == null &&
                                    widget.showClearIcon),
                            dropdownButtonProps: DropdownButtonProps(
                              iconClosed: widget.isLoading
                                  ? ExcludeSemantics(child: loadingWidget())
                                  : const Icon(Icons.expand_more, size: 20),
                              iconOpened: widget.isLoading
                                  ? loadingWidget()
                                  : const Icon(Icons.expand_less, size: 20),
                            ),
                          ),
                      items: (String item, LoadProps? loadprops) =>
                          widget.items ?? [],
                      compareFn:
                          widget.compareFn ?? (item1, item2) => item1 == item2,
                      filterFn: widget.isSearchable ? widget.filterFn : null,
                      selectedItem: (widget.selectedItems != null &&
                              widget.selectedItems!.isNotEmpty)
                          ? widget.selectedItems!.first
                          : null,
                      validator: (value) {
                        if (!widget.isEnabled) {
                          return null;
                        }
                        if ((value == null) &&
                            widget.validationMessage != null) {
                          _errorMessage.value = widget.validationMessage;
                          //Last update visa
                          return widget.validationMessage;
                        }
                        _errorMessage.value = null;

                        return null;
                      },
                      popupProps: PopupProps.menu(
                        containerBuilder: widget.isSearchable
                            ? null
                            : (context, popupWidget) {
                                return KeyboardListener(
                                    focusNode: _focusNode,
                                    autofocus: true,
                                    includeSemantics: true,
                                    onKeyEvent: (KeyEvent keyEvent) =>
                                        handleKeyEvent(keyEvent, _focusNode),
                                    child:
                                        ExcludeSemantics(child: popupWidget));
                              },
                        itemClickProps: widget.showHoverColor
                            ? ClickProps(
                                hoverColor: widget.hoverColor ??
                                    AppColors.textFieldDisabledFillDarker,
                                focusColor: widget.hoverColor ??
                                    AppColors.textFieldDisabledFillDarker,
                              )
                            : const ClickProps(),
                        showSelectedItems: true,
                        constraints: BoxConstraints(
                            maxHeight: widget.maxDropdownHeight ?? 250),
                        showSearchBox: widget.isSearchable,
                        fit: FlexFit.loose,
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
                            (context, T? value, bool isDisabled,
                                bool isSelected) {
                              return dropdownItemBuildWidget(value.toString(),
                                  isSelected: isSelected);
                            },
                        scrollbarProps: const ScrollbarProps(
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 7,
                          radius: Radius.circular(5),
                          thumbColor: AppColors.goldenYellow,
                          trackColor: AppColors.textFieldDisabledFill,
                        ),
                        searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                            borderSide: const BorderSide(
                              color: AppColors.textFieldBorder,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        )),
                      ),
                    ),
                  ),
                );
              })),
    );
  }
}
