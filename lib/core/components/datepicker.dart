import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';

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

class CustomDatePicker extends StatefulWidget {
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
  });

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
      setState(() {});
    }
  }

  void setController() {
    ctrl.text = (selectedDateText == null
            ? null
            : DateTimeUtils.formatDateTime(selectedDateText!,
                    format: widget.dateFormat ?? "dd/MM/yyy")
                .toString()) ??
        "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return
        // Semantics( if Enable this check this Request Information issue
        //   label: widget.semanticLabel ?? widget.labelText ?? "date",
        //   enabled: widget.isEnabled,
        //   child:
        IgnorePointer(
      ignoring: !widget.isEnabled,
      child: SizedBox(
        height: 36,
        child: CustomTextField(
          initialValue: ctrl.text,
          filled: !widget.isEnabled,
          hintText: ctrl.text,
          controller: widget.controller ?? ctrl,
          inputFormatters: [NonEditableFormatter()],
          width: widget.width,
          validator: !widget.isEnabled ? null : widget.validator,
          onSaved: widget.onSaved != null
              ? (String? value) {
                  widget.onSaved!(
                      DateTime.tryParse(value ?? "") ?? widget.initialDateTime);
                }
              : null,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedDateText != null && widget.isEnabled)
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.darkGrey)),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.controller?.clear();
                      if (widget.onSubmit != null) {
                        widget.onSubmit!(null);
                      }
                      if (widget.onSubmit2 != null) {
                        widget.onSubmit2!(null);
                      }
                      selectedDateText = null;
                      setController();
                    },
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                    color: widget.isEnabled ? AppColors.white : null,
                    border: Border.all(color: AppColors.darkGrey)),
                child: IconButton(
                  icon: const Icon(Icons.date_range_sharp),
                  onPressed: !widget.isEnabled
                      ? null
                      : () async {
                          final picked = await showWebDatePicker(
                            context: context,
                            blockedDates: widget.blockedDates,
                            initialDate: selectedDateText ??
                                widget.initialDateTime ??
                                DateTime.now(),
                            withoutActionButtons: true,
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
                              !(widget.blockedDates ?? []).any((d) =>
                                  d.year == picked.start.year &&
                                  d.month == picked.start.month &&
                                  d.day == picked.start.day)) {
                            final formatted =
                                DateFormat(widget.dateFormat ?? 'dd/MM/yyyy')
                                    .format(picked.start);
                            widget.controller?.text = formatted.toString();
                            if (widget.onSubmit != null) {
                              widget.onSubmit!(formatted);
                            }
                            if (widget.onSubmit2 != null) {
                              widget.onSubmit2!(picked.start);
                            }
                            selectedDateText = picked.start;
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
