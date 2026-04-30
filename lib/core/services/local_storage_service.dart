import "package:hive_ce/hive.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";

abstract class StorageInterface {
  Future<void> init({String? path});
  Future<void> put(String box, String key, dynamic value);
  Future<dynamic> get(String box, String key);
  Future<void> delete(String box, String key);
  Future<void> clearBox(String box);
}

class LocalStorageService {
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();
  static final LocalStorageService _instance = LocalStorageService._internal();

  StorageInterface? _storage;

  /// Set the storage implementation (for testing)
  void setStorage(StorageInterface storage) {
    _storage = storage;
  }

  /// Get the storage implementation (creates HiveStorage if not set)
  StorageInterface get _getStorage {
    _storage ??= HiveStorage();
    return _storage!;
  }

  /// Initialize Hive (call this in main before using)
  Future<void> init({String? path}) async {
    await _getStorage.init(path: path);
  }

  /// Store a value in a box
  Future<void> put<T>(String boxName, String key, T value) async {
    await _getStorage.put(boxName, key, value);
  }

  /// Retrieve a value from a box
  Future<T?> get<T>(String boxName, String key, {T? defaultValue}) async {
    final value = await _getStorage.get(boxName, key);
    return value as T? ?? defaultValue;
  }

  /// Delete a value from a box
  Future<void> delete(String boxName, String key) async {
    await _getStorage.delete(boxName, key);
  }

  /// Clear all data in a box
  Future<void> clearBox(String boxName) async {
    await _getStorage.clearBox(boxName);
  }
}

/// Concrete implementation using Hive
class HiveStorage implements StorageInterface {
  HiveStorage({List<int>? encryptionKey})
      : _customEncryptionKey = encryptionKey;
  final List<int>? _customEncryptionKey;

  @override
  Future<void> init({String? path}) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.init(path ?? "hive_data");
    }
  }

  @override
  Future<void> put(String box, String key, dynamic value) async {
    final hiveBox = await _open(box);
    await hiveBox.put(key, value);
  }

  @override
  Future<dynamic> get(String box, String key) async {
    final hiveBox = await _open(box);
    return hiveBox.get(key);
  }

  @override
  Future<void> delete(String box, String key) async {
    final hiveBox = await _open(box);
    await hiveBox.delete(key);
  }

  @override
  Future<void> clearBox(String box) async {
    final hiveBox = await _open(box);
    await hiveBox.clear();
  }

  /// Open a box (creates if not exists)
  Future<Box> _open(String boxName) async {
    final List<int> encryptionKey = _customEncryptionKey ??
        await EncryptionHelper.generateKeyFromDeviceId();
    return Hive.openBox(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
}
