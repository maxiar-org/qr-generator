import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../domain/google_reviews.dart';

class GoogleReviewsScreen extends StatefulWidget {
  const GoogleReviewsScreen({super.key});

  @override
  State<GoogleReviewsScreen> createState() => _GoogleReviewsScreenState();
}

class _GoogleReviewsScreenState extends State<GoogleReviewsScreen> {
  final _controller = TextEditingController();
  String? _reviewUrl;
  String? _error;

  void _generate() {
    try {
      final url = buildGoogleReviewUrl(_controller.text);
      setState(() {
        _reviewUrl = url;
        _error = null;
      });
      FocusScope.of(context).unfocus();
    } on FormatException catch (error) {
      setState(() {
        _reviewUrl = null;
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
      appBar: AppBar(title: const Text('Google Reseñas')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Pegá el Place ID o una URL de Maps con query_place_id.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Place ID o enlace compatible',
                    hintText: 'Place ID del comercio',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                    errorMaxLines: 4,
                  ),
                  onSubmitted: (_) => _generate(),
                  onChanged: (_) => setState(() {
                    _reviewUrl = null;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _generate,
                  child: const Text('Generar QR'),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Tenés un link corto o el nombre del negocio? Abrí el link '
                  'en Maps, anotá nombre y dirección y buscá ese comercio en '
                  'Place ID Finder de Google. Copiá su ID y pegalo acá. '
                  'No necesitás una clave propia.',
                ),
                const SizedBox(height: 8),
                const SelectableText(
                  'https://developers.google.com/maps/documentation/places/web-service/place-id',
                ),
                if (_reviewUrl != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: QrImageView(
                      data: _reviewUrl!,
                      size: 280,
                      padding: const EdgeInsets.all(28),
                      backgroundColor: Colors.white,
                      semanticsLabel: 'QR de reseñas de Google: $_reviewUrl',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(_reviewUrl!, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    'Escaneá el QR y verificá el negocio antes de imprimir. Google puede pedirte iniciar sesión.',
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
