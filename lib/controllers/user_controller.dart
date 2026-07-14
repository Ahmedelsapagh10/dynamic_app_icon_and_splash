import 'package:flutter/material.dart';

import '../core/models/branding_config.dart';
import '../core/repositories/branding_repository.dart';

class UserController extends ChangeNotifier {
  UserController({
    required BrandingRepository repository,
    required this.userName,
  }) : _repository = repository;

  final BrandingRepository _repository;
  final String userName;

  BrandingConfig config = BrandingConfig.fallback;
  bool isLoading = true;

  Future<void> loadConfig() async {
    isLoading = true;
    notifyListeners();

    config = await _repository.fetchConfig();
    isLoading = false;
    notifyListeners();
  }
}
