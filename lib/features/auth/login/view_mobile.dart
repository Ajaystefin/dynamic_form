import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/auth/login/model.dart";
import "package:wcas_frontend/features/auth/login/state.dart";
import "package:wcas_frontend/features/auth/login/widgets/form_section.dart";
import "package:wcas_frontend/features/auth/widgets/logo_section.dart";

/// Mobile view for the login screen.
class ViewMobile extends StatelessWidget {
  /// Creates a [ViewMobile].
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginViewModel viewModel = context.read<LoginViewModel>();

    return BlocBuilder<LoginViewModel, LoginState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(state, viewModel, context),
        );
      },
    );
  }

  Widget _buildBody(
    LoginState state,
    LoginViewModel viewModel,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const SizedBox(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGrey,
                      spreadRadius: 10,
                      blurRadius: 50,
                    ),
                  ],
                ),
                child: ColoredBox(
                  color: AppColors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LogoSection(
                        width: 800.w,
                        // height: 350,
                      ),
                      FormSection(
                        width: 800.w,
                        state: state,
                        viewModel: viewModel,
                        padding: const EdgeInsets.all(20),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                // margin: EdgeInsets.zero,
                padding: const EdgeInsets.only(right: 10),
                alignment: Alignment.bottomRight,
                child: Text(
                  "Build ${viewModel.state.appVersion}",
                  style: const TextStyle(color: AppColors.darkGrey),
                ),
              ),
              // ),
              // Text("sdsd")
            ],
          ),
        ),
      ),
    );
  }
}
