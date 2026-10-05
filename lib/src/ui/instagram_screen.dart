import 'package:flutter/material.dart';

import '../domain/instagram_profile.dart';
import '../domain/qr_label_type.dart';
import 'label_preview_screen.dart';

class InstagramScreen extends StatefulWidget {
  const InstagramScreen({super.key});

  @override
  State<InstagramScreen> createState() => _InstagramScreenState();
}

class _InstagramScreenState extends State<InstagramScreen> {
  final _controller = TextEditingController();
  String? _error;

  void _generate() {
    FocusScope.of(context).unfocus();
    try {
      final url = normalizeInstagramProfile(_controller.text);
      setState(() => _error = null);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              LabelPreviewScreen(type: QrLabelType.instagram, qrData: url),
        ),
      );
    } on FormatException catch (error) {
      setState(() => _error = error.message);
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
                    _error = null;
                  }),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _generate,
                  child: const Text('Ver etiqueta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
