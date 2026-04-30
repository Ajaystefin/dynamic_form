class OutputForm {
  OutputForm({
    required this.id,
    required this.url,
    this.name,
    this.isSelected = false,
  });

  factory OutputForm.fromJson(Map<String, dynamic> json) {
    return OutputForm(
      name: json["name"] as String?,
      id: json["id"] as int?,
      url: json["url"] as String?,
      isSelected: false,
    );
  }
  String? name;
  bool isSelected;
  int? id;
  String? url;
}
