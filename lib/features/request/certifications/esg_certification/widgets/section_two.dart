import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/model.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/sff_customtable.dart';
import 'package:wcas_frontend/models/request/esg_certification.dart';

class SectionTwo extends StatefulWidget {
  final EsgCertificationViewModel viewModel;
  const SectionTwo({super.key, required this.viewModel});

  @override
  State<SectionTwo> createState() => _SectionTwoState();
}

class _SectionTwoState extends State<SectionTwo> {
  bool? value = false;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final sustainableFinanceCategoryList = widget.viewModel.esgSffCategories;
    final briefDescriptionList = widget.viewModel.esgSffCategoriess;

    _controllers = List.generate(sustainableFinanceCategoryList!.length, (i) {
      final meta = sustainableFinanceCategoryList[i];
      // find matching API record by name (if any)
      final record = briefDescriptionList.firstWhere(
        (sffcategoriesList) => sffcategoriesList.sffCategory == meta.name,
        orElse: () => SffCategory(
            sffCategory: meta.name, isSelected: false, briefDesc: ''),
      );
      return TextEditingController(text: record.briefDesc);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
      _controllers.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String headerTitle = widget.viewModel.sectionTitles!.length > 1
        ? widget.viewModel.sectionTitles![1].name!.tr()
        : '';

    final String sectionGuidelines =
        widget.viewModel.additionalGuidelines!.length > 1
            ? widget.viewModel.additionalGuidelines![1].name!
            : '';
    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(title: headerTitle),
          const Gap(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SffCustomtable(
              readOnly: widget.viewModel.isReadOnly,
              onCheckBoxChanged: (index, newValue) {
                final String? id =
                    widget.viewModel.esgSffCategories![index].name;
                widget.viewModel.updateCategorySelectionById(id!, newValue);
              },
              onBriefDescChanged: (index, newBriefDesc) {
                final String? id =
                    widget.viewModel.esgSffCategories![index].name;
                widget.viewModel.updateCategoryBriefDescById(id!, newBriefDesc);
              },
              categories: widget.viewModel.esgSffCategoriess,
              categoriesLocalDb: (widget.viewModel.esgSffCategories)!,
              controllers: _controllers,
            ),
          ),
          GuidelinesSection(
            headerText:
                'certification.esgCertification.additionalGuidnaceText'.tr(),
            guidelines: sectionGuidelines,
          ),
          const Gap(),
        ],
      ),
    );
  }
}
