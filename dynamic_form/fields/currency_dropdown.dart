// ignore_for_file: avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/button_dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/exchange_rate.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';

class DynamicFormCurrencyDropdownTextfield extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  const DynamicFormCurrencyDropdownTextfield({
    super.key,
    required this.fieldData,
    this.document,
    required this.onSubmit,
    this.showLabel = false,
    this.inputFormatters,
    this.controller,
  });

  @override
  State<DynamicFormCurrencyDropdownTextfield> createState() =>
      _DynamicFormCurrencyDropdownTextfieldState();
}

class _DynamicFormCurrencyDropdownTextfieldState
    extends State<DynamicFormCurrencyDropdownTextfield> {
  late TextEditingController _controller;
  String? _initialCurrency;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _initializeFromDocument();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue is Map<String, dynamic> && storedValue.isNotEmpty) {
      // Support new API format: {fromCurrency, fromVal, aedEquivalent}
      if (storedValue.containsKey('fromCurrency')) {
        _initialCurrency = storedValue['fromCurrency']?.toString();
        if (_controller.text.isEmpty) {
          _controller.text = storedValue['fromVal']?.toString() ?? '';
        }
      } else {
        // Fallback for old format: {currency: amount}
        final entry = storedValue.entries.first;
        _initialCurrency = entry.key;
        if (_controller.text.isEmpty) {
          _controller.text = entry.value?.toString() ?? '';
        }
      }
    }
  }

  @override
  void didUpdateWidget(DynamicFormCurrencyDropdownTextfield oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if document value changed externally (e.g., via updateFieldValue)
    if (widget.document != null) {
      final storedValue = widget.document![widget.fieldData.key];
      if (storedValue is Map<String, dynamic> && storedValue.isNotEmpty) {
        final newValue = storedValue['fromVal']?.toString() ?? '';

        // Only update if the value actually changed to avoid cursor jumping
        if (_controller.text != newValue) {
          _controller.text = newValue;
        }

        // Update currency if changed
        final newCurrency = storedValue['fromCurrency']?.toString();
        if (newCurrency != null && newCurrency != _initialCurrency) {
          setState(() {
            _initialCurrency = newCurrency;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CurrencyDropdown(
      options: widget.fieldData.optionList ?? [],
      initialOption: (_initialCurrency ?? "").isEmpty
          ? widget.fieldData.optionList?.first
          : Option(key: _initialCurrency, pairValue: _initialCurrency),
      controller: _controller,
      onChanged: (value) {
        widget.onSubmit(value);
      },
    );
    return widget.showLabel
        ? LabelWidget(
            showLabel: widget.showLabel,
            label: widget.fieldData.label,
            isRequired: widget.fieldData.required,
            exponent: widget.fieldData.isCMOUpdate ? "#" : null,
            child: child)
        : child;
  }
}

class CurrencyDropdown extends StatefulWidget {
  final TextEditingController? controller;
  final String? textFieldLabel;
  final String? dropdownLabel;
  final double? textFieldWidth;
  final List<Option> options;
  final Option? initialOption;
  final String? Function(String?)? validator;
  final Function(Map<String, dynamic>)? onChanged;

  const CurrencyDropdown({
    super.key,
    this.controller,
    required this.options,
    this.textFieldLabel,
    this.dropdownLabel,
    this.textFieldWidth,
    this.initialOption,
    this.validator,
    this.onChanged,
  });

  @override
  State<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  Option? selectedOption;
  final TextEditingController aedController =
      TextEditingController(); //   AED controller
  num exchangeRate = 0;
  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textFieldBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            prefixIcon: CustomDropdownButton(
              borderRadius: 4.0,
              label: widget.dropdownLabel ?? "",
              disabledColor: AppColors.scaffoldBackground,
              textColor: AppColors.defaultTextColor,
              options: widget.options
                  .map((option) => CustomDropdownItem(
                        value: option.pairValue ?? "",
                        label: option.pairValue ?? "",
                      ))
                  .toList(),
              height: 34.0,
              isSearchable: false,
              initialOption: CustomDropdownItem(
                value: widget.initialOption?.pairValue ?? "",
                label: widget.initialOption?.pairValue ?? "",
              ),
              callBack: (selectedValue) async {
                print('Dropdown callBack selectedValue: "$selectedValue"');

                // If overlay errors occur, wrap in addPostFrameCallback; otherwise setState is fine.
                setState(() {
                  selectedOption = widget.options.firstWhere(
                    (opt) => (opt.pairValue ?? '') == (selectedValue),
                    orElse: () =>
                        Option(key: "AED", pairValue: "AED"), // your fallback
                  );
                });

                // Fetch exchange rate if not AED
                if (selectedOption?.pairValue != ServerConstants.aedCurrency) {
                  await getCurrencyRates(
                      Reference(name: selectedOption?.pairValue));
                }

                // Emit updated value with new currency
                if (widget.onChanged != null && widget.controller != null) {
                  final numValue =
                      double.tryParse(widget.controller!.text) ?? 0;
                  final aedValue =
                      selectedOption?.pairValue == ServerConstants.aedCurrency
                          ? numValue
                          : numValue * exchangeRate;

                  widget.onChanged!({
                    'fromCurrency': selectedOption?.pairValue,
                    'fromVal': numValue,
                    'aedEquivalent': aedValue,
                  });
                }
              },
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              FilteringTextInputFormatter.digitsOnly,
            ],
            semanticLabel: widget.textFieldLabel,
            validator: widget.validator,
            controller: widget.controller,
            hintText: widget.textFieldLabel,
            width: widget.textFieldWidth,
            onChanged: (value) async {
              if (widget.onChanged != null && selectedOption != null) {
                final numValue = double.tryParse(value) ?? 0;

                // Calculate AED equivalent
                // If currency is AED, aedEquivalent = fromVal
                // Otherwise, use current exchange rate
                final aedValue =
                    selectedOption!.pairValue == ServerConstants.aedCurrency
                        ? numValue
                        : numValue * exchangeRate;

                // Always emit all three fields for field dependencies
                widget.onChanged!({
                  'fromCurrency': selectedOption!.pairValue,
                  'fromVal': numValue,
                  'aedEquivalent': aedValue,
                });

                // Fetch exchange rate if not AED
                if (selectedOption!.pairValue != ServerConstants.aedCurrency) {
                  await getCurrencyRates(
                      Reference(name: selectedOption?.pairValue));
                }
              }
            },
          ),
          if (selectedOption != null &&
              selectedOption?.pairValue != ServerConstants.aedCurrency)
            CustomTextField(
              readOnly: true,
              filled: true,
              prefixIcon: CustomDropdownButton(
                borderRadius: 4.0,
                label: ServerConstants.aedCurrency,
                disabledColor: AppColors.scaffoldBackground,
                textColor: AppColors.defaultTextColor,
                height: 34.0,
                isSearchable: false,
                initialOption: CustomDropdownItem(
                  value: ServerConstants.aedCurrency,
                  label: ServerConstants.aedCurrency,
                ),
              ),
              semanticLabel: widget.textFieldLabel,
              validator: widget.validator,
              controller: aedController, //   AED equivalent field
              width: widget.textFieldWidth,
            ),
        ],
      ),
    );
  }

  ///   Fetch currency rates and update AED equivalent
  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
    try {
      CurrencyRates currencyRates = await FacilitySecurityRepository.instance
          .getCurrencyRates(selectedCurrency);

      exchangeRate = currencyRates.rates[selectedCurrency?.name] ?? 0;

      // Get user-entered amount
      final amount = double.tryParse(widget.controller?.text ?? "0") ?? 0;
      final convertedValue = amount * exchangeRate;

      // Format AED value
      final formatter = NumberFormat('#,###');
      final formattedAED = formatter.format(convertedValue.toInt());

      //   Update AED controller
      setState(() {
        aedController.text = formattedAED;
      });

      // Emit updated value with AED equivalent
      if (widget.onChanged != null) {
        widget.onChanged!({
          'fromCurrency': selectedCurrency?.name,
          'fromVal': amount,
          'aedEquivalent': convertedValue,
        });
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }
}
