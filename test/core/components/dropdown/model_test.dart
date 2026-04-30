import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/utils/logger.dart";

void main() {
  group("CustomDropdownItem", () {
    test("should create instance with required value", () {
      const testValue = "test_value";
      final item = CustomDropdownItem(value: testValue);

      expect(item.value, equals(testValue));
      expect(item.label, equals(testValue.toString()));
      expect(item.title, isNull);
      expect(item.onPressed, isNull);
    });

    test("should create instance with custom label", () {
      const testValue = "test_value";
      const customLabel = "Custom Label";
      final item = CustomDropdownItem(
        value: testValue,
        label: customLabel,
      );

      expect(item.value, equals(testValue));
      expect(item.label, equals(customLabel));
    });

    test("should create instance with title", () {
      const testValue = "test_value";
      const testTitle = "Test Title";
      final item = CustomDropdownItem(
        value: testValue,
        title: testTitle,
      );

      expect(item.value, equals(testValue));
      expect(item.title, equals(testTitle));
    });

    test("should create instance with onPressed callback", () {
      const testValue = "test_value";
      bool callbackCalled = false;
      void testCallback() {
        callbackCalled = true;
      }

      final item = CustomDropdownItem(
        value: testValue,
        onPressed: testCallback,
      );

      expect(item.onPressed, equals(testCallback));
      expect(callbackCalled, isFalse);

      item.onPressed!();
      expect(callbackCalled, isTrue);
    });

    test("should use value.toString() as default label when label is null", () {
      const intValue = 123;
      final item = CustomDropdownItem(value: intValue);

      expect(item.label, equals(intValue.toString()));
    });

    test("should handle null values", () {
      final item = CustomDropdownItem(value: null);

      expect(item.value, isNull);
      expect(item.label, equals("null"));
    });

    test("should handle complex object values", () {
      final complexValue = {"key": "value", "number": 42};
      final item = CustomDropdownItem(value: complexValue);

      expect(item.value, equals(complexValue));
      expect(item.label, equals(complexValue.toString()));
    });

    test("should create complete instance with all properties", () {
      const testValue = "test_value";
      const customLabel = "Custom Label";
      const testTitle = "Test Title";
      bool callbackCalled = false;
      logger.i(callbackCalled);
      void testCallback() {
        callbackCalled = true;
      }

      final item = CustomDropdownItem(
        value: testValue,
        label: customLabel,
        title: testTitle,
        onPressed: testCallback,
      );

      expect(item.value, equals(testValue));
      expect(item.label, equals(customLabel));
      expect(item.title, equals(testTitle));
      expect(item.onPressed, equals(testCallback));
    });
  });

  group("groupItemsByTitle", () {
    test("should group items by title correctly", () {
      final items = [
        CustomDropdownItem(value: "item1", title: "Group A"),
        CustomDropdownItem(value: "item2", title: "Group B"),
        CustomDropdownItem(value: "item3", title: "Group A"),
        CustomDropdownItem(value: "item4", title: "Group B"),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(2));

      final groupA = groups.firstWhere((g) => g.title == "Group A");
      final groupB = groups.firstWhere((g) => g.title == "Group B");

      expect(groupA.items.length, equals(2));
      expect(groupB.items.length, equals(2));
      expect(groupA.items[0].value, equals("item1"));
      expect(groupA.items[1].value, equals("item3"));
      expect(groupB.items[0].value, equals("item2"));
      expect(groupB.items[1].value, equals("item4"));
    });

    test("should handle items with null titles", () {
      final items = [
        CustomDropdownItem(value: "item1", title: "Group A"),
        CustomDropdownItem(value: "item2", title: null),
        CustomDropdownItem(value: "item3", title: "Group A"),
        CustomDropdownItem(value: "item4", title: null),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(2));

      final groupA = groups.firstWhere((g) => g.title == "Group A");
      final nullGroup = groups.firstWhere((g) => g.title == null);

      expect(groupA.items.length, equals(2));
      expect(nullGroup.items.length, equals(2));
    });

    test("should handle empty list", () {
      final items = <CustomDropdownItem>[];

      final groups = groupItemsByTitle(items);

      expect(groups, isEmpty);
    });

    test("should handle single item", () {
      final items = [
        CustomDropdownItem(value: "item1", title: "Single Group"),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(1));
      expect(groups[0].title, equals("Single Group"));
      expect(groups[0].items.length, equals(1));
      expect(groups[0].items[0].value, equals("item1"));
    });

    test("should handle all items with same title", () {
      final items = [
        CustomDropdownItem(value: "item1", title: "Same Group"),
        CustomDropdownItem(value: "item2", title: "Same Group"),
        CustomDropdownItem(value: "item3", title: "Same Group"),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(1));
      expect(groups[0].title, equals("Same Group"));
      expect(groups[0].items.length, equals(3));
    });

    test("should handle all items with null title", () {
      final items = [
        CustomDropdownItem(value: "item1", title: null),
        CustomDropdownItem(value: "item2", title: null),
        CustomDropdownItem(value: "item3", title: null),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(1));
      expect(groups[0].title, isNull);
      expect(groups[0].items.length, equals(3));
    });

    test("should preserve original order within groups", () {
      final items = [
        CustomDropdownItem(value: "first", title: "Group A"),
        CustomDropdownItem(value: "middle", title: "Group B"),
        CustomDropdownItem(value: "second", title: "Group A"),
        CustomDropdownItem(value: "third", title: "Group A"),
      ];

      final groups = groupItemsByTitle(items);
      final groupA = groups.firstWhere((g) => g.title == "Group A");

      expect(groupA.items[0].value, equals("first"));
      expect(groupA.items[1].value, equals("second"));
      expect(groupA.items[2].value, equals("third"));
    });

    test("should handle mixed value types", () {
      final items = [
        CustomDropdownItem(value: "string_value", title: "Mixed"),
        CustomDropdownItem(value: 42, title: "Mixed"),
        CustomDropdownItem(value: true, title: "Mixed"),
        CustomDropdownItem(value: null, title: "Mixed"),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(1));
      expect(groups[0].items.length, equals(4));
      expect(groups[0].items[0].value, equals("string_value"));
      expect(groups[0].items[1].value, equals(42));
      expect(groups[0].items[2].value, equals(true));
      expect(groups[0].items[3].value, isNull);
    });

    test("should handle empty string titles", () {
      final items = [
        CustomDropdownItem(value: "item1", title: ""),
        CustomDropdownItem(value: "item2", title: "Non-empty"),
        CustomDropdownItem(value: "item3", title: ""),
      ];

      final groups = groupItemsByTitle(items);

      expect(groups.length, equals(2));

      final emptyGroup = groups.firstWhere((g) => g.title == "");
      final nonEmptyGroup = groups.firstWhere((g) => g.title == "Non-empty");

      expect(emptyGroup.items.length, equals(2));
      expect(nonEmptyGroup.items.length, equals(1));
    });
  });

  group("ItemGroup", () {
    test("should create instance with title and items", () {
      const testTitle = "Test Group";
      final testItems = [
        CustomDropdownItem(value: "item1"),
        CustomDropdownItem(value: "item2"),
      ];

      final group = ItemGroup(testTitle, testItems);

      expect(group.title, equals(testTitle));
      expect(group.items, equals(testItems));
      expect(group.items.length, equals(2));
    });

    test("should create instance with null title", () {
      final testItems = [
        CustomDropdownItem(value: "item1"),
        CustomDropdownItem(value: "item2"),
      ];

      final group = ItemGroup(null, testItems);

      expect(group.title, isNull);
      expect(group.items, equals(testItems));
    });

    test("should create instance with empty items list", () {
      const testTitle = "Empty Group";
      final emptyItems = <CustomDropdownItem>[];

      final group = ItemGroup(testTitle, emptyItems);

      expect(group.title, equals(testTitle));
      expect(group.items, isEmpty);
    });

    test("should handle single item in group", () {
      const testTitle = "Single Item Group";
      final singleItem = [CustomDropdownItem(value: "single")];

      final group = ItemGroup(testTitle, singleItem);

      expect(group.title, equals(testTitle));
      expect(group.items.length, equals(1));
      expect(group.items[0].value, equals("single"));
    });

    test("should preserve items reference", () {
      const testTitle = "Reference Test";
      final originalItems = [
        CustomDropdownItem(value: "item1"),
        CustomDropdownItem(value: "item2"),
      ];

      final group = ItemGroup(testTitle, originalItems);

      expect(identical(group.items, originalItems), isTrue);
    });

    test("should handle complex item structures", () {
      const testTitle = "Complex Group";
      final complexItems = [
        CustomDropdownItem(
          value: {"id": 1, "name": "First"},
          label: "First Item",
          title: "Sub-title",
          onPressed: () {},
        ),
        CustomDropdownItem(
          value: {"id": 2, "name": "Second"},
          label: "Second Item",
          title: "Sub-title",
          onPressed: () {},
        ),
      ];

      final group = ItemGroup(testTitle, complexItems);

      expect(group.title, equals(testTitle));
      expect(group.items.length, equals(2));
      expect(group.items[0].label, equals("First Item"));
      expect(group.items[1].label, equals("Second Item"));
    });
  });
}
