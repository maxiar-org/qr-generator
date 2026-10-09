import 'package:flutter/material.dart';

import '../domain/qr_label_type.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.type});

  final QrLabelType type;

  @override
  Widget build(BuildContext context) => AppScreen(
    screenTitle: type.displayName,
    currentType: type,
    children: [
      const SizedBox(height: AppSpacing.xl),
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top,
              size: 40,
              color: AppColors.inkMuted,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Próximamente',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    ],
  );
}
