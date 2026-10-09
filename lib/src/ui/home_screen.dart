import 'package:flutter/material.dart';

import '../domain/qr_label_type.dart';
import '../printing/label_icons.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';
import 'widgets/qr_type_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppScreen(
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
                  builder: (_) => screenForQrType(type),
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
