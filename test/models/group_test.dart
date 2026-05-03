import "package:test/test.dart";
import "package:wcas_frontend/models/request/group.dart";

void main() {
  group("Group model", () {
    test("constructor assigns fields", () {
      final g = Group(id: "G-1", name: "Alpha", groupOwner: 42);
      expect(g.id, "G-1");
      expect(g.name, "Alpha");
      expect(g.groupOwner, 42);
    });

    test("fromJson parses id, name and groupOwner (string -> int)", () {
      final json = {
        "GroupId": "G-99",
        "GroupName": "Bravo",
        "GroupOwner": "123", // string that can be parsed
      };

      final g = Group.fromJson(json);
      expect(g.id, "G-99");
      expect(g.name, "Bravo");
      expect(g.groupOwner, 123);
    });

    test(
        "fromJson sets groupOwner to null when"
        " GroupOwner is null or not parsable", () {
      // Null GroupOwner
      final jsonNull = {
        "GroupId": "G-0",
        "GroupName": "NullOwner",
        "GroupOwner": null,
      };
      final gNull = Group.fromJson(jsonNull);
      expect(gNull.groupOwner, isNull);

      // Non-parsable (e.g., empty string or whitespace)
      final jsonBad = {
        "GroupId": "G-2",
        "GroupName": "BadOwner",
        "GroupOwner": " ", // int.tryParse(' ') -> null
      };
      final gBad = Group.fromJson(jsonBad);
      expect(gBad.groupOwner, isNull);
    });

    test("toJson outputs matching keys and values", () {
      final g = Group(id: "G-7", name: "Seven", groupOwner: 777);
      final out = g.toJson();

      expect(out["GroupId"], "G-7");
      expect(out["GroupName"], "Seven");
      expect(out["GroupOwner"], 777);
    });

    test("toJson preserves nulls", () {
      final g = Group();
      final out = g.toJson();
      expect(out["GroupId"], isNull);
      expect(out["GroupName"], isNull);
      expect(out["GroupOwner"], isNull);
    });
  });
}
