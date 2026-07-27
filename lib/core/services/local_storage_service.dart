import "package:hive_ce/hive.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";

/// Storage Interface
///
/// Defines the contract for storage implementations.
abstract class StorageInterface {
  /// Initializes the storage implementation.
  Future<void> init({String? path});

  /// Stores a value in the specified box.
  Future<void> put(String box, String key, Object? value);

  /// Retrieves a value from the specified box.
  Future<dynamic> get(String box, String key);

  /// Deletes a value from the specified box.
  Future<void> delete(String box, String key);

  /// Clears all values from the specified box.
  Future<void> clearBox(String box);
}

/// Local Storage Service
///
/// Provides a centralized interface for storing and retrieving
/// application data using the configured storage implementation.
class LocalStorageService {
  /// Returns the singleton instance of the service.
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();
  static final LocalStorageService _instance = LocalStorageService._internal();

  StorageInterface? _storage;

  /// Set the storage implementation (for testing)
  set getStorage(StorageInterface storage) {
    _storage = storage;
  }

  /// Get the storage implementation (creates HiveStorage if not set)
  StorageInterface get getStorage {
    _storage ??= HiveStorage();
    return _storage!;
  }

  /// Initialize Hive (call this in main before using)
  Future<void> init({String? path}) async {
    await getStorage.init(path: path);
  }

  /// Store a value in a box
  Future<void> put<T>(String boxName, String key, T value) async {
    await getStorage.put(boxName, key, value);
  }

  /// Retrieve a value from a box
  Future<T?> get<T>(String boxName, String key, {T? defaultValue}) async {
    final value = await getStorage.get(boxName, key);
    return value as T? ?? defaultValue;
  }

  /// Delete a value from a box
  Future<void> delete(String boxName, String key) async {
    await getStorage.delete(boxName, key);
  }

  /// Clear all data in a box
  Future<void> clearBox(String boxName) async {
    await getStorage.clearBox(boxName);
  }
}

/// Hive Storage
///
/// Hive-based implementation of [StorageInterface] with
/// AES encryption support.
class HiveStorage implements StorageInterface {
  /// Creates a Hive storage instance.
  HiveStorage({List<int>? encryptionKey})
      : _customEncryptionKey = encryptionKey;

  final List<int>? _customEncryptionKey;

  /// Initializes Hive storage.
  @override
  Future<void> init({String? path}) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.init(path ?? "hive_data");
    }
  }

  @override
  Future<void> put(String box, String key, Object? value) async {
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
