import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../domain/google_reviews.dart';
import '../domain/qr_label_type.dart';
import 'label_preview_screen.dart';
import 'business_search.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';

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
    final textTheme = Theme.of(context).textTheme;
    return AppScreen(
      title: 'Google Reseñas',
      children: [
        BusinessSearch(
          onSelected: (place) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LabelPreviewScreen(
                  type: QrLabelType.googleReviews,
                  qrData: place.reviewUrl,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Pegá el Place ID o una URL de Maps con query_place_id.',
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _controller,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Place ID o enlace compatible',
            hintText: 'Place ID del comercio',
            errorText: _error,
            errorMaxLines: 4,
          ),
          onSubmitted: (_) => _generate(),
          onChanged: (_) => setState(() {
            _reviewUrl = null;
            _error = null;
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(onPressed: _generate, child: const Text('Generar QR')),
        const SizedBox(height: AppSpacing.md),
        Text(
          'La mayoría de los links compartidos de Maps, incluso largos, '
          'no incluyen el Place ID. Abrí el link en Maps, anotá nombre y '
          'dirección y buscá ese comercio en Place ID Finder de Google. '
          'Copiá su ID y pegalo acá. No necesitás una clave propia.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(
          'https://developers.google.com/maps/documentation/places/web-service/place-id',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.sello),
        ),
        if (_reviewUrl != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  QrImageView(
                    data: _reviewUrl!,
                    size: 220,
                    backgroundColor: Colors.white,
                    semanticsLabel: 'QR de reseñas de Google: $_reviewUrl',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SelectableText(_reviewUrl!, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LabelPreviewScreen(
                          type: QrLabelType.googleReviews,
                          qrData: _reviewUrl!,
                        ),
                      ),
                    ),
                    child: const Text('Vista previa de impresión'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Escaneá el QR y verificá el negocio antes de imprimir. '
                    'Google puede pedirte iniciar sesión.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
