import 'package:flutter/material.dart';

import '../domain/payment_qr.dart';
import '../domain/qr_label_type.dart';
import '../scanning/qr_capture.dart';
import 'label_preview_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';

class MercadoPagoScreen extends StatefulWidget {
  const MercadoPagoScreen({super.key, this.capture = captureQr});
  final Future<String?> Function(bool camera) capture;

  @override
  State<MercadoPagoScreen> createState() => _MercadoPagoScreenState();
}

class _MercadoPagoScreenState extends State<MercadoPagoScreen> {
  String? _data;
  String? _error;
  PaymentQrValidation? _validation;
  bool _busy = false;

  Future<void> _capture(bool camera) async {
    setState(() {
      _busy = true;
      _data = null;
      _validation = null;
      _error = null;
    });
    try {
      final data = await widget.capture(camera);
      if (!mounted) return;
      setState(() {
        _data = data;
        _validation = data == null ? null : validatePaymentQr(data);
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is FormatException
            ? error.message
            : 'No pudimos leer el QR. Probá con otra foto.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    cancelQrCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScreen(
    screenTitle: 'Mercado Pago',
    currentType: QrLabelType.mercadoPago,
    children: [
      const Text('Usá el QR de cobro que ya tiene el comercio.'),
      const SizedBox(height: AppSpacing.md),
      FilledButton.icon(
        onPressed: _busy ? null : () => _capture(true),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear QR del comercio'),
      ),
      const SizedBox(height: AppSpacing.sm),
      OutlinedButton.icon(
        onPressed: _busy ? null : () => _capture(false),
        icon: const Icon(Icons.photo_library_outlined),
        label: const Text('Subir foto del QR'),
      ),
      if (_busy)
        const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('Leyendo QR…'),
        ),
      if (_error != null) ...[
        const SizedBox(height: AppSpacing.md),
        Semantics(liveRegion: true, child: Text(_error!)),
      ],
      if (_data != null) ...[
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Contenido capturado',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(_data!),
        const SizedBox(height: AppSpacing.md),
        Semantics(liveRegion: true, child: Text(_validation!.message)),
        if (_validation!.recognized) ...[
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Confirmá con el comercio que este es su QR vigente. '
            'El formato no verifica el titular ni garantiza que el cobro siga activo.',
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LabelPreviewScreen(
                  type: QrLabelType.mercadoPago,
                  qrData: _data!,
                ),
              ),
            ),
            child: const Text('Confirmar y ver etiqueta'),
          ),
        ],
      ],
    ],
  );
}
