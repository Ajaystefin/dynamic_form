import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/auth/login/model.dart';
import 'package:wcas_frontend/features/auth/login/state.dart';

class FormSection extends StatelessWidget {
  final LoginViewModel viewModel;
  final double? height;
  final double? width;
  final LoginState state;
  final EdgeInsets? padding;
  const FormSection({
    super.key,
    required this.viewModel,
    this.height,
    this.width,
    this.padding,
    required this.state,
  });

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
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              CustomTextField(
                // initialValue: viewModel.username,
                showToolTip: false,
                semanticLabel: "auth.login.semantics.usernameField".tr(),
                textStyle: const TextStyle(
                    color: AppColors.white, fontSize: AppStyle.fontSizeLarge),
                labelText: 'auth.login.username'.tr(),
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'auth.login.enterUsername'.tr();
                  }
                  return null;
                },
                errorTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.failureLogin),
                useUnderlineBorder: true,
                labelStyle: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: AppStyle.fontSizeLarge),
                onSaved: (String? value) {
                  viewModel.username = value;
                },
              ),
              CustomTextField(
                // initialValue: viewModel.password,
                useUnderlineBorder: true,
                semanticLabel: "auth.login.semantics.passwordField".tr(),
                errorTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.failureLogin),
                showToolTip: false,
                contentPadding: const EdgeInsets.only(left: 12, bottom: 12),
                suffixIcon: viewModel.hasPasswordInput
                    ? InkWell(
                        child: Icon(
                          viewModel.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.darkGrey,
                        ),
                        onTap: () {
                          viewModel.togglePasswordVisibility();
                        },
                      )
                    : null,

                textStyle: const TextStyle(
                    color: AppColors.white, fontSize: AppStyle.fontSizeLarge),
                labelText: 'auth.login.password'.tr(),
                labelStyle: const TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: AppStyle.fontSizeLarge,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                isPassword: !viewModel.isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'auth.login.enterPassword'.tr();
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
                label: 'auth.login.signIn'.tr(),
                textColor: AppColors.black,
                textStyle: TextStyle(
                    fontSize: context.isDesktop
                        ? AppStyle.fontSizeLarge
                        : AppStyle.fontSizeMedium,
                    fontWeight: FontWeight.bold),
                onPressed: () async {
                  if (viewModel.formKey.currentState!.validate()) {
                    await viewModel.onSubmitPressed();
                  }
                },
                backgroundColor: AppColors.secondary,
                isLoading: (state.loaderStatus == LoadingStatus.loading)
                    ? true
                    : false,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
