import 'package:flutter/material.dart';

import '../domain/qr_label_type.dart';
import 'google_reviews_screen.dart';
import 'label_preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generador de QR')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final type in QrLabelType.values)
                  Card(
                    child: ListTile(
                      title: Text(type.displayName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => type == QrLabelType.googleReviews
                              ? const GoogleReviewsScreen()
                              : LabelPreviewScreen(type: type),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
