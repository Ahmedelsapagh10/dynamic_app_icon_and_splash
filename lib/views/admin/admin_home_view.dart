import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../controllers/admin_controller.dart';
import '../../core/models/branding_config.dart';
import '../../core/repositories/branding_repository.dart';
import '../../core/services/dynamic_app_icon_service.dart';
import '../../core/services/imagekit_upload_service.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({
    super.key,
    required this.repository,
    required this.dynamicAppIconService,
    required this.imageKitUploadService,
    required this.adminName,
  });

  final BrandingRepository repository;
  final DynamicAppIconService dynamicAppIconService;
  final ImageKitUploadService imageKitUploadService;
  final String adminName;

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  late final AdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminController(
      repository: widget.repository,
      dynamicAppIconService: widget.dynamicAppIconService,
      imageKitUploadService: widget.imageKitUploadService,
      adminName: widget.adminName,
    );
    unawaited(_controller.loadConfig());
  }

  @override
  void dispose() {
    _controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Console'),
            actions: [
              IconButton(
                onPressed: _controller.isBusy ? null : _controller.loadConfig,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _controller.isBusy
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _DashboardHero(
                        title: 'Welcome, ${_controller.adminName}',
                        subtitle:
                            'Choose image and press Save changes. The app will upload it and save everything to Firebase.',
                        trailing: FilledButton.icon(
                          onPressed: _controller.saveConfig,
                          icon: _controller.isUploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _controller.isUploading
                                ? 'Saving...'
                                : 'Save changes',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _AppIconSection(controller: _controller),
                      const SizedBox(height: 16),
                      _SplashSection(controller: _controller),
                      const SizedBox(height: 16),
                      if (_controller.message != null)
                        _StatusBanner(
                          message: _controller.message!,
                          background: const Color(0xFFECFDF3),
                          foreground: const Color(0xFF027A48),
                        ),
                      if (_controller.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _StatusBanner(
                            message: _controller.error!,
                            background: const Color(0xFFFEF3F2),
                            foreground: const Color(0xFFB42318),
                          ),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Back to role selection'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _AppIconSection extends StatelessWidget {
  const _AppIconSection({required this.controller});

  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'App icon',
              subtitle: 'Choose a built-in icon key and save it.',
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: controller.selectedIcon,
              items: BrandingConfig.supportedIconKeys
                  .map(
                    (key) =>
                        DropdownMenuItem<String>(value: key, child: Text(key)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                controller.updateSelectedIcon(value);
              },
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/app_icon_previews/${controller.selectedIcon}.webp',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            _SimpleRow(label: 'Current key', value: controller.selectedIcon),
          ],
        ),
      ),
    );
  }
}

class _SplashSection extends StatelessWidget {
  const _SplashSection({required this.controller});

  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Splash image',
              subtitle:
                  'Pick image, then Save changes uploads it and stores the URL in Firebase.',
            ),
            const SizedBox(height: 12),
            _SimpleRow(
              label: 'ImageKit',
              value: ImageKitUploadService.urlEndpoint,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use default splash'),
              value: controller.useDefaultSplash,
              onChanged: controller.updateSplashMode,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: controller.isBusy
                        ? null
                        : controller.pickSplashImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.splashUrlController,
              enabled: !controller.useDefaultSplash,
              decoration: const InputDecoration(
                labelText: 'Remote splash URL',
                hintText: 'Uploaded URL will appear here',
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: controller.hasSelectedSplashFile
                    ? Image.file(
                        File(controller.selectedSplashFile!.path),
                        fit: BoxFit.cover,
                      )
                    : controller.useDefaultSplash ||
                          controller.previewUrl.isEmpty
                    ? Image.asset(
                        'assets/images/default_splash.png',
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: controller.previewUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Text('Preview unavailable'),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SimpleChip(
                  label: 'Selected file',
                  value: controller.selectedSplashFileName,
                ),
                _SimpleChip(
                  label: 'Mode',
                  value: controller.useDefaultSplash
                      ? 'Default'
                      : 'Custom remote',
                ),
                _SimpleChip(
                  label: 'Splash version',
                  value: controller.config.splashVersion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.background,
    required this.foreground,
  });

  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SimpleChip extends StatelessWidget {
  const _SimpleChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFF475467),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF101828),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
