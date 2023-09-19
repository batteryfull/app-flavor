import 'package:package_info/package_info.dart';

import '../app_flavor.dart';

enum AppFlavor {
  development,
  staging,
  production,
}

extension AppFlavorExt on AppFlavor {
  bool get isDevelopment => this == AppFlavor.development;
  bool get isStaging => this == AppFlavor.staging;
  bool get isProduction => this == AppFlavor.production;
}

class AppFlavorUtils {
  static AppFlavor _appFlavor = AppFlavor.development;
  static Map<AppFlavor, Map<String, dynamic>>? _variables;
  static AppFlavor get appFlavor => _appFlavor;

  static String _packageName = "";
  static String get packageName => _packageName;

  /// Initialize flavor must call first
  static Future<AppFlavor> initializeFlavor() {
    return getFlavor();
  }

  /// Initialize flavor app data, must call as soon as possible after calling [initializeFlavor]
  static Future<void> initializeVariables({
    required Future<Map<String, dynamic>> Function(AppFlavor) onVariable,
  }) async {
    for (final flavor in AppFlavor.values) {
      final variable = await onVariable.call(flavor);
      _variables?.putIfAbsent(flavor, () => variable);
    }
  }

  /// Get variable by flavor
  static V? getVariableByFlavor<V>(
    AppFlavor flavor,
    String key, {
    V? defaultValue,
  }) {
    final value = _variables?[flavor]?[key];
    if (value == null) return value ?? defaultValue;
    return value is V? ? value : null;
  }

  /// Get current flavor variable
  static V? getVariable<V>(String key, {V? defaultValue}) {
    return getVariableByFlavor(
      _appFlavor,
      key,
      defaultValue: defaultValue,
    );
  }

  /// Get current flavor variable by key enum
  static V? getVariableByEnum<V>(Keys key, {V? defaultValue}) {
    return getVariableByFlavor(
      _appFlavor,
      key.name,
      defaultValue: defaultValue,
    );
  }

  static V? getApiUrl<V>({V? defaultValue}) {
    return getVariableByEnum<V>(
      Keys.apiUrl,
      defaultValue: defaultValue,
    );
  }

  static V? getAppTitle<V>({V? defaultValue}) {
    return getVariableByEnum<V>(
      Keys.appTitle,
      defaultValue: defaultValue,
    );
  }

  static V? getImageApiUrl<V>({V? defaultValue}) {
    return getVariableByEnum<V>(
      Keys.imageApiUrl,
      defaultValue: defaultValue,
    );
  }

  static V? getGoogleApiKey<V>({V? defaultValue}) {
    return getVariableByEnum<V>(
      Keys.googleApiKey,
      defaultValue: defaultValue,
    );
  }

  /// Retrieve flavor from scheme (iOS) or flavor (android)
  static Future<AppFlavor> getFlavor() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageName = packageInfo.packageName;
    if (_packageName.contains(".dev")) {
      _appFlavor = AppFlavor.development;
    } else if (packageInfo.packageName.contains(".staging")) {
      _appFlavor = AppFlavor.staging;
    } else {
      _appFlavor = AppFlavor.production;
    }
    return _appFlavor;
  }
}
