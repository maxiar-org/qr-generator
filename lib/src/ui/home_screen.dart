import 'package:flutter/material.dart';

import '../domain/qr_label_type.dart';
import '../printing/label_icons.dart';
import 'coming_soon_screen.dart';
import 'google_reviews_screen.dart';
import 'instagram_screen.dart';
import 'theme/app_theme.dart';
import 'whatsapp_screen.dart';
import 'widgets/app_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppScreen(
      title: 'Generador de QR',
      children: [
        for (final type in QrLabelType.values) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: qrTypeAccent(type),
                foregroundColor: Colors.white,
                child: Icon(labelIconFor(type), size: 20),
              ),
              title: Text(type.displayName, style: textTheme.titleMedium),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.inkMuted,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => switch (type) {
                    QrLabelType.googleReviews => const GoogleReviewsScreen(),
                    QrLabelType.whatsapp => const WhatsAppScreen(),
                    QrLabelType.instagram => const InstagramScreen(),
                    _ => ComingSoonScreen(type: type),
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
