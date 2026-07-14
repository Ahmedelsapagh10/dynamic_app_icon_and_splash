import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/branding_config.dart';
import 'branding_repository.dart';

class FirestoreBrandingRepository implements BrandingRepository {
  FirestoreBrandingRepository({
    FirebaseFirestore? firestore,
    required BrandingRepository fallbackRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _fallbackRepository = fallbackRepository;

  final FirebaseFirestore _firestore;
  final BrandingRepository _fallbackRepository;

  DocumentReference<Map<String, dynamic>> get _appIconDoc =>
      _firestore.collection('setting-config').doc('app_icon');

  DocumentReference<Map<String, dynamic>> get _splashDoc =>
      _firestore.collection('setting-config').doc('splash');

  @override
  Future<BrandingConfig> fetchConfig() async {
    try {
      await _seedIfNeeded();

      final appIconSnapshot = await _appIconDoc.get();
      final splashSnapshot = await _splashDoc.get();

      final appIconData = appIconSnapshot.data() ?? const <String, dynamic>{};
      final splashData = splashSnapshot.data() ?? const <String, dynamic>{};

      final config = BrandingConfig.fromMap({
        'app_icon_key': appIconData['active_icon'],
        'icon_version': appIconData['icon_version'],
        'use_default_splash': splashData['use_default_splash'],
        'splash_image_url': splashData['image_url'],
        'splash_version': splashData['image_version'],
        'updated_at': _resolveUpdatedAt(appIconData, splashData),
      });

      await _fallbackRepository.saveConfig(config);
      return config;
    } catch (_) {
      return _fallbackRepository.fetchConfig();
    }
  }

  @override
  Future<void> saveConfig(BrandingConfig config) async {
    try {
      await _appIconDoc.set({
        'enabled': true,
        'active_icon': config.appIconKey,
        'icon_version': config.iconVersion,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _splashDoc.set({
        'use_default_splash': config.useDefaultSplash,
        'image_url': config.useDefaultSplash ? '' : config.splashImageUrl,
        'image_version': config.splashVersion,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _fallbackRepository.saveConfig(config);
    } catch (_) {
      await _fallbackRepository.saveConfig(config);
      rethrow;
    }
  }

  Future<void> _seedIfNeeded() async {
    final appIconSnapshot = await _appIconDoc.get();
    if (!appIconSnapshot.exists) {
      await _appIconDoc.set({
        'enabled': true,
        'active_icon': BrandingConfig.defaultIconKey,
        'icon_version': '1',
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    final splashSnapshot = await _splashDoc.get();
    if (!splashSnapshot.exists) {
      await _splashDoc.set({
        'use_default_splash': true,
        'image_url': '',
        'image_version': '1',
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  String _resolveUpdatedAt(
    Map<String, dynamic> appIconData,
    Map<String, dynamic> splashData,
  ) {
    final appIconUpdatedAt = appIconData['updated_at'];
    if (appIconUpdatedAt is Timestamp) {
      return appIconUpdatedAt.toDate().toIso8601String();
    }

    final splashUpdatedAt = splashData['updated_at'];
    if (splashUpdatedAt is Timestamp) {
      return splashUpdatedAt.toDate().toIso8601String();
    }

    return '';
  }
}
