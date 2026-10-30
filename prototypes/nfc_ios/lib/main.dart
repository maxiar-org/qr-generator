import 'dart:io';

import 'package:flutter/material.dart';
// This separate spike reuses the exact NDEF planning logic accepted for web.
// ignore: implementation_imports
import 'package:qr_generator/src/domain/nfc_message.dart';
// ignore: implementation_imports
import 'package:qr_generator/src/domain/qr_label_type.dart';

import 'nfc_session.dart';

const nfcSpikeEnabled = bool.fromEnvironment('NFC_SPIKE');

/// Example content per QR type, not a real customer's data.
const _demoQrData = <QrLabelType, String>{
  QrLabelType.whatsapp: 'https://wa.me/5491112345678',
  QrLabelType.instagram: 'https://instagram.com/ejemplo',
  QrLabelType.googleReviews: 'https://search.google.com/local/writereview?placeid=ChIJdemo00000000000000000000',
  QrLabelType.mercadoPago: 'https://mpago.la/pos/DEMO-NO-PAGAR',
};

/// A raw EMVCo payload (not a link), to demonstrate the content this
/// prototype refuses to write — see docs/spike-nfc.md, point 3.
const _demoMercadoPagoEmv =
    '00020101021126390017ar.demo.aceptador0114demo-sin-cobro5204970053030325802AR5904Demo6004CABA63040582';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isIOS) {
    throw UnsupportedError('Este prototipo requiere un iPhone.');
  }
  runApp(const MaterialApp(home: SpikeScreen()));
}

class SpikeScreen extends StatefulWidget {
  const SpikeScreen({super.key});

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  final _session = NfcSession();
  QrLabelType _type = QrLabelType.whatsapp;
  bool _useEmvDemo = false;
  bool _lock = false;
  bool _busy = false;
  String _status = 'Elegí un tipo de QR y acercá un tag NTAG213/215/216.';

  NfcRecordPlan get _plan => planNfcRecording(
    type: _type,
    qrData: _type == QrLabelType.mercadoPago && _useEmvDemo
        ? _demoMercadoPagoEmv
        : _demoQrData[_type]!,
  );

  Future<void> _record(String url) async {
    setState(() {
      _busy = true;
      _status = 'Acercá el tag…';
    });
    try {
      await _session.writeUri(encodeNdefUriPayload(url), lock: _lock);
      if (!mounted) return;
      setState(() => _status = 'Grabado: $url');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba NFC · iOS')),
      body: !nfcSpikeEnabled
          ? const Center(child: Text('Prototipo desactivado (NFC_SPIKE).'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Datos de ejemplo, no de un cliente real. Usá un tag de '
                  'prueba NTAG213, 215 o 216.',
                ),
                const SizedBox(height: 16),
                RadioGroup<QrLabelType>(
                  groupValue: _type,
                  onChanged: (value) {
                    if (!_busy && value != null) {
                      setState(() => _type = value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final type in QrLabelType.values)
                        RadioListTile<QrLabelType>(
                          title: Text(type.displayName),
                          value: type,
                        ),
                    ],
                  ),
                ),
                if (_type == QrLabelType.mercadoPago)
                  SwitchListTile(
                    title: const Text('Simular payload EMVCo (no un link)'),
                    value: _useEmvDemo,
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _useEmvDemo = value),
                  ),
                SwitchListTile(
                  title: const Text('Bloquear el tag después de grabar'),
                  subtitle: const Text(
                    'Irreversible: deja de poder regrabarse.',
                  ),
                  value: _lock,
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _lock = value),
                ),
                const SizedBox(height: 16),
                Text(switch (plan) {
                  NfcUriRecordPlan() => 'Se va a grabar: ${plan.url}',
                  NfcUnsupportedPlan() => plan.reason,
                }),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy || plan is! NfcUriRecordPlan
                      ? null
                      : () => _record(plan.url),
                  child: const Text('Grabar NFC'),
                ),
                if (_busy) const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(_status),
              ],
            ),
    );
  }
}
