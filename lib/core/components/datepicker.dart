import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vph_web_date_picker/vph_web_date_picker.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

/// Alias for [PickerViewMode].
typedef PickerMode = PickerViewMode;

/// Prevents manual text editing.
class NonEditableFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return oldValue; // Always return old value, ignoring new input
  }
}

/// Formats date input as dd/MM/yyyy.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r"\D"), "");

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);

      if ((i == 1 || i == 3) && i != digits.length - 1) {
        buffer.write("/");
      }
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Date picker widget with optional manual date entry.
class CustomDatePicker extends StatefulWidget {
  /// Creates a [CustomDatePicker].
  const CustomDatePicker({
    super.key,
    this.width,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.dateFormat,
    this.blockedDates,
    this.initialDateTime,
    this.onSubmit2,
    this.controller,
    this.onSubmit,
    this.semanticLabel,
    this.isEnabled = true,
    this.labelText = "Select Date",
    this.onSaved,
    this.pickerViewMode,
    this.isMaualEdit = false,
    this.ignoreProvider = false,
  });

  /// Width of the date picker.
  final double? width;

  /// Date display format.
  final String? dateFormat;

  /// Date selection callback.
  final Function(DateTime? selectedDate)? onSubmit2;

  /// Initially selected date.
  final DateTime? initialDateTime;

  /// Validation callback.
  final String? Function(String?)? validator;

  /// Text controller.
  final TextEditingController? controller;

  /// Text submission callback.
  final ValueChanged<String?>? onSubmit;

  /// Field label.
  final String? labelText;

  /// Disabled dates.
  final List<DateTime>? blockedDates;

  /// Save callback.
  final FormFieldSetter<DateTime?>? onSaved;

  /// Whether the field is enabled.
  final bool isEnabled;

  /// Date picker view mode.
  final PickerMode? pickerViewMode;

  /// Accessibility label.
  final String? semanticLabel;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Enables manual date editing.
  final bool isMaualEdit;

  /// Ignores form access restrictions.
  final bool ignoreProvider;

  @override
  CustomDatePickerState createState() => CustomDatePickerState();
}

/// State for [CustomDatePicker].
class CustomDatePickerState extends State<CustomDatePicker> {
  /// Controller used to manage the date input field.
  TextEditingController ctrl = TextEditingController();

  /// Currently selected date.
  DateTime? selectedDateText;
  @override
  void initState() {
    super.initState();
    selectedDateText = widget.initialDateTime;
    setController();
  }

  @override
  void didUpdateWidget(covariant CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateTime != oldWidget.initialDateTime) {
      selectedDateText = widget.initialDateTime;
      widget.isMaualEdit
          ? setController()
          : setState(() {}); // keep text in sync
    }
  }

  /// Updates the text controller with the formatted selected date.
  void setController() {
    ctrl.text = (selectedDateText == null
            ? null
            : DateTimeUtils.formatDateTime(
                selectedDateText!,
                format: widget.dateFormat ?? "dd/MM/yyy",
              )) ??
        "";
    setState(() {});
  }

  // Helper that encapsulates the save behavior
  void _handleOnSaved(String? value) {
    if (widget.onSaved == null) {
      return;
    }

    DateTime? toSave;

    if (widget.isMaualEdit) {
      // 1) Prefer the selected date if already chosen/parsed elsewhere
      toSave = selectedDateText;

      // 2) Fallback: strict parse from the latest text value
      toSave ??=
          DateTimeUtils.parseToDateOnly((widget.controller ?? ctrl).text);

      // 3) Last fallback: keep prior initial date if provided
      toSave ??= widget.initialDateTime;
    } else {
      // Non-manual: use ISO-8601 parsing as before with a fallback
      toSave = DateTime.tryParse(value ?? "") ?? widget.initialDateTime;
    }
    widget.onSaved!(toSave);
  }

  @override
  Widget build(BuildContext context) {
    // Combine the widget's own isEnabled with any ancestor FormAccessProvider.
    final bool effectiveIsEnabled = widget.isEnabled &&
        (widget.ignoreProvider || !FormAccessProvider.of(context));
    return
        // Semantics( if Enable this check this Request Information issue
        //   label: widget.semanticLabel ?? widget.labelText ?? "date",
        //   enabled: widget.isEnabled,
        //   child:
        IgnorePointer(
      ignoring: !effectiveIsEnabled,
      child: SizedBox(
        height: 36,
        child: CustomTextField(
          initialValue: widget.isMaualEdit ? null : ctrl.text,
          readOnly: !widget.isEnabled,
          filled: !widget.isEnabled,
          hintText: ctrl.text,
          controller: widget.controller ?? ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: widget.isMaualEdit
              ? [
                  FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                  LengthLimitingTextInputFormatter(10),
                  DateInputFormatter(), // Custom formatter for dd/MM/yyyy
                ]
              : [NonEditableFormatter()],
          width: widget.width,
          validator: !effectiveIsEnabled ? null : widget.validator,
          onChanged: (text) {
            if (widget.isMaualEdit) {
              selectedDateText = DateTimeUtils.parseToDateOnly(text);
            }
          },
          onSaved: widget.onSaved != null ? _handleOnSaved : null,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedDateText != null && effectiveIsEnabled)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.darkGrey),
                  ),
                  child: IconButton(
                    tooltip: "common.clear".tr(),
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.controller?.clear();
                      widget.onSubmit?.call(null);
                      widget.onSubmit2?.call(null);
                      selectedDateText = null;
                      setController();
                    },
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: effectiveIsEnabled ? AppColors.white : null,
                  border: Border.all(color: AppColors.darkGrey),
                ),
                child: IconButton(
                  tooltip: widget.labelText ?? "common.searchEntity".tr(),
                  icon: const Icon(Icons.date_range_sharp),
                  onPressed: !effectiveIsEnabled
                      ? null
                      : () async {
                          final picked = await showWebDatePicker(
                            context: context,
                            blockedDates: widget.blockedDates,
                            initialDate: selectedDateText ??
                                widget.initialDateTime ??
                                DateTime.now(),
                            // withoutActionButtons: true,
                            showOkButton:
                                widget.pickerViewMode == PickerMode.month,
                            autoCloseOnDateSelect: true,
                            showResetButton: false,
                            width: widget.pickerViewMode != null ? 400 : 300,
                            initViewMode:
                                widget.pickerViewMode ?? PickerMode.day,
                            firstDate: widget.firstDate,
                            lastDate: widget.lastDate,
                            selectedDayColor: AppColors.primary,
                            weekendDaysColor: AppColors.failure,
                            confirmButtonColor: AppColors.primary,
                            cancelButtonColor: AppColors.failure,
                          );
                          if (picked != null &&
                              !(widget.blockedDates ?? []).any(
                                (d) =>
                                    d.year == picked.start.year &&
                                    d.month == picked.start.month &&
                                    d.day == picked.start.day,
                              )) {
                            final formatted =
                                DateFormat(widget.dateFormat ?? "dd/MM/yyyy")
                                    .format(picked.start);
                            widget.controller?.text = formatted;
                            widget.onSubmit?.call(formatted);
                            widget.onSubmit2?.call(picked.start);

                            selectedDateText = widget.isMaualEdit
                                ? DateTimeUtils.toDateOnly(
                                    picked.start,
                                  ) // ensure date-only
                                : picked.start;
                            setController();
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // );
  }
}
