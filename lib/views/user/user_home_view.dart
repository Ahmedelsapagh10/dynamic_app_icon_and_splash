import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/user_controller.dart';
import '../../core/repositories/branding_repository.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({
    super.key,
    required this.repository,
    required this.userName,
  });

  final BrandingRepository repository;
  final String userName;

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  late final UserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserController(
      repository: widget.repository,
      userName: widget.userName,
    );
    unawaited(_controller.loadConfig());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final config = _controller.config;

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Console'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : _controller.loadConfig,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'monospace',
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'brand_console.log',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('user=${_controller.userName}'),
                          Text('icon_key=${config.appIconKey}'),
                          Text('icon_label=${config.iconLabel}'),
                          Text('icon_version=${config.iconVersion}'),
                          Text('splash_mode=${config.splashModeLabel}'),
                          Text('splash_version=${config.splashVersion}'),
                          Text('campaign=${config.campaignTitle}'),
                          Text('updated_at=${config.shortUpdatedAt}'),
                          Text(
                            'splash_url=${config.hasRemoteSplash ? config.resolvedSplashUrl : 'default'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
