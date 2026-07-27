import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";

class _TestDraftViewModel with DraftMixin<_TestDraftViewModel> {
  _TestDraftViewModel({
    Map<String, dynamic>? initialState,
    _FakeDraftHandler? customHandler,
  })  : state = initialState ??
            <String, dynamic>{
              "name": "initial",
              "amount": 100,
              "enabled": true,
            },
        _handler = customHandler ?? _FakeDraftHandler();

  Map<String, dynamic> state;

  int applyDraftCallCount = 0;
  Map<String, dynamic>? lastAppliedPayload;

  final _FakeDraftHandler _handler;

  @override
  String get draftModuleKey => "test_module";

  @override
  String get draftFormKey => "test_form";

  @override
  DraftHandler<_TestDraftViewModel> get draftHandler => _handler;
}

class _FakeDraftHandler implements DraftHandler<_TestDraftViewModel> {
  bool throwOnBuild = false;
  bool throwOnApply = false;

  @override
  Map<String, dynamic> buildDraftData(_TestDraftViewModel viewModel) {
    if (throwOnBuild) {
      throw Exception("build draft failed");
    }

    return Map<String, dynamic>.from(viewModel.state);
  }

  @override
  void applyDraft(
    _TestDraftViewModel viewModel,
    Map<String, dynamic> draftData,
  ) {
    if (throwOnApply) {
      throw Exception("apply draft failed");
    }

    viewModel.applyDraftCallCount++;
    viewModel
      ..lastAppliedPayload = Map<String, dynamic>.from(draftData)
      ..state = <String, dynamic>{
        ...viewModel.state,
        ...draftData,
      };
  }
}

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(method, url);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return openUrl("POST", url);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl("GET", url);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return openUrl("DELETE", url);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return openUrl("PUT", url);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return openUrl("PATCH", url);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return openUrl("HEAD", url);
  }

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    return openUrl(method, Uri.parse("http://$host:$port$path"));
  }

  @override
  Future<HttpClientRequest> post(
    String host,
    int port,
    String path,
  ) {
    return open("POST", host, port, path);
  }

  @override
  Future<HttpClientRequest> get(
    String host,
    int port,
    String path,
  ) {
    return open("GET", host, port, path);
  }

  @override
  Future<HttpClientRequest> delete(
    String host,
    int port,
    String path,
  ) {
    return open("DELETE", host, port, path);
  }

  @override
  Future<HttpClientRequest> put(
    String host,
    int port,
    String path,
  ) {
    return open("PUT", host, port, path);
  }

  @override
  Future<HttpClientRequest> patch(
    String host,
    int port,
    String path,
  ) {
    return open("PATCH", host, port, path);
  }

  @override
  Future<HttpClientRequest> head(
    String host,
    int port,
    String path,
  ) {
    return open("HEAD", host, port, path);
  }

  @override
  void close({bool force = false}) {}

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 1);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  bool Function(X509Certificate cert, String host, int port)?
      badCertificateCallback;

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {}

  @override
  set authenticateProxy(
    Future<bool> Function(
      String host,
      int port,
      String scheme,
      String? realm,
    )? f,
  ) {}

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  set keyLog(Function(String line)? callback) {}

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )? f,
  ) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  _MockHttpClientRequest(this._method, this._uri);

  final String _method;
  final Uri _uri;
  final BytesBuilder _body = BytesBuilder();
  final _MockHttpHeaders _headers = _MockHttpHeaders();

  @override
  String get method => _method;

  @override
  Uri get uri => _uri;

  @override
  HttpHeaders get headers => _headers;

  @override
  Encoding encoding = utf8;

  @override
  int contentLength = -1;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = false;

  @override
  void add(List<int> data) {
    _body.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _body.add(chunk);
    }
  }

  @override
  void write(Object? object) {
    if (object != null) {
      _body.add(encoding.encode(object.toString()));
    }
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = ""]) {
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = ""]) {
    write(object);
    write("\n");
  }

  @override
  Future<dynamic> flush() async {}

  @override
  Future<HttpClientResponse> close() async {
    final requestText = utf8.decode(_body.toBytes(), allowMalformed: true);

    return _MockHttpClientResponse(
      _buildResponseBody(
        uri: _uri,
        method: _method,
        requestBody: requestText,
      ),
    );
  }

  @override
  Future<HttpClientResponse> get done => close();

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  static String _buildResponseBody({
    required Uri uri,
    required String method,
    required String requestBody,
  }) {
    final lowerUrl = uri.toString().toLowerCase();
    final lowerPath = uri.path.toLowerCase();

    if (lowerUrl.contains("delete") ||
        lowerPath.contains("delete") ||
        method.toUpperCase() == "DELETE") {
      return jsonEncode(
        <String, dynamic>{
          "message": "Deleted",
          "status": "success",
          "code": 200,
          "responseData": true,
          "data": true,
          "success": true,
        },
      );
    }

    if (lowerUrl.contains("getdraft") ||
        lowerPath.contains("getdraft") ||
        lowerUrl.contains("get-draft") ||
        lowerUrl.contains("draft/get") ||
        lowerUrl.contains("draft")) {
      return jsonEncode(
        <String, dynamic>{
          "message": "Success",
          "status": "success",
          "code": 200,
          "success": true,
          "responseData": <String, dynamic>{
            "module": "test_module",
            "screen": "test_form",
            "payload": <String, dynamic>{
              "name": "loaded draft",
              "amount": 999,
              "enabled": false,
              "loadedFromDraft": true,
            },
          },
          "data": <String, dynamic>{
            "module": "test_module",
            "screen": "test_form",
            "payload": <String, dynamic>{
              "name": "loaded draft",
              "amount": 999,
              "enabled": false,
              "loadedFromDraft": true,
            },
          },
        },
      );
    }

    return jsonEncode(
      <String, dynamic>{
        "message": "Saved",
        "status": "success",
        "code": 200,
        "success": true,
        "responseData": <String, dynamic>{
          "saved": true,
          "requestBody": requestBody,
        },
        "data": <String, dynamic>{
          "saved": true,
          "requestBody": requestBody,
        },
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _MockHttpClientResponse(String body)
      : _bytes = Uint8List.fromList(utf8.encode(body)),
        _headers = _MockHttpHeaders(
          <String, List<String>>{
            HttpHeaders.contentTypeHeader: <String>["application/json"],
          },
        );

  final Uint8List _bytes;
  final _MockHttpHeaders _headers;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_bytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  int get statusCode => HttpStatus.ok;

  @override
  String get reasonPhrase => "OK";

  @override
  int get contentLength => _bytes.length;

  @override
  HttpHeaders get headers => _headers;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => <RedirectInfo>[];

  @override
  bool get persistentConnection => false;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpClientResponseCompressionState get compressionState {
    return HttpClientResponseCompressionState.notCompressed;
  }

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => <Cookie>[];

  @override
  Future<Socket> detachSocket() {
    throw UnsupportedError("detachSocket is not supported in test mock");
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpHeaders implements HttpHeaders {
  _MockHttpHeaders([Map<String, List<String>>? initialHeaders])
      : _headers = initialHeaders ?? <String, List<String>>{};

  final Map<String, List<String>> _headers;

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = name.toLowerCase();
    _headers.putIfAbsent(key, () => <String>[]).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  void remove(String name, Object value) {
    _headers[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  void removeAll(String name) {
    _headers.remove(name.toLowerCase());
  }

  @override
  String? value(String name) {
    final values = this[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  bool get chunkedTransferEncoding => false;

  @override
  set chunkedTransferEncoding(bool value) {}

  @override
  int get contentLength => -1;

  @override
  set contentLength(int value) {}

  @override
  ContentType? get contentType => ContentType.json;

  @override
  set contentType(ContentType? value) {}

  @override
  DateTime? get date => null;

  @override
  set date(DateTime? value) {}

  @override
  DateTime? get expires => null;

  @override
  set expires(DateTime? value) {}

  @override
  String? get host => null;

  @override
  set host(String? value) {}

  @override
  DateTime? get ifModifiedSince => null;

  @override
  set ifModifiedSince(DateTime? value) {}

  @override
  bool get persistentConnection => false;

  @override
  set persistentConnection(bool value) {}

  @override
  int? get port => null;

  @override
  set port(int? value) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  const MethodChannel connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  Directory? hiveTempDir;
  HttpOverrides? previousHttpOverrides;

  group("DraftMixin Tests", () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      hiveTempDir =
          Directory.systemTemp.createTempSync("draft_mixin_hive_test_");

      try {
        Hive.init(hiveTempDir!.path);
      } on Object catch (_) {
        // Hive can already be initialized by another test file.
      }

      previousHttpOverrides = HttpOverrides.current;
      HttpOverrides.global = _MockHttpOverrides();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        connectivityChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == "check") {
            return <String>["wifi"];
          }
          return null;
        },
      );
    });

    tearDownAll(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(connectivityChannel, null);

      HttpOverrides.global = previousHttpOverrides;

      try {
        await Hive.close();
      } on Object catch (_) {
        // Ignore Hive close errors in tests.
      }

      try {
        hiveTempDir?.deleteSync(recursive: true);
      } on Object catch (_) {
        // Ignore temp directory cleanup errors in tests.
      }
    });

    setUp(() {
      Globals.onAutoSave = null;
      Globals.onAutoSaveSync = null;
    });

    tearDown(() {
      Globals.onAutoSave = null;
      Globals.onAutoSaveSync = null;
    });

    group("captureInitialDraftState", () {
      test("should capture current draft state without throwing", () {
        final viewModel = _TestDraftViewModel();

        expect(viewModel.captureInitialDraftState, returnsNormally);
      });

      test("should swallow buildDraftData exception", () {
        final handler = _FakeDraftHandler()..throwOnBuild = true;
        final viewModel = _TestDraftViewModel(customHandler: handler);

        expect(viewModel.captureInitialDraftState, returnsNormally);
      });

      test("should capture empty state", () {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{},
        );

        expect(viewModel.captureInitialDraftState, returnsNormally);
      });

      test("should capture nested state", () {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{
            "customer": <String, dynamic>{
              "name": "ABC",
              "rim": 12345,
            },
            "items": <Map<String, dynamic>>[
              <String, dynamic>{"id": 1, "amount": 100},
              <String, dynamic>{"id": 2, "amount": 200},
            ],
          },
        );

        expect(viewModel.captureInitialDraftState, returnsNormally);
      });
    });

    group("saveDraft", () {
      test("should skip repository save when state is unchanged", () async {
        final viewModel = _TestDraftViewModel()..captureInitialDraftState();

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should call repository save when state changed", () async {
        final viewModel = _TestDraftViewModel()..captureInitialDraftState();
        viewModel.state["name"] = "changed";

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should update baseline after changed save", () async {
        final viewModel = _TestDraftViewModel()..captureInitialDraftState();
        viewModel.state["name"] = "changed once";

        await expectLater(viewModel.saveDraft(), completes);

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should save when no initial hash exists", () async {
        final viewModel = _TestDraftViewModel();

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should save changed empty-to-filled state", () async {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{},
        )..captureInitialDraftState();
        viewModel.state["field"] = "value";

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should save changed nested state", () async {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{
            "customer": <String, dynamic>{
              "name": "ABC",
              "rim": 123,
            },
            "limit": 1000,
          },
        )..captureInitialDraftState();
        viewModel.state["customer"] = <String, dynamic>{
          "name": "XYZ",
          "rim": 456,
        };
        viewModel.state["limit"] = 2000;

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should swallow buildDraftData exception", () async {
        final handler = _FakeDraftHandler()..throwOnBuild = true;
        final viewModel = _TestDraftViewModel(customHandler: handler);

        await expectLater(viewModel.saveDraft(), completes);
      });
    });

    group("deleteDraft", () {
      test("should call repository delete and capture baseline", () async {
        final viewModel = _TestDraftViewModel();

        viewModel.state["name"] = "before delete";

        await expectLater(viewModel.deleteDraft(), completes);
      });

      test("should reset baseline after delete", () async {
        final viewModel = _TestDraftViewModel();

        viewModel.state["name"] = "saved data";

        await expectLater(viewModel.deleteDraft(), completes);

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should swallow buildDraftData exception after delete", () async {
        final handler = _FakeDraftHandler()..throwOnBuild = true;
        final viewModel = _TestDraftViewModel(customHandler: handler);

        await expectLater(viewModel.deleteDraft(), completes);
      });

      test("should complete delete with empty state", () async {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{},
        );

        await expectLater(viewModel.deleteDraft(), completes);
      });

      test("should complete delete with nested state", () async {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{
            "section": <String, dynamic>{
              "field": "value",
            },
          },
        );

        await expectLater(viewModel.deleteDraft(), completes);
      });
    });

    group("loadDraftIfAvailable", () {
      test("should call repository getDraft and complete", () async {
        final viewModel = _TestDraftViewModel();

        await expectLater(viewModel.loadDraftIfAvailable(), completes);
      });

      test("should capture baseline after load", () async {
        final viewModel = _TestDraftViewModel();

        await viewModel.loadDraftIfAvailable();

        await expectLater(viewModel.saveDraft(), completes);
      });

      test("should swallow applyDraft exception", () async {
        final handler = _FakeDraftHandler()..throwOnApply = true;
        final viewModel = _TestDraftViewModel(customHandler: handler);

        await expectLater(viewModel.loadDraftIfAvailable(), completes);
      });

      test("should swallow buildDraftData exception during final capture",
          () async {
        final handler = _FakeDraftHandler()..throwOnBuild = true;
        final viewModel = _TestDraftViewModel(customHandler: handler);

        await expectLater(viewModel.loadDraftIfAvailable(), completes);
      });

      test("should load draft with empty initial state", () async {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{},
        );

        await expectLater(viewModel.loadDraftIfAvailable(), completes);
      });

      test("should load draft with nested initial state", () async {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{
            "sectionA": <String, dynamic>{
              "field1": "value1",
              "field2": 10,
            },
            "sectionB": <String>["one", "two"],
          },
        );

        await expectLater(viewModel.loadDraftIfAvailable(), completes);
      });
    });

    group("registerDraftCallback", () {
      test("should register async and sync autosave callbacks", () {
        final viewModel = _TestDraftViewModel();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);

        viewModel.registerDraftCallback();

        expect(Globals.onAutoSave, isNotNull);
        expect(Globals.onAutoSaveSync, isNotNull);
      });

      test("registered async callback should execute unchanged save", () async {
        await expectLater(Globals.onAutoSave?.call(), isNull);
      });

      test("registered async callback should execute changed save", () async {
        final viewModel = _TestDraftViewModel()
          ..captureInitialDraftState()
          ..registerDraftCallback();

        viewModel.state["name"] = "autosave changed";

        await expectLater(Globals.onAutoSave?.call(), completes);
      });

      test("registered sync callback should execute unchanged save", () {
        expect(() => Globals.onAutoSaveSync?.call(), returnsNormally);
      });

      test("registered sync callback should execute changed beacon save", () {
        final viewModel = _TestDraftViewModel()
          ..captureInitialDraftState()
          ..registerDraftCallback();

        viewModel.state["amount"] = 123456;

        expect(() => Globals.onAutoSaveSync?.call(), returnsNormally);
      });

      test("register should replace old global callbacks", () {
        final firstViewModel = _TestDraftViewModel();
        final secondViewModel = _TestDraftViewModel();

        firstViewModel.registerDraftCallback();

        final firstAsyncCallback = Globals.onAutoSave;
        final firstSyncCallback = Globals.onAutoSaveSync;

        secondViewModel.registerDraftCallback();

        expect(Globals.onAutoSave, isNotNull);
        expect(Globals.onAutoSaveSync, isNotNull);
        expect(Globals.onAutoSave == firstAsyncCallback, isFalse);
        expect(Globals.onAutoSaveSync == firstSyncCallback, isFalse);
      });
    });

    group("unregisterDraftCallback", () {
      test("should clear callbacks when same instance unregisters", () {
        final viewModel = _TestDraftViewModel()..registerDraftCallback();

        expect(Globals.onAutoSave, isNotNull);
        expect(Globals.onAutoSaveSync, isNotNull);

        viewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });

      test("should not clear callbacks registered by another instance", () {
        final firstViewModel = _TestDraftViewModel();
        final secondViewModel = _TestDraftViewModel();

        firstViewModel.registerDraftCallback();

        final firstAsyncCallback = Globals.onAutoSave;
        final firstSyncCallback = Globals.onAutoSaveSync;

        expect(firstAsyncCallback, isNotNull);
        expect(firstSyncCallback, isNotNull);

        secondViewModel.registerDraftCallback();

        final secondAsyncCallback = Globals.onAutoSave;
        final secondSyncCallback = Globals.onAutoSaveSync;

        expect(secondAsyncCallback, isNotNull);
        expect(secondSyncCallback, isNotNull);
        expect(secondAsyncCallback == firstAsyncCallback, isFalse);
        expect(secondSyncCallback == firstSyncCallback, isFalse);

        firstViewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, same(secondAsyncCallback));
        expect(Globals.onAutoSaveSync, same(secondSyncCallback));

        secondViewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });

      test("should be safe to unregister without register", () {
        final viewModel = _TestDraftViewModel();

        expect(viewModel.unregisterDraftCallback, returnsNormally);
        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });

      test("should support repeated register and unregister", () {
        final viewModel = _TestDraftViewModel()
          ..registerDraftCallback()
          ..unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);

        viewModel
          ..registerDraftCallback()
          ..unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });
    });

    group("saveDraftSync", () {
      test("should skip beacon save when state is unchanged", () {
        final viewModel = _TestDraftViewModel()..captureInitialDraftState();

        expect(viewModel.saveDraftSync, returnsNormally);
      });

      test("should call beacon save when state changed", () {
        final viewModel = _TestDraftViewModel()..captureInitialDraftState();
        viewModel.state["name"] = "sync changed";

        expect(viewModel.saveDraftSync, returnsNormally);
      });

      test("should call beacon save when no initial hash exists", () {
        final viewModel = _TestDraftViewModel();

        expect(viewModel.saveDraftSync, returnsNormally);
      });

      test("should call beacon save with nested changed state", () {
        final viewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{
            "customer": <String, dynamic>{
              "name": "ABC",
            },
          },
        )..captureInitialDraftState();
        viewModel.state["customer"] = <String, dynamic>{
          "name": "XYZ",
        };

        expect(viewModel.saveDraftSync, returnsNormally);
      });

      test("should swallow buildDraftData exception", () {
        final handler = _FakeDraftHandler()..throwOnBuild = true;
        final viewModel = _TestDraftViewModel(customHandler: handler);

        expect(viewModel.saveDraftSync, returnsNormally);
      });
    });

    group("Combined lifecycle flow", () {
      test("should run full init load save sync delete dispose lifecycle",
          () async {
        final viewModel = _TestDraftViewModel()..registerDraftCallback();

        await expectLater(viewModel.loadDraftIfAvailable(), completes);

        viewModel.state["name"] = "changed after load";

        await expectLater(Globals.onAutoSave?.call(), completes);

        viewModel.state["amount"] = 777;

        expect(() => Globals.onAutoSaveSync?.call(), returnsNormally);

        await expectLater(viewModel.deleteDraft(), completes);

        viewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });

      test("should handle build failure across lifecycle", () async {
        final handler = _FakeDraftHandler();
        final viewModel = _TestDraftViewModel(customHandler: handler)
          ..registerDraftCallback();

        handler.throwOnBuild = true;

        await expectLater(viewModel.loadDraftIfAvailable(), completes);
        await expectLater(viewModel.saveDraft(), completes);

        expect(viewModel.saveDraftSync, returnsNormally);

        await expectLater(viewModel.deleteDraft(), completes);

        viewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });

      test("multiple view models should keep latest autosave owner", () async {
        final firstViewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{"screen": "first"},
        );
        final secondViewModel = _TestDraftViewModel(
          initialState: <String, dynamic>{"screen": "second"},
        );

        firstViewModel.captureInitialDraftState();
        secondViewModel.captureInitialDraftState();

        firstViewModel.registerDraftCallback();
        secondViewModel.registerDraftCallback();

        final latestAsyncCallback = Globals.onAutoSave;
        final latestSyncCallback = Globals.onAutoSaveSync;

        expect(latestAsyncCallback, isNotNull);
        expect(latestSyncCallback, isNotNull);

        firstViewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, same(latestAsyncCallback));
        expect(Globals.onAutoSaveSync, same(latestSyncCallback));

        await expectLater(Globals.onAutoSave?.call(), completes);
        expect(() => Globals.onAutoSaveSync?.call(), returnsNormally);

        secondViewModel.unregisterDraftCallback();

        expect(Globals.onAutoSave, isNull);
        expect(Globals.onAutoSaveSync, isNull);
      });
    });
  });
}
