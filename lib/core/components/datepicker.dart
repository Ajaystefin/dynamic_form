import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vph_web_date_picker/vph_web_date_picker.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";

typedef PickerMode = PickerViewMode;

class NonEditableFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return oldValue; // Always return old value, ignoring new input
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp("[^0-9]"), "");
    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      buffer.write(digitsOnly[i]);
      if (i == 1 || i == 3) buffer.write("/");
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CustomDatePicker extends StatefulWidget {
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
  });
  final double? width;
  final String? dateFormat;
  final Function(DateTime? selectedDate)? onSubmit2;
  final DateTime? initialDateTime;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final ValueChanged<String?>? onSubmit;
  final String? labelText;
  final List<DateTime>? blockedDates;
  final FormFieldSetter<DateTime?>? onSaved;
  final bool isEnabled;
  final PickerMode? pickerViewMode;
  final String? semanticLabel;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool? isMaualEdit;

  @override
  CustomDatePickerState createState() => CustomDatePickerState();
}

class CustomDatePickerState extends State<CustomDatePicker> {
  TextEditingController ctrl = TextEditingController();
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
      (widget.isMaualEdit == true)
          ? setController()
          : setState(() {}); // keep text in sync
    }
  }

  void setController() {
    ctrl.text = (selectedDateText == null
            ? null
            : DateTimeUtils.formatDateTime(
                selectedDateText!,
                format: widget.dateFormat ?? "dd/MM/yyy",
              ).toString()) ??
        "";
    setState(() {});
  }

  // Helper that encapsulates the save behavior
  void _handleOnSaved(String? value) {
    if (widget.onSaved == null) return;

    DateTime? toSave;

    if (widget.isMaualEdit == true) {
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
    final bool effectiveIsEnabled =
        widget.isEnabled && !FormAccessProvider.of(context);

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
          initialValue: (widget.isMaualEdit == true) ? null : ctrl.text,
          filled: !effectiveIsEnabled,
          hintText: ctrl.text,
          controller: widget.controller ?? ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: (widget.isMaualEdit == true)
              ? [
                  FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                  LengthLimitingTextInputFormatter(10),
                  DateInputFormatter(), // Custom formatter for dd/MM/yyyy
                ]
              : [NonEditableFormatter()],
          width: widget.width,
          validator: !effectiveIsEnabled ? null : widget.validator,
          onChanged: (text) {
            if (widget.isMaualEdit == true) {
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
                            enableRangeSelection: false,
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
                            widget.controller?.text = formatted.toString();
                            widget.onSubmit?.call(formatted);
                            widget.onSubmit2?.call(picked.start);

                            selectedDateText = (widget.isMaualEdit == true)
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
