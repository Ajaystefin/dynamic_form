import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class CustomDropdownMenuButton extends StatefulWidget {
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
  final List<CustomDropdownMenuItem>? options;
  final bool isSearchable;
  final Function(String)? callBack;
  final Function((String, void Function()?)?)? validation;
  final bool showValueWithLabel;

  const CustomDropdownMenuButton(
      {super.key,
      required this.label,
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
      this.validation});

  @override
  State<CustomDropdownMenuButton> createState() =>
      _CustomDropdownMenuButtonState();
}

class _CustomDropdownMenuButtonState extends State<CustomDropdownMenuButton> {
  ValueNotifier<CustomDropdownItem?>? selectedButtonModelVN =
      ValueNotifier(null);

  @override
  void initState() {
    if (widget.initialOption != null && (widget.options?.isNotEmpty ?? false)) {
      selectedButtonModelVN?.value = widget.initialOption;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CustomDropdownItem?>(
        valueListenable: selectedButtonModelVN ?? ValueNotifier(null),
        builder: (context, selectedButtonModel, _) {
          String label = widget.showValueWithLabel
              ? "${widget.label} ${selectedButtonModel?.label ?? ""}"
              : selectedButtonModel?.label ?? widget.label;
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
              onPressed: selectedButtonModel?.onPressed,
              trailingIcon: DropdownSearch<(String?, dynamic, Function()?)>(
                mode: Mode.custom,
                popupProps: PopupProps.menu(
                  showSearchBox: widget.isSearchable,
                  fit: FlexFit.loose,
                  searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                          color: AppColors.textFieldBorder, width: 1.5),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  )),
                  itemBuilder: (context, item, isDisabled, isSelected) =>
                      Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.$1 ?? item.$2),
                  ),
                ),
                onChanged: (selectedOption) {
                  if (widget.callBack != null) {
                    widget.callBack!(selectedOption?.$2);
                  }
                  selectedButtonModelVN?.value = CustomDropdownItem(
                      label: selectedOption?.$1,
                      value: selectedOption?.$2,
                      onPressed: selectedOption?.$3);
                },
                enabled: widget.options != null && widget.callBack != null,
                // items: (f, cs) => (widget.options ?? [])
                //     .map((option) =>
                //         (option.label, option.value, option.onPressed))
                //     .toList(),
                compareFn: (item1, item2) => item1.$1 == item2.$1,
                dropdownBuilder: (ctx, selectedItem) => Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: widget.textColor ?? AppColors.white,
                ),
              ),
            ),
          );
        });
  }
}
