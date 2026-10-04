import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../domain/instagram_profile.dart';

class InstagramScreen extends StatefulWidget {
  const InstagramScreen({super.key});

  @override
  State<InstagramScreen> createState() => _InstagramScreenState();
}

class _InstagramScreenState extends State<InstagramScreen> {
  final _controller = TextEditingController();
  String? _profileUrl;
  String? _error;

  void _generate() {
    try {
      final url = normalizeInstagramProfile(_controller.text);
      setState(() {
        _profileUrl = url;
        _error = null;
      });
      FocusScope.of(context).unfocus();
    } on FormatException catch (error) {
      setState(() {
        _profileUrl = null;
        _error = error.message;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instagram')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Ingresá el usuario o pegá el enlace al perfil de tu comercio.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Usuario o enlace de Instagram',
                    hintText: '@tu_comercio',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                    errorMaxLines: 4,
                  ),
                  onSubmitted: (_) => _generate(),
                  onChanged: (_) => setState(() {
                    _profileUrl = null;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _generate,
                  child: const Text('Generar QR'),
                ),
                if (_profileUrl != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: QrImageView(
                      data: _profileUrl!,
                      size: 280,
                      padding: const EdgeInsets.all(28),
                      backgroundColor: Colors.white,
                      semanticsLabel:
                          'QR del perfil de Instagram: $_profileUrl',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(_profileUrl!, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    'Escaneá el QR para abrir el perfil.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
