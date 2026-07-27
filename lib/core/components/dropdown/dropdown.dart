import "package:dropdown_search/dropdown_search.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:multi_dropdown/multi_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// Builds a dropdown display widget.
Widget dropdownBuilderWidget({
  required String? text,
  bool showToolTip = false,
}) {
  final String selectedText = (text == "null" || text == null) ? "" : text;
  final Widget builderWidget = Text(
    selectedText,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(fontSize: 13),
  );

  return ExcludeSemantics(
    child: ExcludeFocus(
      child: showToolTip
          ? CustomTooltip(message: selectedText, child: builderWidget)
          : builderWidget,
    ),
  );
}

/// Builds a dropdown item widget.
Widget dropdownItemBuildWidget(
  String? text, {
  bool isSelected = false,
  bool isListTile = true,
}) {
  if (isListTile) {
    return ListTile(
      dense: true,
      minVerticalPadding: 0,
      textColor: isSelected ? AppColors.black : null,
      tileColor: isSelected ? AppColors.textFieldDisabledFillDarker : null,
      splashColor: AppColors.darkGrey,
      minTileHeight: 35,
      title: Text(
        "$text",
        maxLines: 3,
        overflow: TextOverflow.ellipsis, //
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    color: isSelected ? AppColors.textFieldDisabledFillDarker : null,
    child: Text(
      "$text",
      maxLines: 3,
      softWrap: false,
      overflow: TextOverflow.ellipsis, // FIX
      style: const TextStyle(fontSize: 12),
    ),
  );
}

/// A customizable dropdown widget with search,
/// validation, and edit-mode support.
class CustomDropdown<T> extends StatefulWidget {
  /// Creates a [CustomDropdown].
  const CustomDropdown({
    required this.items,
    super.key,
    this.filterFn,
    this.semanticLabel,
    this.height = 50,
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
    this.showEditIcon = false,
    this.onEditModeActivated,
    this.onTextChanged,
    this.onEditComplete,
    this.onClear,
    this.editController,
    this.editHintText,
    this.editInputFormatters,
    this.editKeyboardType,
    this.ignoreProvider = false,
    this.editValidator,
  });

  /// Items displayed in the dropdown.
  final List<T>? items;

  /// Filter function for search.
  final bool Function(T, String)? filterFn;

  /// Dropdown menu alignment.
  final MenuAlign? dropdownMenuAlign;

  /// Accessibility label.
  final String? semanticLabel;

  /// Comparison function for items.
  final bool Function(T, T)? compareFn;

  /// Builder for the selected item display.
  final Widget Function(BuildContext context, T? item)? dropdownBuilder;

  /// Builder for dropdown items.
  final Widget Function(
    BuildContext context,
    T item, {
    bool? isSelected,
    bool? isDisabled,
  })? itemBuilder;

  /// Selected items.
  final List<T?>? selectedItems;

  /// Selection callback.
  final Function(List<T> selectedValue)? onSelected;

  /// Enables search.
  final bool isSearchable;

  /// Placeholder text.
  final String? hintText;

  /// Input border.
  final InputBorder? border;

  /// Dropdown suffix properties.
  final DropdownSuffixProps? dropdownSuffixProps;

  /// Whether the dropdown is enabled.
  final bool isEnabled;

  /// Maximum allowed selections.
  final int? maxValueSelection;

  /// Validation message.
  final String? validationMessage;

  /// Dropdown width.
  final double? width;

  /// Dropdown height.
  final double? height;

  /// Callback before selection changes.
  final Future<bool?> Function(T? previousValue, T? currentValue)?
      onBeforeChange;

  /// Enables hover color.
  final bool showHoverColor;

  /// Hover color.
  final Color? hoverColor;

  /// Loading state.
  final bool isLoading;

  /// Shows clear icon.
  final bool showClearIcon;

  /// Maximum dropdown height.
  final double? maxDropdownHeight;

  /// When true, shows an edit icon before the expand arrow.
  final bool showEditIcon;

  /// Callback triggered when edit mode is activated.
  final VoidCallback? onEditModeActivated;

  /// Callback triggered when edit mode textbox value changes.
  final Function(String)? onTextChanged;

  /// Callback triggered when edit mode is completed.
  final Function(String)? onEditComplete;

  /// Callback triggered when the clear icon is pressed.
  final Function(List<T> selectedValue)? onClear;

  /// Controller used in edit mode.
  final TextEditingController? editController;

  /// Hint text for edit mode.
  final String? editHintText;

  /// Input formatters for edit mode.
  final List<TextInputFormatter>? editInputFormatters;

  /// When [ignoreProvider] is `true`, the dropdown remains interactive even when
  /// an ancestor [FormAccessProvider] is disabled.
  final bool ignoreProvider;

  /// Keyboard type for edit mode.
  final TextInputType? editKeyboardType;

  final String? Function(String?)? editValidator;

  @override
  CustomDropdownState createState() => CustomDropdownState<T>();
}

/// State for [CustomDropdown].
class CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  /// Multi-select controller.
  final MultiSelectController<String> multiSelectController =
      MultiSelectController();

  /// Select-all state notifier.
  final ValueNotifier<bool> selectAll = ValueNotifier(false);

  /// Background color used when disabled.
  Color disabledColor = AppColors.textFieldDisabledFill;

  // Edit mode state
  final ValueNotifier<bool> _isEditMode = ValueNotifier(false);
  TextEditingController? _internalEditController;
  final FocusNode _editFocusNode = FocusNode();

  TextEditingController get _editController =>
      widget.editController ??
      (_internalEditController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    // No focus listener needed - edit mode is permanent
  }

  void _enterEditMode() {
    _isEditMode.value = true;
    widget.onEditModeActivated?.call();
    // Pre-fill with current selection if available
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      final selectedItem = widget.selectedItems!.first;
      // Use the value property if it's a CustomDropdownItem, otherwise
      // toString()
      if (selectedItem is CustomDropdownItem) {
        _editController.text = selectedItem.value ?? "";
      } else {
        _editController.text = selectedItem.toString();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
    });
  }

  void _exitEditMode() {
    // Call onEditComplete with the current text before exiting
    widget.onEditComplete?.call(_editController.text);
    _isEditMode.value = false;
    _editController.clear();
  }

  /// Returns dropdown decoration properties.
  DropDownDecoratorProps dropDownDecoratorProps(
    InputBorder? border,
    String? errorMsg, {
    required bool isEnabled,
  }) {
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
        filled: !isEnabled,
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
      ),
    );
  }

  /// Builds the loading indicator.
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
    _editFocusNode.dispose();
    _internalEditController?.dispose();
    _isEditMode.dispose();
    super.dispose();
  }

  /// Builds the edit mode textbox widget with clear icon to return to dropdown
  Widget _buildEditModeWidget() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textFieldBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: CustomTextField(
        controller: _editController,
        focusNode: _editFocusNode,
        onChanged: widget.onTextChanged,
        onSubmitted: (value) {
          // Save the value when user presses Enter
          widget.onEditComplete?.call(value);
        },
        inputFormatters: widget.editInputFormatters,
        keyboardType: widget.editKeyboardType,
        validator: widget.editValidator,
        hintText: widget.editHintText ?? widget.hintText,
        suffixIcon: IconButton(
          tooltip: "common.clear".tr(),
          icon: const Icon(Icons.clear, size: 16),
          onPressed: _exitEditMode,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
      ),
    );
  }

  /// Builds the edit icon that appears before the expand arrow
  Widget _buildEditIcon() {
    return Semantics(
      button: true,
      label: "common.edit".tr(),
      child: InkWell(
        onTap: widget.isEnabled ? _enterEditMode : null,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.edit_outlined,
            size: 16,
            // color: widget.isEnabled
            //     ? AppColors.accordionPrimary
            //     : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine the widget's own isEnabled flag with any ancestor
    // FormAccessProvider.
    final bool providerDisabled =
        !widget.ignoreProvider && FormAccessProvider.of(context);

    final bool effectiveIsEnabled = widget.isEnabled && !providerDisabled;

    return Semantics(
      label: widget.semanticLabel,
      child: SizedBox(
        width: widget.width,
        height: 36,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isEditMode,
          builder: (context, isEditMode, _) {
            // Show edit mode textbox when in edit mode
            if (isEditMode) {
              return _buildEditModeWidget();
            }

            // Show regular dropdown when not in edit mode
            return ValueListenableBuilder<String?>(
              valueListenable: _errorMessage,
              builder: (context, errMsg, _) {
                return CustomTooltip(
                  message: effectiveIsEnabled
                      ? (errMsg != null)
                          ? errMsg
                          : ""
                      : "",
                  decoration: BoxDecoration(
                    color: AppColors.lightFailure,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  textStyle: const TextStyle(color: AppColors.failure),
                  child: DropdownSearch<T>(
                    onChanged: (value) {
                      if (value == null) {
                        widget.onClear?.call([]);
                      } else {
                        widget.onSelected?.call([value]);
                      }
                    },
                    onBeforeChange: widget.onBeforeChange,
                    dropdownBuilder: widget.dropdownBuilder ??
                        (context, T? value) {
                          return dropdownBuilderWidget(
                            text: value.toString(),
                          );
                        },
                    decoratorProps: dropDownDecoratorProps(
                      widget.border,
                      errMsg,
                      isEnabled: effectiveIsEnabled,
                    ),
                    enabled: effectiveIsEnabled,
                    suffixProps: widget.dropdownSuffixProps ??
                        DropdownSuffixProps(
                          clearButtonProps: ClearButtonProps(
                            icon: const Icon(Icons.clear, size: 16),
                            padding: EdgeInsets
                                .zero, // zero out the IconButton's padding
                            constraints: const BoxConstraints(
                              minWidth: 1,
                              minHeight: 1,
                            ),
                            isVisible: widget.validationMessage == null &&
                                widget.showClearIcon,
                          ),
                          dropdownButtonProps: DropdownButtonProps(
                            iconClosed: widget.isLoading
                                ? ExcludeSemantics(
                                    child: loadingWidget(),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.showEditIcon) _buildEditIcon(),
                                      const Icon(
                                        Icons.expand_more,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                            iconOpened: widget.isLoading
                                ? loadingWidget()
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.showEditIcon) _buildEditIcon(),
                                      const Icon(
                                        Icons.expand_less,
                                        size: 20,
                                      ),
                                    ],
                                  ),
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
                      if (!effectiveIsEnabled) {
                        return null;
                      }
                      // Check if there's a selected value OR custom text in
                      // edit controller
                      final hasValue = value != null ||
                          (widget.showEditIcon &&
                              _editController.text.isNotEmpty);

                      if (!hasValue && widget.validationMessage != null) {
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
                                onKeyEvent: (KeyEvent keyEvent) =>
                                    handleKeyEvent(
                                  keyEvent,
                                  _focusNode,
                                ),
                                child: ExcludeSemantics(
                                  child: popupWidget,
                                ),
                              );
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
                        maxHeight: widget.maxDropdownHeight ?? 250,
                      ),
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
                      // itemBuilder: widget.itemBuilder ??
                      //     (
                      //       context,
                      //       T? value,
                      //       bool isDisabled,
                      //       bool isSelected,
                      //     ) {
                      //       return SizedBox(
                      //         width: double.infinity, //forces truncation
                      //         child: dropdownItemBuildWidget(
                      //           value.toString(),
                      //           isSelected: isSelected,
                      //         ),
                      //       );
                      //     },
                      itemBuilder: (context, item, isDisabled, isSelected) {
                        final builder = widget.itemBuilder;

                        if (builder != null) {
                          return builder(
                            context,
                            item,
                            isDisabled: false,
                            isSelected: isSelected,
                          );
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: dropdownItemBuildWidget(
                            item.toString(),
                            isSelected: isSelected,
                          ),
                        );
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
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
