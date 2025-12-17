import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/auth/widgets/logo_section.dart';
import 'package:wcas_frontend/features/auth/select_role/model.dart';
import 'package:wcas_frontend/features/auth/select_role/state.dart';
import 'package:wcas_frontend/features/auth/select_role/widgets/select_role_dropdown.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    SelectRoleViewModel viewModel = context.read<SelectRoleViewModel>();
    return BlocBuilder<SelectRoleViewModel, SelectRoleState>(
        builder: (context, state) {
      return Scaffold(
          body: Center(
        child: SingleChildScrollView(
          child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGrey,
                    spreadRadius: 10,
                    blurRadius: 50,
                  ),
                ],
              ),
              child: Container(
                color: AppColors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LogoSection(
                      width: 800.w,
                      // height: 350,
                    ),
                    Container(
                      width: 800.w,
                      padding: const EdgeInsets.all(40),
                      color: AppColors.loginBackground,
                      child: Container(
                        width: 800.w,
                        color: AppColors.darkBlue,
                        padding: const EdgeInsets.all(20),
                        child: SelectRoleDropdown(
                          viewModel: viewModel,
                          state: state,
                          width: 800.w,
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ));
    });
  }
}
