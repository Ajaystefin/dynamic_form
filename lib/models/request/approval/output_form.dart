/// Represents an output form with metadata and references.
class OutputForm {
  /// Creates an [OutputForm] instance.
  ///
  /// [id] and [url] are required fields.
  OutputForm({
    required this.id,
    required this.url,
    this.name,
    this.isSelected = false,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.ref5,
  });

  /// Creates an [OutputForm] instance from a JSON map.
  factory OutputForm.fromJson(Map<String, dynamic> json) {
    return OutputForm(
      name: json["name"] as String?,
      id: json["id"] as int?,
      url: json["url"] as String?,
    );
  }

  /// Name of the form.
  String? name;

  /// Indicates if the form is selected.
  bool isSelected;

  /// Unique identifier of the form.
  int? id;

  /// URL associated with the form.
  String? url;

  /// Reference field 1.
  String? ref1;

  /// Reference field 2.
  String? ref2;

  /// Reference field 3.
  String? ref3;

  /// Reference field 4.
  String? ref4;

  /// Reference field 5.
  String? ref5;
}
