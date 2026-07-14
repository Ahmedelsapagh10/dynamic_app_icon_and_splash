import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/models/branding_config.dart';
import '../core/repositories/branding_repository.dart';
import '../core/services/dynamic_app_icon_service.dart';
import '../core/services/imagekit_upload_service.dart';

class AdminController extends ChangeNotifier {
  AdminController({
    required BrandingRepository repository,
    required DynamicAppIconService dynamicAppIconService,
    required ImageKitUploadService imageKitUploadService,
    required this.adminName,
    ImagePicker? imagePicker,
  }) : _repository = repository,
       _dynamicAppIconService = dynamicAppIconService,
       _imageKitUploadService = imageKitUploadService,
       _imagePicker = imagePicker ?? ImagePicker();

  final BrandingRepository _repository;
  final DynamicAppIconService _dynamicAppIconService;
  final ImageKitUploadService _imageKitUploadService;
  final ImagePicker _imagePicker;
  final String adminName;

  final TextEditingController splashUrlController = TextEditingController();

  BrandingConfig config = BrandingConfig.fallback;
  String selectedIcon = BrandingConfig.defaultIconKey;
  bool useDefaultSplash = true;
  bool isBusy = true;
  bool isUploading = false;
  String? message;
  String? error;
  XFile? selectedSplashFile;

  String get previewUrl => splashUrlController.text.trim();
  String get selectedSplashFileName =>
      selectedSplashFile?.name ?? 'No image selected';
  bool get hasSelectedSplashFile => selectedSplashFile != null;

  Future<void> loadConfig() async {
    isBusy = true;
    message = null;
    error = null;
    notifyListeners();

    final loadedConfig = await _repository.fetchConfig();
    _applyDraft(loadedConfig);
  }

  void updateSelectedIcon(String value) {
    selectedIcon = value;
    notifyListeners();
  }

  void updateSplashMode(bool value) {
    useDefaultSplash = value;
    notifyListeners();
  }

  Future<void> pickSplashImage() async {
    try {
      message = null;
      error = null;
      notifyListeners();

      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      selectedSplashFile = file;
      useDefaultSplash = false;
      message = 'Image selected. Click Save changes to upload and save.';
      notifyListeners();
    } catch (currentError) {
      error = currentError.toString();
      notifyListeners();
    }
  }

  Future<bool> saveConfig() async {
    try {
      isBusy = true;
      isUploading = selectedSplashFile != null;
      message = null;
      error = null;
      notifyListeners();

      if (!useDefaultSplash && selectedSplashFile != null) {
        final uploadedUrl = await _imageKitUploadService.uploadSplashImage(
          selectedSplashFile!,
        );
        splashUrlController.text = uploadedUrl;
      }

      final splashUrl = splashUrlController.text.trim();
      if (!_isValidSplashInput(splashUrl)) {
        error = 'Enter a valid splash URL before saving custom mode.';
        isBusy = false;
        isUploading = false;
        notifyListeners();
        return false;
      }

      final nextConfig = config.copyWith(
        appIconKey: selectedIcon,
        iconVersion: BrandingConfig.nextVersion(config.iconVersion),
        useDefaultSplash: useDefaultSplash,
        splashImageUrl: useDefaultSplash ? '' : splashUrl,
        splashVersion: useDefaultSplash
            ? config.splashVersion
            : BrandingConfig.nextVersion(config.splashVersion),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _repository.saveConfig(nextConfig);
      await _dynamicAppIconService.applyIcon(nextConfig.appIconKey);

      config = nextConfig;
      selectedSplashFile = null;
      message = 'Branding config saved to Firebase successfully.';
      isBusy = false;
      isUploading = false;
      notifyListeners();
      return true;
    } catch (currentError) {
      error = currentError.toString();
      isBusy = false;
      isUploading = false;
      notifyListeners();
      return false;
    }
  }

  void disposeController() {
    splashUrlController.dispose();
  }

  void _applyDraft(BrandingConfig loadedConfig) {
    config = loadedConfig;
    selectedIcon = loadedConfig.appIconKey;
    useDefaultSplash = loadedConfig.useDefaultSplash;
    splashUrlController.text = loadedConfig.splashImageUrl;
    selectedSplashFile = null;
    isBusy = false;
    notifyListeners();
  }

  bool _isValidSplashInput(String splashUrl) {
    if (useDefaultSplash) return true;
    final uri = Uri.tryParse(splashUrl);
    return uri != null && uri.isAbsolute;
  }
}
