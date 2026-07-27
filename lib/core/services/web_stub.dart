/// In-memory mock implementation of browser storage.
class MockStorage {
  final Map<String, String> _storage = {};

  /// Returns the value associated with the specified key.
  String? getItem(String key) => _storage[key];

  /// Stores a value for the specified key.
  void setItem(String key, String value) => _storage[key] = value;
}

/// Mock implementation of the browser window object.
class MockWindow {
  /// Mock session storage instance.
  final sessionStorage = MockStorage();
}

/// Global mock window instance.
final window = MockWindow();
