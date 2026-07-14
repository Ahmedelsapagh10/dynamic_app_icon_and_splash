import 'package:flutter/material.dart';

import '../../core/models/user_role.dart';
import '../../core/repositories/branding_repository.dart';
import '../../core/services/dynamic_app_icon_service.dart';
import '../../core/services/imagekit_upload_service.dart';
import '../admin/admin_home_view.dart';
import '../user/user_home_view.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoleCard(
                    title: 'Login as Admin',
                    icon: Icons.admin_panel_settings_outlined,
                    accent: const Color(0xFF155EEF),
                    onTap: () => _openNext(context, UserRole.admin),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    title: 'Login as User',
                    icon: Icons.person_outline,
                    accent: const Color(0xFF0F766E),
                    onTap: () => _openNext(context, UserRole.user),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openNext(BuildContext context, UserRole role) {
    if (role == UserRole.admin) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AdminHomeView(
            repository: repository,
            dynamicAppIconService: dynamicAppIconService,
            imageKitUploadService: imageKitUploadService,
            adminName: 'admin',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UserHomeView(repository: repository, userName: 'user'),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
