import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Deviation/Breach Justification field on the
/// Request Information screen.
///
/// Allows users to provide or review the justification for
/// policy deviations, exceptions, or limit breaches associated
/// with the current request.
class DeviationBreachJustification extends StatelessWidget {
  /// Creates a [DeviationBreachJustification].
  const DeviationBreachJustification({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages deviation and breach justification details.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.applicationDetails?.deviationBreachJustification ?? "";
    final bool isValid = viewModel.canEdit;
    //  bool isValid = viewModel.canEdit
    //     ? viewModel.viewAccessRolesCheck()
    //         ? true
    //         : false
    //     : false;
    return LabelWidget(
      label:
          "requestInformation.requestInformation.deviationBreachJustification"
              .tr(),
      isRequired: true,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            final controller = viewModel.deviationJustificationController;

            controller
              ..text += "\n"
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );

            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: CustomTextArea(
          controller: viewModel.deviationJustificationController,
          key: const ValueKey("deviationBreachJustification"),
          filled: !isValid,
          readOnly: !isValid,
          initialValue: initialValue,
          counterText: "",
          semanticLabel:
              "requestInformation.requestInformation.deviationBreachJustification"
                  .tr(),
          maxLength: 2000,
          hintText: "requestInformation.requestInformation.typeHere".tr(),
          validator: CustomValidator.requiredField,
          onSaved: (String? value) {
            viewModel.applicationDetails?.deviationBreachJustification =
                value ?? "";
          },
        ),
      ),
    );
  }
}
