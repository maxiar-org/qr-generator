import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../domain/whatsapp.dart';

class WhatsAppScreen extends StatefulWidget {
  const WhatsAppScreen({super.key});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  final _phone = TextEditingController();
  final _message = TextEditingController();
  String? _url;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  void _clearResult(String _) {
    setState(() {
      _url = null;
      _error = null;
    });
  }

  void _generate() {
    FocusScope.of(context).unfocus();
    setState(() {
      _url = null;
      _error = null;
      try {
        _url = buildWhatsAppUrl(_phone.text, message: _message.text);
      } on FormatException catch (error) {
        _error = error.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WhatsApp')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Ingresá el celular de tu comercio con código de área.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  onChanged: _clearResult,
                  decoration: InputDecoration(
                    labelText: 'Celular argentino',
                    hintText: '11 2345-6789',
                    errorText: _error,
                    errorMaxLines: 4,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _message,
                  onChanged: _clearResult,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje inicial (opcional)',
                    hintText: 'Hola, quiero hacer una consulta.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _generate,
                  child: const Text('Generar QR'),
                ),
                if (_url != null) ...[
                  const SizedBox(height: 24),
                  const Text('Escaneá el QR para abrir el chat en WhatsApp.'),
                  Center(
                    child: QrImageView(
                      data: _url!,
                      size: 280,
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.white,
                      semanticsLabel: 'QR para abrir el chat en WhatsApp',
                      errorStateBuilder: (_, _) => const Text(
                        'El mensaje es demasiado largo. Acortalo y volvé a generar el QR.',
                      ),
                    ),
                  ),
                  SelectableText(_url!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
