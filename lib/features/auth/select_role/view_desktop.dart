import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/auth/select_role/model.dart";
import "package:wcas_frontend/features/auth/select_role/state.dart";
import "package:wcas_frontend/features/auth/select_role/widgets/select_role_dropdown.dart";
import "package:wcas_frontend/features/auth/widgets/logo_section.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    final SelectRoleViewModel viewModel = context.read<SelectRoleViewModel>();
    return BlocBuilder<SelectRoleViewModel, SelectRoleState>(
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: DecoratedBox(
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
                      Container(
                        width: 400.w,
                        height: 500,
                        padding: const EdgeInsets.all(60),
                        color: AppColors.loginBackground,
                        child: Container(
                          width: 400.w,
                          height: 450,
                          color: AppColors.darkBlue,
                          padding: const EdgeInsets.all(20),
                          child: SelectRoleDropdown(
                            viewModel: viewModel,
                            state: state,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
