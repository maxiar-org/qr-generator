import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/nfc_message.dart';
import 'package:qr_generator/src/nfc/nfc_recorder.dart';
import 'package:qr_generator/src/ui/nfc_record_button.dart';

class FakeNfcRecorder implements NfcRecorder {
  FakeNfcRecorder({this.isAvailable = true});

  @override
  bool isAvailable;
  bool fail = false;
  Completer<NfcWriteResult>? pending;
  @override
  void cancel() {
    pending?.complete(NfcWriteResult.cancelled);
    pending = null;
  }

  NfcWriteResult result = NfcWriteResult.written;
  String? writtenUrl;

  @override
  Future<NfcWriteResult> writeUri(String url) async {
    if (fail) throw StateError('failed');
    writtenUrl = url;
    return pending == null ? result : await pending!.future;
  }
}

void main() {
  const url = 'https://wa.me/5491112345678';
  late FakeNfcRecorder recorder;

  Future<void> show(
    WidgetTester tester, {
    NfcRecordPlan plan = const NfcUriRecordPlan(url),
  }) async {
    recorder = FakeNfcRecorder();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NfcRecordButton(plan: plan, recorder: recorder),
        ),
      ),
    );
  }

  testWidgets('cancels a pending write when its route is popped', (
    tester,
  ) async {
    await show(tester);
    final context = tester.element(find.byType(NfcRecordButton));
    final pendingRecorder = FakeNfcRecorder()..pending = Completer();
    final pending = pendingRecorder.pending!.future;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: NfcRecordButton(
            plan: const NfcUriRecordPlan(url),
            recorder: pendingRecorder,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grabar NFC').last);
    await tester.pump();
    Navigator.of(tester.element(find.byType(NfcRecordButton).last)).pop();
    await tester.pumpAndSettle();
    expect(pendingRecorder.pending, isNull);
    expect(await pending, NfcWriteResult.cancelled);
  });

  testWidgets('offers cancellation while waiting and allows retry', (
    tester,
  ) async {
    await show(tester);
    recorder.pending = Completer();
    await tester.tap(find.text('Grabar NFC'));
    await tester.pump();
    await tester.tap(find.text('Cancelar grabación'));
    await tester.pumpAndSettle();
    expect(recorder.pending, isNull);
    await tester.tap(find.text('Grabar NFC'));
    await tester.pumpAndSettle();
    expect(find.textContaining('grabada'), findsOneWidget);
  });

  testWidgets('hides entirely when the platform has no NFC support', (
    tester,
  ) async {
    await show(tester);
    recorder.isAvailable = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NfcRecordButton(
            plan: const NfcUriRecordPlan(url),
            recorder: recorder,
          ),
        ),
      ),
    );
    expect(find.text('Grabar NFC'), findsNothing);
  });

  testWidgets('offers to record the exact URL when available', (tester) async {
    await show(tester);
    await tester.tap(find.text('Grabar NFC'));
    await tester.pumpAndSettle();
    expect(recorder.writtenUrl, url);
    expect(find.textContaining('grabada'), findsOneWidget);
  });

  testWidgets('explains why Mercado Pago EMVCo content is not offered', (
    tester,
  ) async {
    await show(
      tester,
      plan: const NfcUnsupportedPlan('Este QR de Mercado Pago es EMVCo.'),
    );
    expect(find.text('Grabar NFC'), findsNothing);
    expect(find.textContaining('EMVCo'), findsOneWidget);
  });

  testWidgets('reports a write failure and allows retrying', (tester) async {
    await show(tester);
    recorder.fail = true;
    await tester.tap(find.text('Grabar NFC'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo'), findsOneWidget);
    recorder.fail = false;
    await tester.tap(find.text('Grabar NFC'));
    await tester.pumpAndSettle();
    expect(recorder.writtenUrl, url);
  });

  testWidgets('does not suggest success after a cancelled write', (
    tester,
  ) async {
    await show(tester);
    recorder.result = NfcWriteResult.cancelled;
    await tester.tap(find.text('Grabar NFC'));
    await tester.pumpAndSettle();
    expect(find.textContaining('grabada'), findsNothing);
    expect(find.textContaining('No se pudo'), findsNothing);
  });
}
