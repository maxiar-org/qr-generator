import 'package:flutter/material.dart';

import '../domain/whatsapp.dart';
import '../domain/qr_label_type.dart';
import 'label_preview_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';

class WhatsAppScreen extends StatefulWidget {
  const WhatsAppScreen({super.key});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  final _phone = TextEditingController();
  final _message = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  void _clearResult(String _) {
    setState(() {
      _error = null;
    });
  }

  void _generate() {
    FocusScope.of(context).unfocus();
    try {
      final url = buildWhatsAppUrl(_phone.text, message: _message.text);
      setState(() => _error = null);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              LabelPreviewScreen(type: QrLabelType.whatsapp, qrData: url),
        ),
      );
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'WhatsApp',
      children: [
        const Text('Ingresá el celular de tu comercio con código de área.'),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          onChanged: _clearResult,
          decoration: InputDecoration(
            labelText: 'Celular argentino',
            hintText: '11 2345-6789',
            errorText: _error,
            errorMaxLines: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _message,
          onChanged: _clearResult,
          minLines: 2,
          maxLines: 4,
          maxLength: 300,
          decoration: const InputDecoration(
            labelText: 'Mensaje inicial (opcional)',
            hintText: 'Hola, quiero hacer una consulta.',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(onPressed: _generate, child: const Text('Ver etiqueta')),
      ],
    );
  }
}
