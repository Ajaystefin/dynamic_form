import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/approval/output_form.dart";

void main() {
  group("OutputForm", () {
    test(
        "OutputForm can be created with a name and default isSelected to false",
        () {
      final outputForm = OutputForm(name: "Test Form", id: 1, url: "");
      expect(outputForm.name, "Test Form");
      expect(outputForm.isSelected, false);
    });

    test("OutputForm can be created with a name and specified isSelected", () {
      final outputForm =
          OutputForm(name: "Another Form", id: 1, isSelected: true, url: "");
      expect(outputForm.name, "Another Form");
      expect(outputForm.isSelected, true);
    });

    test(
        "fromJson creates an OutputForm object with"
        " correct name and isSelected false", () {
      final Map<String, dynamic> json = {"name": "JSON Form"};
      final outputForm = OutputForm.fromJson(json);
      expect(outputForm.name, "JSON Form");
      expect(outputForm.isSelected, false);
    });

    test("fromJson handles null name correctly", () {
      final Map<String, dynamic> json = {};
      final outputForm = OutputForm.fromJson(json);
      expect(outputForm.name, isNull);
      expect(outputForm.isSelected, false);
    });
  });
}
