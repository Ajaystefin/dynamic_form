import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/auth/login/model.dart";
import "package:wcas_frontend/features/auth/login/state.dart";
import "package:wcas_frontend/features/auth/login/widgets/form_section.dart";
import "package:wcas_frontend/features/auth/widgets/logo_section.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({
    super.key,
  });

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
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              DecoratedBox(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LogoSection(
                        width: 300.w,
                        height: 450,
                      ),
                      FormSection(
                        width: 400.w,
                        height: 500,
                        viewModel: viewModel,
                        padding: const EdgeInsets.all(60),
                        state: state,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 10),
                alignment: Alignment.bottomRight,
                child: Text(
                  "version ${viewModel.state.appVersion}",
                  style: const TextStyle(color: AppColors.darkGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
