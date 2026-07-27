import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";
import "package:wcas_frontend/repositories/risk_rating_repository.dart";

/// A dynamic entity search field for dynamic forms.
///
/// Allows users to search and select entity-related data.
class DynamicFormSearchEntity extends StatefulWidget {
  /// Creates a [DynamicFormSearchEntity].
  const DynamicFormSearchEntity({
    required this.fieldData,
    required this.onSubmit,
    super.key,
    this.document,
    this.inputFormatters,
    this.showLabel = true,
    this.controller,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Callback invoked when the value changes.
  final Function(String?) onSubmit;

  /// Input formatters applied to the field.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to display the field label.
  final bool showLabel;

  /// Controller for the text field.
  final TextEditingController? controller;

  @override
  State<DynamicFormSearchEntity> createState() =>
      _DynamicFormSearchEntityState();
}

class _DynamicFormSearchEntityState extends State<DynamicFormSearchEntity> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // Initialize from document if available
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) {
      return;
    }

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
    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.isRequired,
      child: CustomTextField(
        controller: _controller,
        readOnly: widget.fieldData.isDisable,
        inputFormatters: widget.inputFormatters,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Semantics(
              button: true,
              label: "common.searchEntity".tr(),
              child: InkWell(
                onTap: _isLoading
                    ? null
                    : () async {
                        final int? entityId = int.tryParse(_controller.text);
                        if (entityId == null) {
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final List<UpdatedRating?> updatedRatings =
                              await RiskRatingRepository.instance
                                  .getUpdatedRatingDetails(entityId: entityId);
                          String? result;
                          for (final UpdatedRating? updatedRating
                              in updatedRatings) {
                            if (updatedRating?.entityId == entityId) {
                              final String existingGrade =
                                  getCrr(updatedRating?.existingFinalGrade) ??
                                      "";
                              final String proposedGrade =
                                  getCrr(updatedRating?.proposedFinalGrade) ??
                                      "";
                              result =
                                  "$entityId@$existingGrade@$proposedGrade";
                            }
                          }
                          widget.onSubmit(result);
                        } on Object catch (e) {
                          AlertManager().showFailureToast(e.toString());
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(4),
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.search_rounded,
                        color: AppColors.white,
                      ),
              ),
            ),
          ),
        ),
        filled: widget.fieldData.isDisable,
        maxLength: widget.fieldData.maxLength,
        hintText: widget.fieldData.defaultValue,
        onChanged: (String? value) {
          // enteredValue = value ?? "";
        },
        onSubmitted: (String? value) {
          _controller.text = value ?? "";
        },
        validator: widget.fieldData.isRequired
            ? (value) {
                // Use controller's text as the source of truth
                final actualValue = _controller.text;

                // First check if field is required and empty
                if (actualValue.isEmpty) {
                  logger.f("Validation FAILED: Field is empty");
                  return widget.fieldData.message;
                }

                // Then check validation pattern if provided
                if (widget.fieldData.validationPattern != null) {
                  final pattern = RegExp(widget.fieldData.validationPattern!);
                  final matches = pattern.hasMatch(actualValue);
                  logger.f("Pattern matches: $matches");

                  if (!matches) {
                    logger.f("Validation FAILED: Pattern mismatch");
                    return widget.fieldData.message;
                  }
                }

                logger.f("Validation PASSED");
                return null;
              }
            : null,
      ),
    );
  }
}
