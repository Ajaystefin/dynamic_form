import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/comment_history/comments_table.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/widgets/bottom_controls.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  ViewDesktop({super.key});

  final userList = [
    CustomDropdownItem(
      value: "User 1",
      onPressed: () {},
    ),
    CustomDropdownItem(
      value: "User 2",
      onPressed: () {},
    ),
    CustomDropdownItem(
      value: "User 3",
      onPressed: () {},
    )
  ];

  @override
  Widget build(BuildContext context) {
    RequestForFolViewModel viewModel = context.read<RequestForFolViewModel>();
    return BlocBuilder<RequestForFolViewModel, RequestForFolState>(
        builder: (context, state) {
      return Layout(
          child: SingleChildScrollView(
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "approval.requestForFOL.sectionTitle".tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: _body(context, state, viewModel),
              ),
            ],
          ),
        ),
      ));
    });
  }

  Widget _body(BuildContext context, RequestForFolState state,
      RequestForFolViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('Empty State'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('Error State'.tr()),
        );
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(BuildContext context, RequestForFolState state,
      RequestForFolViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Gap(),
      LabelWidget(
        isRequired: true,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        label: "approval.requestForFOL.remarkJustification".tr(),
        child: CustomTextArea(
          semanticLabel: "approval.requestForFOL.remarkJustification".tr(),
          maxLength: 5000,
          initialValue: viewModel.strategyComment,
          validator: CustomValidator.requiredField,
          onSaved: (String? value) {
            viewModel.strategyComment = value;
          },
        ),
      ),
      const Gap(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomSelectableText(
          text: "approval.requestForFOL.commentHistory".tr(),
          semanticsLabel: "approval.requestForFOL.commentHistory".tr(),
          textAlign: TextAlign.left,
          style: AppStyle.tableHeaderStyle,
        ),
      ]),
      CommentsTableWidget(comments: viewModel.comments),
      const Gap(),
      BottomControls(
        viewModel: viewModel,
        context: context,
      ),
      const Gap(),
    ]);
  }
}
