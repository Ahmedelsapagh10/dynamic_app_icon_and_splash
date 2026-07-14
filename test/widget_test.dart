import 'package:flutter_test/flutter_test.dart';

import 'package:dynamic_app_icon_and_splash/core/models/branding_config.dart';

void main() {
  test('normalizes unknown icon to default', () {
    final config = BrandingConfig.fromMap(const {
      'app_icon_key': 'unknown',
      'icon_version': '7',
      'use_default_splash': false,
      'splash_image_url': 'https://example.com/splash.png',
      'splash_version': '3',
    });

    expect(config.appIconKey, BrandingConfig.defaultIconKey);
    expect(config.iconVersion, '7');
    expect(config.splashVersion, '3');
  });
}
