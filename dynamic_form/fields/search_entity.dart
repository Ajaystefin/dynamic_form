import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/models/request/risk_rating/updated_rating.dart';
import 'package:wcas_frontend/repositories/risk_rating_repository.dart';

class DynamicFormSearchEntity extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final Function(String?) onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final bool showLabel;
  final TextEditingController? controller;
  const DynamicFormSearchEntity({
    super.key,
    required this.fieldData,
    this.document,
    required this.onSubmit,
    this.inputFormatters,
    this.showLabel = true,
    this.controller,
  });

  @override
  State<DynamicFormSearchEntity> createState() =>
      _DynamicFormSearchEntityState();
}

class _DynamicFormSearchEntityState extends State<DynamicFormSearchEntity> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // Initialize from document if available
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final initialValue = widget.document![widget.fieldData.key];
    if (initialValue != null && _controller.text.isEmpty) {
      _controller.text = initialValue.toString();
    }
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? enteredValue;
    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.required,
      child: CustomTextField(
        controller: _controller,
        readOnly: widget.fieldData.isDisable,
        inputFormatters: widget.inputFormatters,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () async {
                final int? entityId = int.tryParse(enteredValue ?? '');
                final List<UpdatedRating?> updatedRatings =
                    await RiskRatingRepository.instance
                        .getUpdatedRatingDetails(entityId: entityId);
                String? result;
                for (UpdatedRating? updatedRating in updatedRatings) {
                  if (updatedRating?.entityId == entityId) {
                    result =
                        '${updatedRating?.existingFinalGrade ?? ""}@${updatedRating?.proposedFinalGrade ?? ""}';
                  }
                }
                widget.onSubmit(result);
              },
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        filled: widget.fieldData.isDisable,
        maxLength: widget.fieldData.maxLength,
        hintText: widget.fieldData.defaultValue,
        onChanged: (String? value) {
          enteredValue = value ?? "";
        },
        onSubmitted: (String? value) {
          _controller.text = value ?? "";
        },
        validator: widget.fieldData.required
            ? (value) {
                // Use controller's text as the source of truth
                final actualValue = _controller.text;

                // ignore: avoid_print
                print('=== Validation Debug for ${widget.fieldData.key} ===');
                logger.f('Controller text: "$actualValue"');
                logger.f('FormField value: "$value"');
                logger.f('Required: ${widget.fieldData.required}');

                // First check if field is required and empty
                if (actualValue.isEmpty) {
                  logger.f('Validation FAILED: Field is empty');
                  return widget.fieldData.message;
                }

                // Then check validation pattern if provided
                if (widget.fieldData.validationPattern != null) {
                  logger.f(
                      'Validation pattern: ${widget.fieldData.validationPattern}');
                  final pattern = RegExp(widget.fieldData.validationPattern!);
                  final matches = pattern.hasMatch(actualValue);
                  logger.f('Pattern matches: $matches');

                  if (!matches) {
                    logger.f('Validation FAILED: Pattern mismatch');
                    return widget.fieldData.message;
                  }
                }

                logger.f('Validation PASSED');
                return null;
              }
            : null,
      ),
    );
  }
}
