class BrandingConfig {
  const BrandingConfig({
    required this.appIconKey,
    required this.iconVersion,
    required this.useDefaultSplash,
    required this.splashImageUrl,
    required this.splashVersion,
    required this.updatedAt,
  });

  static const String defaultIconKey = 'default';
  static const List<String> supportedIconKeys = [
    defaultIconKey,
    'ramadan',
    'white_friday',
  ];

  static const Map<String, String> iconLabels = {
    'default': 'Default',
    'ramadan': 'Ramadan',
    'white_friday': 'White Friday',
  };

  static const BrandingConfig fallback = BrandingConfig(
    appIconKey: defaultIconKey,
    iconVersion: '1',
    useDefaultSplash: true,
    splashImageUrl: '',
    splashVersion: '1',
    updatedAt: '',
  );

  final String appIconKey;
  final String iconVersion;
  final bool useDefaultSplash;
  final String splashImageUrl;
  final String splashVersion;
  final String updatedAt;

  bool get hasRemoteSplash => !useDefaultSplash && splashImageUrl.isNotEmpty;
  bool get hasUpdatedAt => updatedAt.trim().isNotEmpty;

  String get previewAssetPath => 'assets/app_icon_previews/$appIconKey.webp';
  String get iconLabel => iconLabels[appIconKey] ?? appIconKey;
  String get splashModeLabel =>
      useDefaultSplash ? 'Default splash' : 'Remote splash';
  String get campaignTitle =>
      appIconKey == defaultIconKey ? 'Everyday Look' : iconLabel;
  String get shortUpdatedAt => _formatUpdatedAt(updatedAt);

  String get resolvedSplashUrl {
    if (!hasRemoteSplash) return '';

    final uri = Uri.tryParse(splashImageUrl);
    if (uri == null) return splashImageUrl;

    final query = Map<String, String>.from(uri.queryParameters);
    query['splash_version'] = splashVersion;
    return uri.replace(queryParameters: query).toString();
  }

  BrandingConfig copyWith({
    String? appIconKey,
    String? iconVersion,
    bool? useDefaultSplash,
    String? splashImageUrl,
    String? splashVersion,
    String? updatedAt,
  }) {
    return BrandingConfig(
      appIconKey: appIconKey ?? this.appIconKey,
      iconVersion: iconVersion ?? this.iconVersion,
      useDefaultSplash: useDefaultSplash ?? this.useDefaultSplash,
      splashImageUrl: splashImageUrl ?? this.splashImageUrl,
      splashVersion: splashVersion ?? this.splashVersion,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'app_icon_key': appIconKey,
      'icon_version': iconVersion,
      'use_default_splash': useDefaultSplash,
      'splash_image_url': splashImageUrl,
      'splash_version': splashVersion,
      'updated_at': updatedAt,
    };
  }

  factory BrandingConfig.fromMap(Map<String, dynamic>? data) {
    if (data == null) return fallback;

    final iconKey = normalizeIconKey(data['app_icon_key']?.toString());
    final iconVersion = normalizeVersion(data['icon_version']?.toString());
    final useDefaultSplash = data['use_default_splash'] == true;
    final splashUrl = data['splash_image_url']?.toString().trim() ?? '';
    final splashVersion = normalizeVersion(data['splash_version']?.toString());
    final updatedAt = data['updated_at']?.toString().trim() ?? '';

    return BrandingConfig(
      appIconKey: iconKey,
      iconVersion: iconVersion,
      useDefaultSplash: useDefaultSplash,
      splashImageUrl: splashUrl,
      splashVersion: splashVersion,
      updatedAt: updatedAt,
    );
  }

  static String normalizeIconKey(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (supportedIconKeys.contains(normalized)) {
      return normalized;
    }
    return defaultIconKey;
  }

  static String normalizeVersion(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    return parsed == null || parsed < 1 ? '1' : parsed.toString();
  }

  static String nextVersion(String currentVersion) {
    final parsed = int.tryParse(currentVersion.trim());
    return ((parsed ?? 0) + 1).toString();
  }

  static String _formatUpdatedAt(String value) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) return 'Not saved yet';

    final local = parsed.toLocal();
    final month = _monthName(local.month);
    final minutes = local.minute.toString().padLeft(2, '0');
    return '${local.day} $month ${local.year} • ${local.hour}:$minutes';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
