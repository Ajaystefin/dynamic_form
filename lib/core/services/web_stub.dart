class MockStorage {
  final Map<String, String> _storage = {};
  String? getItem(String key) => _storage[key];
  void setItem(String key, String value) => _storage[key] = value;
}

class MockWindow {
  final sessionStorage = MockStorage();
}

final window = MockWindow();
