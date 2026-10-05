import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lpapi_ios_spike/main.dart';
import 'package:lpapi_ios_spike/printer_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('lpapi_thermal_printer');
  final calls = <MethodCall>[];
  var connects = true;
  var prints = true;
  var disconnectFails = false;

  setUp(() {
    calls.clear();
    connects = true;
    prints = true;
    disconnectFails = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'disconnectPrinter' && disconnectFails) {
            throw PlatformException(code: 'DISCONNECT_FAILED');
          }
          return switch (call.method) {
            'connectPrinter' => connects,
            'printImage' => prints,
            'disconnectPrinter' => true,
            'discoverPrinters' => [
              {
                'name': 'DT01 Maxi',
                'address': 'DT01 Maxi',
                'type': 'DISCOVERED',
              },
            ],
            _ => throw PlatformException(code: 'UNEXPECTED'),
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends the exact PNG to the selected printer and disconnects', () async {
    final bytes = Uint8List.fromList([137, 80, 78, 71]);
    await PrinterSession().printImage('DT01-selected', bytes);
    expect(calls.map((call) => call.method), [
      'connectPrinter',
      'printImage',
      'disconnectPrinter',
    ]);
    expect(calls.first.arguments, {'address': 'DT01-selected'});
    expect(calls[1].arguments, {'imageData': base64Encode(bytes)});
  });

  test('does not print after a rejected connection', () async {
    connects = false;
    await expectLater(
      PrinterSession().printImage('DT01', Uint8List(1)),
      throwsA(isA<StateError>()),
    );
    expect(calls.map((call) => call.method), [
      'connectPrinter',
      'disconnectPrinter',
    ]);
  });

  test('reports a rejected print and releases the connection', () async {
    prints = false;
    await expectLater(
      PrinterSession().printImage('DT01', Uint8List(1)),
      throwsA(isA<StateError>()),
    );
    expect(calls.last.method, 'disconnectPrinter');
  });

  for (final failsToConnect in [true, false]) {
    test('preserves the original error when disconnect also fails '
        '(connection rejected: $failsToConnect)', () async {
      connects = !failsToConnect;
      prints = false;
      disconnectFails = true;
      await expectLater(
        PrinterSession().printImage('DT01', Uint8List(1)),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            failsToConnect
                ? 'No se pudo conectar con la impresora.'
                : 'La impresora rechazó la imagen.',
          ),
        ),
      );
      expect(calls.last.method, 'disconnectPrinter');
    });
  }

  test('reports disconnect failure after a successful print', () async {
    disconnectFails = true;
    await expectLater(
      PrinterSession().printImage('DT01', Uint8List(1)),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'DISCONNECT_FAILED',
        ),
      ),
    );
  });

  testWidgets('default flag hides printing and makes no Bluetooth calls', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SpikeScreen()));
    expect(find.text('Imprimir'), findsNothing);
    expect(find.textContaining('desactivado'), findsOneWidget);
    expect(calls, isEmpty);
  }, skip: directPrintEnabled);

  testWidgets(
    'enabled flag requires discovery and explicit printer selection',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SpikeScreen()));
      final printButton = find.widgetWithText(FilledButton, 'Imprimir');
      expect(tester.widget<FilledButton>(printButton).onPressed, isNull);
      await tester.tap(find.text('Buscar impresoras'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(printButton).onPressed, isNull);
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(tester.widget<FilledButton>(printButton).onPressed, isNotNull);
      expect(calls.map((call) => call.method), ['discoverPrinters']);
    },
    skip: !directPrintEnabled,
  );
}
