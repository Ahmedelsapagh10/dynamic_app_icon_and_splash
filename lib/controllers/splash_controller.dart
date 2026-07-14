import 'dart:async';

import 'package:flutter/material.dart';

import '../core/models/branding_config.dart';
import '../core/repositories/branding_repository.dart';
import '../core/services/dynamic_app_icon_service.dart';

class SplashController extends ChangeNotifier {
  SplashController({
    required BrandingRepository repository,
    required DynamicAppIconService dynamicAppIconService,
  }) : _repository = repository,
       _dynamicAppIconService = dynamicAppIconService;

  final BrandingRepository _repository;
  final DynamicAppIconService _dynamicAppIconService;

  BrandingConfig config = BrandingConfig.fallback;

  Future<void> initialize() async {
    config = await _repository.fetchConfig();

    try {
      await _dynamicAppIconService.applyIcon(config.appIconKey);
    } catch (_) {
      // Best effort only for the demo.
    }

    notifyListeners();
  }

  Future<void> waitBeforeContinue() async {
    await Future<void>.delayed(const Duration(seconds: 2));
  }
}
