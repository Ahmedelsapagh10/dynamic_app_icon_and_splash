import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';

import '../models/branding_config.dart';

class DynamicAppIconService {
  static const MethodChannel _androidChannel = MethodChannel(
    'dynamic_app_icon_and_splash/dynamic_app_icon',
  );

  Future<void> applyIcon(String iconKey) async {
    final normalizedIconKey = BrandingConfig.normalizeIconKey(iconKey);

    if (Platform.isAndroid) {
      await _androidChannel.invokeMethod<void>('setIcon', <String, dynamic>{
        'iconName': normalizedIconKey,
      });
      return;
    }

    if (Platform.isIOS) {
      final supportsAlternateIcons =
          await FlutterDynamicIconPlus.supportsAlternateIcons;
      if (!supportsAlternateIcons) return;

      await FlutterDynamicIconPlus.setAlternateIconName(
        iconName: normalizedIconKey == BrandingConfig.defaultIconKey
            ? null
            : normalizedIconKey,
      );
    }
  }

  Future<String> getCurrentIcon() async {
    if (Platform.isAndroid) {
      final value = await _androidChannel.invokeMethod<String>(
        'getCurrentIcon',
      );
      return BrandingConfig.normalizeIconKey(value);
    }

    if (Platform.isIOS) {
      final value = await FlutterDynamicIconPlus.alternateIconName;
      return BrandingConfig.normalizeIconKey(
        value ?? BrandingConfig.defaultIconKey,
      );
    }

    return BrandingConfig.defaultIconKey;
  }
}
