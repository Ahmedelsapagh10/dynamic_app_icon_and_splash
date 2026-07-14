import 'package:flutter/material.dart';

import 'core/repositories/branding_repository.dart';
import 'core/services/dynamic_app_icon_service.dart';
import 'core/services/imagekit_upload_service.dart';
import 'core/theme/app_theme.dart';
import 'views/auth/role_selection_view.dart';
import 'views/splash/branding_splash_view.dart';

class BrandingDemoApp extends StatelessWidget {
  const BrandingDemoApp({
    super.key,
    required this.repository,
    required this.dynamicAppIconService,
    required this.imageKitUploadService,
  });

  final BrandingRepository repository;
  final DynamicAppIconService dynamicAppIconService;
  final ImageKitUploadService imageKitUploadService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Branding Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: BrandingSplashView(
        repository: repository,
        dynamicAppIconService: dynamicAppIconService,
        onFinished: (context) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => RoleSelectionView(
                repository: repository,
                dynamicAppIconService: dynamicAppIconService,
                imageKitUploadService: imageKitUploadService,
              ),
            ),
          );
        },
      ),
    );
  }
}
