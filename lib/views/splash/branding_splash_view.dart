import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../controllers/splash_controller.dart';
import '../../core/repositories/branding_repository.dart';
import '../../core/services/dynamic_app_icon_service.dart';

class BrandingSplashView extends StatefulWidget {
  const BrandingSplashView({
    super.key,
    required this.repository,
    required this.dynamicAppIconService,
    required this.onFinished,
  });

  final BrandingRepository repository;
  final DynamicAppIconService dynamicAppIconService;
  final void Function(BuildContext context) onFinished;

  @override
  State<BrandingSplashView> createState() => _BrandingSplashViewState();
}

class _BrandingSplashViewState extends State<BrandingSplashView> {
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController(
      repository: widget.repository,
      dynamicAppIconService: widget.dynamicAppIconService,
    );
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _controller.initialize();
    if (!mounted) return;
    await _controller.waitBeforeContinue();
    if (!mounted) return;
    widget.onFinished(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final config = _controller.config;

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (config.hasRemoteSplash)
                CachedNetworkImage(
                  imageUrl: config.resolvedSplashUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/default_splash.png',
                    fit: BoxFit.cover,
                  ),
                )
              else
                Image.asset(
                  'assets/images/default_splash.png',
                  fit: BoxFit.cover,
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F172A).withValues(alpha: 0.22),
                      const Color(0xFF020617).withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          config.splashModeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.94, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.asset(
                                      config.previewAssetPath,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Hello World',
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          config.campaignTitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'A better splash experience with dynamic icon switching, remote image support, and seasonal branding control.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _SplashMetaChip(
                                    label: 'Icon',
                                    value: config.iconLabel,
                                  ),
                                  _SplashMetaChip(
                                    label: 'Icon v',
                                    value: config.iconVersion,
                                  ),
                                  _SplashMetaChip(
                                    label: 'Splash v',
                                    value: config.splashVersion,
                                  ),
                                  _SplashMetaChip(
                                    label: 'Updated',
                                    value: config.shortUpdatedAt,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SplashMetaChip extends StatelessWidget {
  const _SplashMetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
