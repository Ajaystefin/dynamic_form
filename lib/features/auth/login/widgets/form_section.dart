import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/login/model.dart";
import "package:wcas_frontend/features/auth/login/state.dart";

/// Displays the login form section.
class FormSection extends StatelessWidget {
  /// Creates a login form section widget.
  const FormSection({
    required this.viewModel,
    required this.state,
    super.key,
    this.height,
    this.width,
    this.padding,
  });

  /// Login view model.
  final LoginViewModel viewModel;

  /// Optional height of the widget.
  final double? height;

  /// Optional width of the widget.
  final double? width;

  /// Current login state.
  final LoginState state;

  /// Optional padding for the widget.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: AppColors.loginBackground,
      padding: padding,
      child: Container(
        width: width,
        height: height,
        color: AppColors.darkBlue,
        padding: const EdgeInsets.all(30),
        child: viewModel.hasNoRoles ?? false
            ? Column(
                spacing: 60,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(),
                  Text(
                    // Build welcome: "{welcomeTitle}{UserName}"
                    "${"auth.selectRole.welcomeTitle".tr()}"
                    "${Globals.user?.name?.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: AppStyle.fontSizeLarge,
                      color: AppColors.accordionPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "auth.login.errorMessageNoRoles".tr(),
                    style: const TextStyle(
                      fontSize: AppStyle.fontSizeLarge,
                      color: AppColors.alertToastWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomButton(
                    width: 200.w,
                    semanticLabel: "auth.login.semantics.retryButton".tr(),
                    label: "auth.login.signInRetry".tr(),
                    textColor: AppColors.black,
                    textStyle: TextStyle(
                      fontSize: context.isDesktop
                          ? AppStyle.fontSizeLarge
                          : AppStyle.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {
                      viewModel.refresh();
                    },
                    backgroundColor: AppColors.secondary,
                    isLoading: state.loaderStatus == LoadingStatus.loading,
                    borderRadius: 12,
                  ),
                ],
              )
            : Form(
                key: viewModel.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    CustomTextField(
                      // initialValue: viewModel.username,
                      semanticLabel: "auth.login.semantics.usernameField".tr(),
                      textStyle: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppStyle.fontSizeLarge,
                      ),
                      labelText: "auth.login.username".tr(),
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "auth.login.enterUsername".tr();
                        }
                        return null;
                      },
                      errorTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.failureLogin,
                      ),
                      useUnderlineBorder: true,
                      labelStyle: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: AppStyle.fontSizeLarge,
                      ),
                      onSaved: (String? value) {
                        viewModel.username = value;
                      },
                    ),
                    CustomTextField(
                      // initialValue: viewModel.password,
                      useUnderlineBorder: true,
                      semanticLabel: "auth.login.semantics.passwordField".tr(),
                      errorTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.failureLogin,
                      ),
                      contentPadding:
                          const EdgeInsets.only(left: 12, bottom: 12),
                      suffixIcon: viewModel.hasPasswordInput
                          ? InkWell(
                              onTap: viewModel.togglePasswordVisibility,
                              child: Icon(
                                viewModel.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.darkGrey,
                              ),
                            )
                          : null,

                      textStyle: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppStyle.fontSizeLarge,
                      ),
                      labelText: "auth.login.password".tr(),
                      labelStyle: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: AppStyle.fontSizeLarge,
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      isPassword: !viewModel.isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "auth.login.enterPassword".tr();
                        }
                        return null;
                      },
                      onChanged: (value) {
                        viewModel.onPasswordChanged(value);
                      },
                      onSaved: (String? value) {
                        viewModel.password = value;
                      },
                      onSubmitted: (value) async {
                        {
                          if (viewModel.formKey.currentState!.validate()) {
                            await viewModel.onSubmitPressed();
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                      width: 200.w,
                      semanticLabel: "auth.login.semantics.signInButton".tr(),
                      label: "auth.login.signIn".tr(),
                      textColor: AppColors.black,
                      textStyle: TextStyle(
                        fontSize: context.isDesktop
                            ? AppStyle.fontSizeLarge
                            : AppStyle.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () async {
                        if (viewModel.formKey.currentState!.validate()) {
                          await viewModel.onSubmitPressed();
                        }
                      },
                      backgroundColor: AppColors.secondary,
                      isLoading: state.loaderStatus == LoadingStatus.loading,
                      borderRadius: 12,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomSelectableText(
                        text: viewModel.errorText ?? " ",
                        style: const TextStyle(
                          color: AppColors.failure,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
