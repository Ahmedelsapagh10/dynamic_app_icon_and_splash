import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/repositories/branding_repository.dart';
import 'core/repositories/firestore_branding_repository.dart';
import 'core/repositories/local_branding_repository.dart';
import 'core/services/dynamic_app_icon_service.dart';
import 'core/services/imagekit_upload_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localRepository = await LocalBrandingRepository.create();
  final repository = await _buildRepository(localRepository);
  final dynamicAppIconService = DynamicAppIconService();
  final imageKitUploadService = ImageKitUploadService();

  runApp(
    BrandingDemoApp(
      repository: repository,
      dynamicAppIconService: dynamicAppIconService,
      imageKitUploadService: imageKitUploadService,
    ),
  );
}

Future<BrandingRepository> _buildRepository(
  LocalBrandingRepository localRepository,
) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    return FirestoreBrandingRepository(fallbackRepository: localRepository);
  } catch (_) {
    return localRepository;
  }
}
