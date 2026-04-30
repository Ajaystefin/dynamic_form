class AppendixEntry {
  //Notes(5000)

  AppendixEntry({
    required this.id,
    this.label = "",
    this.value = "",
  });
  final String id;
  final String label; //Name(100)
  final String value;

  AppendixEntry copyWith({String? label, String? value}) => AppendixEntry(
        id: id,
        label: label ?? this.label,
        value: value ?? this.value,
      );
}
