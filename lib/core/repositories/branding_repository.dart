import '../models/branding_config.dart';

abstract class BrandingRepository {
  Future<BrandingConfig> fetchConfig();

  Future<void> saveConfig(BrandingConfig config);
}
