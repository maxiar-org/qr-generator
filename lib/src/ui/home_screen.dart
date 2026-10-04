import 'package:flutter/material.dart';

import 'coming_soon_screen.dart';
import 'instagram_screen.dart';
import 'whatsapp_screen.dart';

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
                for (final option in const [
                  'WhatsApp',
                  'Instagram',
                  'Google Reseñas',
                  'Mercado Pago',
                ])
                  Card(
                    child: ListTile(
                      title: Text(option),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => option == 'Instagram'
                              ? const InstagramScreen()
                              : option == 'WhatsApp'
                              ? const WhatsAppScreen()
                              : ComingSoonScreen(title: option),
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
