import 'package:flutter/material.dart';

import '../domain/nfc_message.dart';
import '../nfc/nfc_recorder.dart';
import 'theme/app_theme.dart';

/// "Grabar NFC": only rendered where both the content and the platform
/// support it (see `planNfcRecording` and `NfcRecorder.isAvailable`).
/// Renders nothing elsewhere, so it never breaks the web flow.
class NfcRecordButton extends StatefulWidget {
  const NfcRecordButton({super.key, required this.plan, this.recorder});

  final NfcRecordPlan plan;

  /// Permite reemplazar el recorder en los tests por uno sin dependencias
  /// del navegador real.
  final NfcRecorder? recorder;

  @override
  State<NfcRecordButton> createState() => _NfcRecordButtonState();
}

class _NfcRecordButtonState extends State<NfcRecordButton> {
  late final NfcRecorder _recorder;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _recorder = widget.recorder ?? NfcRecorder();
  }

  @override
  void dispose() {
    _recorder.cancel();
    super.dispose();
  }

  Future<void> _record(String url) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await _recorder.writeUri(url);
      if (!mounted) return;
      setState(
        () => _message = switch (result) {
          NfcWriteResult.written =>
            'Etiqueta grabada. Acercá otro celular para confirmar la lectura.',
          NfcWriteResult.cancelled => null,
        },
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'No se pudo grabar la etiqueta NFC. Acercá el tag y probá de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_recorder.isAvailable) return const SizedBox.shrink();
    final plan = widget.plan;
    return switch (plan) {
      NfcUnsupportedPlan() => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(
          plan.reason,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      NfcUriRecordPlan() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _record(plan.url),
            icon: const Icon(Icons.nfc),
            label: const Text('Grabar NFC'),
          ),
          if (_busy)
            TextButton(
              onPressed: _recorder.cancel,
              child: const Text('Cancelar grabación'),
            ),
          if (_message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _message!,
              semanticsLabel: _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    };
  }
}
