import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

class NativeApiConfig {
  static String? get apiKey => _readString(_apiKeyFnName);
  static String? get baseUrl => _readString(_baseUrlFnName);

  static const String _apiKeyFnName = 'apiconfig_api_key';
  static const String _baseUrlFnName = 'apiconfig_base_url';

  static DynamicLibrary? _lib;

  static DynamicLibrary? _load() {
    if (_lib != null) return _lib;

    try {
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libapiconfig.so');
      } else if (Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else {
        return null;
      }
      return _lib;
    } catch (_) {
      return null;
    }
  }

  static String? _readString(String symbolName) {
    final lib = _load();
    if (lib == null) return null;
    try {
      final fn = lib
          .lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
            symbolName,
          );
      final ptr = fn();
      final value = ptr.toDartString();
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return trimmed;
    } catch (_) {
      return null;
    }
  }
}
