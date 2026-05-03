import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:multi_dropdown/multi_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

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
    constraints: const BoxConstraints(maxWidth: double.infinity),
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

class CustomDropdown<T> extends StatefulWidget {
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
  });

  ///List of items to be displayed in the dropdown
  final List<T>? items;
  final bool Function(T, String)? filterFn;
  final MenuAlign? dropdownMenuAlign;
  final String? semanticLabel;

  ///Compare Function
  final bool Function(T, T)? compareFn;

  final Widget Function(BuildContext context, T? item)? dropdownBuilder;

  final Widget Function(
    BuildContext context,
    T item,
    bool isDisabled,
    bool isSelected,
  )? itemBuilder;

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

  /// When true, shows an edit icon before the expand arrow
  final bool showEditIcon;

  /// Callback triggered when edit mode is activated
  final VoidCallback? onEditModeActivated;

  /// Callback triggered when edit mode textbox value changes
  final Function(String)? onTextChanged;

  /// Callback triggered when edit mode is deactivated (e.g., on focus loss or
  /// submit)
  final Function(String)? onEditComplete;

  /// Callback triggered when the clear icon is pressed
  final Function(List<T> selectedValue)? onClear;

  /// Controller for the textbox in edit mode (optional, internal one created if
  /// not provided)
  final TextEditingController? editController;

  /// Hint text for the edit mode textbox
  final String? editHintText;

  /// Input formatters for the edit mode textbox (e.g., for numeric input, max
  /// length)
  final List<TextInputFormatter>? editInputFormatters;

  /// When [ignoreProvider] is `true`, the button remains clickable even when
  /// an ancestor [FormAccessProvider] has [disabled] set to `true`.
  /// Use this for navigation / cancel buttons that should stay active on
  /// read-only screens.
  final bool ignoreProvider;

  /// Keyboard type for the edit mode textbox
  final TextInputType? editKeyboardType;

  @override
  CustomDropdownState createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  final MultiSelectController<String> multiSelectController =
      MultiSelectController();

  final ValueNotifier<bool> selectAll = ValueNotifier(false);

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
      child: TextField(
        controller: _editController,
        focusNode: _editFocusNode,
        onChanged: widget.onTextChanged,
        onSubmitted: (value) {
          // Save the value when user presses Enter
          widget.onEditComplete?.call(value);
        },
        inputFormatters: widget.editInputFormatters,
        keyboardType: widget.editKeyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: widget.editHintText ?? widget.hintText,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: _exitEditMode,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the edit icon that appears before the expand arrow
  Widget _buildEditIcon() {
    return InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
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
                                        if (widget.showEditIcon)
                                          _buildEditIcon(),
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
                                        if (widget.showEditIcon)
                                          _buildEditIcon(),
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
                                  includeSemantics: true,
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
                        itemBuilder: widget.itemBuilder ??
                            (
                              context,
                              T? value,
                              bool isDisabled,
                              bool isSelected,
                            ) {
                              return SizedBox(
                                width: double.infinity, //forces truncation
                                child: dropdownItemBuildWidget(
                                  value.toString(),
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
