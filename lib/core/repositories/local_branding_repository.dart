import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/branding_config.dart';
import 'branding_repository.dart';

class LocalBrandingRepository implements BrandingRepository {
  LocalBrandingRepository._(this._preferences);

  static const String _storageKey = 'branding_demo_config';

  final SharedPreferences _preferences;

  static Future<LocalBrandingRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalBrandingRepository._(preferences);
  }

  @override
  Future<BrandingConfig> fetchConfig() async {
    final rawValue = _preferences.getString(_storageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return BrandingConfig.fallback;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return BrandingConfig.fallback;
      }
      return BrandingConfig.fromMap(decoded);
    } catch (_) {
      return BrandingConfig.fallback;
    }
  }

  @override
  Future<void> saveConfig(BrandingConfig config) async {
    await _preferences.setString(_storageKey, jsonEncode(config.toMap()));
  }
}
