import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/utils/currency_utils.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

class DynamicFormCurrencyDropdownTextfield extends StatefulWidget {
  const DynamicFormCurrencyDropdownTextfield({
    required this.fieldData,
    required this.onSubmit,
    super.key,
    this.document,
    this.showLabel = false,
    this.inputFormatters,
    this.controller,
  });
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  @override
  State<DynamicFormCurrencyDropdownTextfield> createState() =>
      _DynamicFormCurrencyDropdownTextfieldState();
}

class _DynamicFormCurrencyDropdownTextfieldState
    extends State<DynamicFormCurrencyDropdownTextfield> {
  late TextEditingController _controller;

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

  @override
  void didUpdateWidget(DynamicFormCurrencyDropdownTextfield oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Extract old and new field values
    final oldData = CurrencyUtils.extractFromDocument(
      oldWidget.document,
      oldWidget.fieldData.key,
    );
    final newData = CurrencyUtils.extractFromDocument(
      widget.document,
      widget.fieldData.key,
    );

    // Check if amount or currency changed
    final amountChanged = oldData?.amount != newData?.amount;
    final currencyChanged = oldData?.currency != newData?.currency;

    if (amountChanged || currencyChanged) {
      if (newData != null && newData.amount != null) {
        final formattedAmount = newData.formattedAmount;

        if (_controller.text != formattedAmount) {
          _controller.text = formattedAmount;
        }
      } else if (newData == null || newData.amount == null) {
        if (_controller.text.isNotEmpty) {
          _controller.clear();
        }
      }
    }
  }

  void _initializeFromDocument() {
    final CurrencyFieldData? data = CurrencyUtils.extractFromDocument(
      widget.document,
      widget.fieldData.key,
    );

    if (data != null) {
      // Only set controller text if empty
      if (_controller.text.isEmpty && data.amount != null) {
        _controller.text = data.formattedAmount;
      }
    }
  }

  // Get the current currency from document
  String? _getCurrentCurrency() {
    final CurrencyFieldData? data = CurrencyUtils.extractFromDocument(
      widget.document,
      widget.fieldData.key,
    );
    return data?.currency;
  }

  // Get the initial AED equivalent from document
  double? _getInitialAedEquivalent() {
    final CurrencyFieldData? data = CurrencyUtils.extractFromDocument(
      widget.document,
      widget.fieldData.key,
    );
    return data?.aedEquivalent;
  }

  @override
  Widget build(BuildContext context) {
    final List<Option> options = widget.fieldData.optionList ?? const [];

    // Read currency directly from document instead of cached value
    final String? currentCurrency = _getCurrentCurrency();
    final Option? initial = (currentCurrency ?? "").isEmpty
        ? (options.isNotEmpty ? options.first : null)
        : Option(key: currentCurrency, pairValue: currentCurrency);

    final Widget child = CurrencyDropdown(
      options: options,
      initialOption: initial,
      initialAedEquivalent: _getInitialAedEquivalent(),
      maxLength: widget.fieldData.maxLength,
      controller: _controller,
      readOnly: widget.fieldData.isDisable,
      disableDropdown: widget.fieldData.disableDropdown,
      validator: widget.fieldData.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return widget.fieldData.message ??
                    "${widget.fieldData.label} is required";
              }
              return null;
            }
          : null,
      onChanged: (value) {
        widget.onSubmit(value);
      },
    );
    return widget.showLabel
        ? LabelWidget(
            showLabel: widget.showLabel,
            label: widget.fieldData.label,
            isRequired: widget.fieldData.isRequired,
            exponent: widget.fieldData.isCMOUpdate ? "#" : null,
            child: child,
          )
        : child;
  }
}

class CurrencyDropdown extends StatefulWidget {
  const CurrencyDropdown({
    required this.options,
    super.key,
    this.controller,
    this.textFieldLabel,
    this.dropdownLabel,
    this.textFieldWidth,
    this.initialOption,
    this.initialAedEquivalent,
    this.validator,
    this.maxLength,
    this.onChanged,
    this.readOnly = false,
    this.disableDropdown = false,
  });
  final TextEditingController? controller;
  final String? textFieldLabel;
  final String? dropdownLabel;
  final int? maxLength;
  final double? textFieldWidth;
  final List<Option> options;
  final Option? initialOption;
  final double? initialAedEquivalent;
  final String? Function(String?)? validator;
  final Function(Map<String, dynamic>)? onChanged;
  final bool readOnly;
  final bool disableDropdown;

  @override
  State<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  Option? selectedOption;
  final TextEditingController aedController = TextEditingController();
  double exchangeRate = 0;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialOption;

    // Initialize AED controller with prefill value if available
    if (widget.initialAedEquivalent != null &&
        widget.initialAedEquivalent! > 0) {
      aedController.text =
          CurrencyUtils.formatCurrency(widget.initialAedEquivalent!);
    }
  }

  @override
  void didUpdateWidget(CurrencyDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected option if initialOption changed
    if (widget.initialOption?.key != oldWidget.initialOption?.key) {
      setState(() {
        selectedOption = widget.initialOption;
      });

      // Currency changed - fetch exchange rate and recalculate AED equivalent
      if (widget.initialOption != null &&
          widget.initialOption!.pairValue != ServerConstants.aedCurrency &&
          widget.controller != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          // Fetch exchange rate for new currency
          await getCurrencyRates(
            Reference(name: widget.initialOption?.pairValue),
          );

          // Recalculate and emit the updated value
          if (!mounted) return;
          if (widget.onChanged != null) {
            final double numValue =
                CurrencyUtils.parseCurrency(widget.controller!.text) ?? 0;
            final double aedValue = CurrencyUtils.calculateAedEquivalent(
              currency: widget.initialOption!.pairValue ?? "",
              amount: numValue,
              exchangeRate: exchangeRate,
            );

            widget.onChanged!(
              CurrencyUtils.createCurrencyMap(
                currency: widget.initialOption!.pairValue ?? "",
                amount: numValue,
                aedEquivalent: aedValue,
              ),
            );
          }
        });
      }
    } else if (widget.initialAedEquivalent == null &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty &&
        selectedOption != null &&
        selectedOption?.pairValue != ServerConstants.aedCurrency) {
      // Amount changed programmatically (same currency, non-AED)
      // and AED equivalent is null — recalculate it
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        // Fetch exchange rate if not already cached (exchangeRate == 0)
        if (exchangeRate == 0.0) {
          await getCurrencyRates(Reference(name: selectedOption?.pairValue));
        }

        if (!mounted) return;

        // Recalculate AED equivalent with current exchange rate
        final double numValue =
            CurrencyUtils.parseCurrency(widget.controller!.text) ?? 0;
        final double aedValue = CurrencyUtils.calculateAedEquivalent(
          currency: selectedOption!.pairValue ?? "",
          amount: numValue,
          exchangeRate: exchangeRate,
        );

        // Update AED controller directly
        setState(() {
          aedController.text = CurrencyUtils.formatCurrency(aedValue);
        });

        // Emit updated value to parent
        if (widget.onChanged != null) {
          widget.onChanged!(
            CurrencyUtils.createCurrencyMap(
              currency: selectedOption!.pairValue ?? "",
              amount: numValue,
              aedEquivalent: aedValue,
            ),
          );
        }
      });
    }

    // Update AED equivalent if it changed
    if (widget.initialAedEquivalent != oldWidget.initialAedEquivalent) {
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (widget.initialAedEquivalent != null &&
            widget.initialAedEquivalent! > 0) {
          final formattedAed =
              CurrencyUtils.formatCurrency(widget.initialAedEquivalent!);
          if (aedController.text != formattedAed) {
            setState(() {
              aedController.text = formattedAed;
            });
          }
        } else {
          // Don't clear if a recalculation is pending (controller has amount
          // and currency is non-AED — the recalculation block above will
          // populate the AED equivalent)
          final bool recalculationPending = widget.controller != null &&
              widget.controller!.text.isNotEmpty &&
              selectedOption?.pairValue != ServerConstants.aedCurrency;

          if (!recalculationPending && aedController.text.isNotEmpty) {
            setState(aedController.clear);
          }
        }
      });
    }
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
              key: ValueKey(selectedOption?.pairValue ?? ""),
              borderRadius: 4,
              label: widget.dropdownLabel ?? "",
              disabledColor: AppColors.scaffoldBackground,
              textColor: AppColors.defaultTextColor,
              options: widget.options
                  .map(
                    (option) => CustomDropdownItem(
                      value: option.pairValue ?? "",
                      label: option.pairValue ?? "",
                    ),
                  )
                  .toList(),
              height: 34,
              isSearchable: false,
              initialOption: CustomDropdownItem(
                value: selectedOption?.pairValue ?? "",
                label: selectedOption?.pairValue ?? "",
              ),
              callBack: (widget.readOnly || widget.disableDropdown)
                  ? null
                  : (selectedValue) {
                      // Defer entire callback logic to post-frame to ensure
                      // the widget build is complete relative to parent/ancestor builds.
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!mounted) return;

                        // Safe option retrieval with fallback to avoid "Bad
                        // state: No element"
                        final newOption = widget.options.firstWhere(
                          (opt) => (opt.pairValue ?? "") == (selectedValue),
                          orElse: () =>
                              Option(key: "AED", pairValue: "AED"), // fallback
                        );

                        // Update local state WITHOUT setState
                        // We're using a dynamic key based on selectedOption, so
                        // calling
                        // setState here would cause the widget to be recreated
                        // during
                        // this callback, which locks the widget tree.
                        // The parent's onChanged callback will update the
                        // document,
                        // which will trigger a rebuild from above anyway.
                        selectedOption = newOption;

                        // Fetch exchange rate if not AED
                        if (selectedOption?.pairValue !=
                            ServerConstants.aedCurrency) {
                          await getCurrencyRates(
                            Reference(name: selectedOption?.pairValue),
                          );
                        }

                        // Check mounted again after await
                        if (!mounted) return;

                        // Emit updated value to parent
                        if (widget.onChanged != null &&
                            widget.controller != null) {
                          final double numValue = CurrencyUtils.parseCurrency(
                                widget.controller!.text,
                              ) ??
                              0;
                          final double aedValue =
                              CurrencyUtils.calculateAedEquivalent(
                            currency: selectedOption?.pairValue ?? "",
                            amount: numValue,
                            exchangeRate: exchangeRate,
                          );

                          widget.onChanged!(
                            CurrencyUtils.createCurrencyMap(
                              currency: selectedOption?.pairValue ?? "",
                              amount: numValue,
                              aedEquivalent: aedValue,
                            ),
                          );
                        }
                      });
                    },
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsWithMaxDigitsFormatter(
                maxDigits: widget.maxLength ?? 12,
              ),
            ],
            maxLength: widget.maxLength,
            semanticLabel: widget.textFieldLabel,
            validator: widget.validator,
            controller: widget.controller,
            hintText: widget.textFieldLabel,
            width: widget.textFieldWidth,
            readOnly: widget.readOnly,
            filled: widget.readOnly,
            onChanged: (value) async {
              final double numValue = CurrencyUtils.parseCurrency(value) ?? 0;

              if (widget.onChanged != null && selectedOption != null) {
                final double aedValue = CurrencyUtils.calculateAedEquivalent(
                  currency: selectedOption!.pairValue ?? "",
                  amount: numValue,
                  exchangeRate: exchangeRate,
                );

                // Always emit all three fields for field dependencies
                widget.onChanged!(
                  CurrencyUtils.createCurrencyMap(
                    currency: selectedOption!.pairValue ?? "",
                    amount: numValue,
                    aedEquivalent: aedValue,
                  ),
                );

                // Fetch exchange rate if not AED
                if (!CurrencyUtils.isAedCurrency(selectedOption!.pairValue)) {
                  await getCurrencyRates(
                    Reference(name: selectedOption?.pairValue),
                  );
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
                borderRadius: 4,
                label:
                    "", // Empty: initialOption already provides the "AED" label
                disabledColor: AppColors.scaffoldBackground,
                textColor: AppColors.defaultTextColor,
                height: 34,
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
      final CurrencyRates currencyRates = await FacilitySecurityRepository
          .instance
          .getCurrencyRates(selectedCurrency);

      exchangeRate =
          (currencyRates.rates[selectedCurrency?.name] ?? 0).toDouble();

      // Get user-entered amount
      final double amount =
          CurrencyUtils.parseCurrency(widget.controller?.text ?? "0") ?? 0;
      final double convertedValue = CurrencyUtils.calculateAedEquivalent(
        currency: selectedCurrency?.name ?? "",
        amount: amount,
        exchangeRate: exchangeRate,
      );

      //   Update AED controller
      setState(() {
        aedController.text = CurrencyUtils.formatCurrency(convertedValue);
      });

      // Emit updated value with AED equivalent
      if (widget.onChanged != null) {
        widget.onChanged!(
          CurrencyUtils.createCurrencyMap(
            currency: selectedCurrency?.name ?? "",
            amount: amount,
            aedEquivalent: convertedValue,
          ),
        );
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }
}
