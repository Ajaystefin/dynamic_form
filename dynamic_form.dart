import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field_dependencies.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class DynamicForm extends StatefulWidget {
  final List<Section> sections;
  final Map<String, dynamic> document;
  final GlobalKey formKey;
  final FieldDependencies? dependencies;

  const DynamicForm({
    super.key,
    required this.sections,
    required this.document,
    required this.formKey,
    this.dependencies,
  });

  @override
  State<DynamicForm> createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Form(
        key: widget.formKey,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.sections.length,
          itemBuilder: (context, index) => widget.sections[index].rows != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.sections[index].rows!.length,
                  itemBuilder: (context, rowIndex) {
                    if (widget.sections[index].rows![rowIndex].fields == null) {
                      return const SizedBox();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                            .length,
                        (fieldIndex) => Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyle.spacing,
                            vertical: AppStyle.spacingSmall,
                          ),
                          child: DynamicFormField(
                            field: widget.sections[index].rows![rowIndex]
                                .fields![fieldIndex],
                            document: widget.document,
                            dependencies: widget.dependencies,
                          ),
                        )),
                      ),
                    );
                  },
                )
              : Container(),
        ),
      ),
    );
  }
}
