import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/export/label_exporter.dart';
import 'package:qr_generator/src/ui/export_actions.dart';

class FakeExporter implements LabelExporter {
  bool clipboardAvailable = true;
  bool failSave = false;
  SaveResult saveResult = SaveResult.downloaded;
  Uint8List? savedBytes;
  String? copiedUrl;

  @override
  Future<SaveResult> saveImage(Uint8List bytes) async {
    if (failSave) throw StateError('failed');
    savedBytes = bytes;
    return saveResult;
  }

  @override
  Future<bool> copyLink(String url) async {
    copiedUrl = url;
    return clipboardAvailable;
  }
}

void main() {
  const url = 'https://wa.me/5491112345678';
  final bytes = Uint8List.fromList([1, 2, 3]);
  late FakeExporter exporter;

  Future<void> showActions(WidgetTester tester) async {
    exporter = FakeExporter();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportActions(bytes: bytes, url: url, exporter: exporter),
        ),
      ),
    );
  }

  testWidgets('saves the provided PNG and explains the download', (
    tester,
  ) async {
    await showActions(tester);
    await tester.tap(find.text('Guardar imagen'));
    await tester.pumpAndSettle();
    expect(exporter.savedBytes, same(bytes));
    expect(find.textContaining('Descargas'), findsOneWidget);
  });

  testWidgets('does not suggest downloading after cancellation', (
    tester,
  ) async {
    await showActions(tester);
    exporter.saveResult = SaveResult.cancelled;
    await tester.tap(find.text('Guardar imagen'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Descargas'), findsNothing);
    expect(find.textContaining('No se pudo'), findsNothing);
  });

  testWidgets('disables saving while the current PNG is rendering', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportActions(bytes: null, url: url, exporter: FakeExporter()),
        ),
      ),
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar imagen'),
    );
    expect(button.onPressed, isNull);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Copiar link'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('copies the actual QR URL', (tester) async {
    await showActions(tester);
    await tester.tap(find.text('Copiar link'));
    await tester.pumpAndSettle();
    expect(exporter.copiedUrl, url);
    expect(find.text('Link copiado'), findsOneWidget);
  });

  testWidgets('shows selectable URL when clipboard is unavailable', (
    tester,
  ) async {
    await showActions(tester);
    exporter.clipboardAvailable = false;
    await tester.tap(find.text('Copiar link'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      url,
    );
  });

  testWidgets('reports a save failure and permits retry', (tester) async {
    await showActions(tester);
    exporter.failSave = true;
    await tester.tap(find.text('Guardar imagen'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo guardar'), findsOneWidget);
    exporter.failSave = false;
    await tester.tap(find.text('Guardar imagen'));
    await tester.pumpAndSettle();
    expect(exporter.savedBytes, same(bytes));
  });

  testWidgets('opens WePrint instructions and returns', (tester) async {
    await showActions(tester);
    await tester.tap(find.text('Cómo imprimir con WePrint'));
    await tester.pumpAndSettle();
    for (final step in [
      '1. Guardá la imagen',
      '2. Abrí WePrint',
      '3. Creá una nueva etiqueta',
      '4. Tocá Imagen',
      '5. Elegí la foto',
      '6. Imprimí',
    ]) {
      expect(find.text(step), findsOneWidget);
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Guardar imagen'), findsOneWidget);
  });
}
