class OutputForm {
  String? name;
  bool isSelected;

  OutputForm({this.name, this.isSelected = false});

  factory OutputForm.fromJson(Map<String, dynamic> json) {
    return OutputForm(
      name: json['name'] as String?,
      isSelected: false,
    );
  }
}
