import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

const double kDefaultPadding = 14.0;

class DynamicFormInline extends StatefulWidget {
  final String inputString;
  final String splitSymbol;
  final bool isRequired;
  final Function(String)? callBackString;
  final bool showError;
  final String? editedPreview;

  const DynamicFormInline({
    super.key,
    required this.inputString,
    this.splitSymbol = "()",
    this.isRequired = true,
    this.callBackString,
    this.showError = false,
    this.editedPreview,
  });

  @override
  DynamicFormInlineState createState() => DynamicFormInlineState();
}

class DynamicFormInlineState extends State<DynamicFormInline> {
  late String originalInputString;
  late List<TextEditingController> dynamicControllers;
  late List<TextEditingController> bracketControllers;

  final ValueNotifier<String> filltextVN = ValueNotifier("");
  final List<InlineSpan> inlineSpans = [];

  @override
  void initState() {
    super.initState();
    originalInputString = widget.inputString;
    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in dynamicControllers) {
      controller.dispose();
    }
    for (var controller in bracketControllers) {
      controller.dispose();
    }
    filltextVN.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    dynamicControllers = [];
    bracketControllers = [];

    RegExp separatorExp = RegExp(r'(\(\))|(\[.*?\])');
    Iterable<RegExpMatch> separators =
        separatorExp.allMatches(originalInputString);

    for (var separator in separators) {
      String separatorText = separator.group(0)!;

      if (separatorText == widget.splitSymbol) {
        dynamicControllers.add(TextEditingController());
      } else if (separatorText.startsWith('[') && separatorText.endsWith(']')) {
        bracketControllers.add(TextEditingController());
      }
    }

    filltextVN.value = widget.editedPreview ?? originalInputString;
    buildInlineSpans();
  }

  /// ✅ Validation function for mandatory fields
  bool isValid(String value) {
    return !widget.isRequired || value.trim().isNotEmpty;
  }

  void getFormattedString() {
    try {
      String result = '';
      int dynamicIndex = 0;
      int bracketIndex = 0;

      RegExp separatorExp = RegExp(r'(\(\))|(\[.*?\])');
      List<String> parts = originalInputString.split(separatorExp);
      Iterable<RegExpMatch> separators =
          separatorExp.allMatches(originalInputString);

      for (int i = 0; i < parts.length; i++) {
        result += parts[i];

        if (i < separators.length) {
          RegExpMatch separator = separators.elementAt(i);
          String separatorText = separator.group(0)!;

          if (separatorText == widget.splitSymbol) {
            if (dynamicIndex < dynamicControllers.length) {
              String text = dynamicControllers[dynamicIndex].text;
              result += isValid(text) ? text : widget.splitSymbol;
              dynamicIndex++;
            }
          } else if (separatorText.startsWith('[') &&
              separatorText.endsWith(']')) {
            if (bracketIndex < bracketControllers.length) {
              String text = bracketControllers[bracketIndex].text;
              result += '[$text]';
              bracketIndex++;
            }
          }
        }
      }

      bool isDynamicFormFilled =
          dynamicControllers.every((c) => isValid(c.text));
      bool isBracketFormFilled =
          bracketControllers.every((c) => isValid(c.text));

      if (isDynamicFormFilled &&
          isBracketFormFilled &&
          widget.callBackString != null) {
        widget.callBackString!(result);
      }

      filltextVN.value = result;
      setState(() {}); // Refresh UI
    } catch (e) {
      debugPrint("Error in string formatting: $e");
    }
  }

  void buildInlineSpans() {
    inlineSpans.clear();

    int dynamicIndex = 0;
    int bracketIndex = 0;
    inlineSpans.add(const TextSpan(
      text: "*",
      style: TextStyle(color: AppColors.failure),
    ));

    RegExp separatorExp = RegExp(r'(\(\))|(\[.*?\])');
    List<String> parts = originalInputString.split(separatorExp);
    Iterable<RegExpMatch> separators =
        separatorExp.allMatches(originalInputString);

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        inlineSpans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(color: AppColors.black),
        ));
      }

      if (i < separators.length) {
        RegExpMatch separator = separators.elementAt(i);
        String separatorText = separator.group(0)!;

        if (separatorText == widget.splitSymbol) {
          if (dynamicIndex < dynamicControllers.length) {
            final controller = dynamicControllers[dynamicIndex];
            final isFieldValid = isValid(controller.text);
            inlineSpans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(
                width: 100,
                child: CustomTextField(
                  maxLines: 1,
                  maxLength: 100,
                  counterText: '',
                  controller: controller,
                  onChanged: (val) => getFormattedString(),
                  validator: (value) => CustomValidator.requiredField(value),
                  border: widget.showError && !isFieldValid
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: const BorderSide(
                            color: AppColors.failure,
                          ),
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldBorder,
                          ),
                        ),
                ),
              ),
            ));
            dynamicIndex++;
          }
        } else if (separatorText.startsWith('[') &&
            separatorText.endsWith(']')) {
          if (bracketIndex < bracketControllers.length) {
            final controller = bracketControllers[bracketIndex];
            final isFieldValid = isValid(controller.text);
            inlineSpans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(
                width: 140,
                child: CustomTextField(
                  maxLines: 1,
                  maxLength: 100,
                  counterText: '',
                  validator: (value) => CustomValidator.requiredField(value),
                  controller: controller,
                  onChanged: (val) => getFormattedString(),
                  border: widget.showError && !isFieldValid
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: const BorderSide(
                            color: AppColors.failure,
                          ),
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldBorder,
                          ),
                        ),
                ),
              ),
            ));
            bracketIndex++;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inputString.isEmpty || widget.inputString == " ") {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(),
          Text("", style: TextStyle(fontSize: 12)),
        ],
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: filltextVN,
      builder: (context, fillText, _) {
        final hasValidationError = widget.showError &&
            (dynamicControllers.any((c) => !isValid(c.text)) ||
                bracketControllers.any((c) => !isValid(c.text)));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kDefaultPadding / 2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasValidationError
                      ? AppColors.failure
                      : AppColors.textFieldBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                fillText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: inlineSpans.length == 1 ? 5 : kDefaultPadding),
            RichText(
              text: TextSpan(
                children: inlineSpans,
                style: inlineSpans.length == 1
                    ? const TextStyle(fontSize: 12)
                    : const TextStyle(height: 3, fontSize: 12),
              ),
            ),
            if (hasValidationError)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Please fill all required fields.",
                  style: TextStyle(color: AppColors.failure, fontSize: 12),
                ),
              ),
            SizedBox(height: inlineSpans.length == 1 ? 5 : kDefaultPadding),
          ],
        );
      },
    );
  }
}
