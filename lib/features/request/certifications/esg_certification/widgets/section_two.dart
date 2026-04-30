import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/guidellines_list.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/sff_customtable.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

class SectionTwo extends StatefulWidget {
  const SectionTwo({required this.viewModel, super.key});
  final EsgCertificationViewModel viewModel;

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
    final List<Reference>? sustainableFinanceCategoryList =
        widget.viewModel.esgSffCategories;
    final List<SffCategory> briefDescriptionList =
        widget.viewModel.esgSffCategoriess;

    _controllers = List.generate(sustainableFinanceCategoryList!.length, (i) {
      final Reference meta = sustainableFinanceCategoryList[i];
      // find matching API record by name (if any)
      final SffCategory record = briefDescriptionList.firstWhere(
        (sffcategoriesList) => sffcategoriesList.sffCategory == meta.name,
        orElse: () => SffCategory(
          sffCategory: meta.name,
          isSelected: false,
          briefDesc: "",
        ),
      );
      return TextEditingController(text: record.briefDesc);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
      _controllers.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int secId = widget.viewModel.sectionIdAt(1);
    final String headerTitle =
        secId != 0 ? (widget.viewModel.sectionTitles![1].name ?? "").tr() : "";
    final String sectionGuidelines =
        (secId != 0) ? widget.viewModel.guidelinesForSectionId(secId) : "";

    return BoxLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeader(title: headerTitle),
          const Gap(),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SffCustomtable(
              viewModel: widget.viewModel,
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
                "certification.esgCertification.additionalGuidnaceText".tr(),
            guidelines: sectionGuidelines,
          ),
          const Gap(),
        ],
      ),
    );
  }
}
