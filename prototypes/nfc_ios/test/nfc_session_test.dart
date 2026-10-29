import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_ios_spike/nfc_session.dart';

class FakeDriver implements NfcSessionDriver {
  late Future<void> Function(NfcWritableTag) discover;
  late void Function(Object) error;
  int stops = 0;
  bool failStart = false;
  Completer<void>? stopping;
  @override
  Future<void> start({
    required Future<void> Function(NfcWritableTag) onDiscovered,
    required void Function(Object) onError,
  }) async {
    if (failStart) throw StateError('start failed');
    discover = onDiscovered;
    error = onError;
  }

  @override
  Future<void> stop() async {
    stops++;
    await stopping?.future;
  }
}

class FakeTag implements NfcWritableTag {
  int writes = 0;
  int locks = 0;
  bool failWrite = false;
  bool failLock = false;
  Completer<void>? writing;
  @override
  Future<void> write(Uint8List payload) async {
    writes++;
    if (failWrite) throw StateError('write failed');
    await writing?.future;
  }

  @override
  Future<void> lock() async {
    locks++;
    if (failLock) throw StateError('lock failed');
  }
}

void main() {
  test('entitlement enables the plugin tag reader session', () {
    expect(
      File('ios/Runner/Runner.entitlements').readAsStringSync(),
      contains('<string>TAG</string>'),
    );
  });
  for (final timeout in [true, false]) {
    testWidgets(
      '${timeout ? "timeout" : "cancel"} closes before retry and ignores late discoveries',
      (tester) async {
        final driver = FakeDriver()..stopping = Completer();
        final session = NfcSession(
          driver: driver,
          timeout: const Duration(seconds: 1),
        );
        var finished = false;
        final operation = session.writeUri(Uint8List(1), lock: true);
        final expectation = expectLater(
          operation,
          throwsA(anything),
        ).then((_) => finished = true);
        await tester.pump();
        final oldDiscover = driver.discover;
        if (timeout) {
          await tester.pump(const Duration(seconds: 2));
        } else {
          driver.error(StateError('cancelled'));
          await tester.pump();
        }
        expect(driver.stops, 1);
        expect(finished, isFalse);
        final tag = FakeTag();
        await oldDiscover(tag);
        expect(tag.writes, 0);
        driver.stopping!.complete();
        await tester.pump();
        await expectation;
        driver.stopping = null;
        final retry = session.writeUri(Uint8List(1), lock: true);
        await tester.pump();
        await oldDiscover(tag);
        expect(tag.writes, 0);
        await driver.discover(tag);
        await retry;
        expect(tag.writes, 1);
        expect(tag.locks, 1);
        expect(driver.stops, 2);
      },
    );
  }
  for (final failure in ['start', 'write', 'lock']) {
    testWidgets('$failure failure releases session and permits retry', (
      tester,
    ) async {
      final driver = FakeDriver()..failStart = failure == 'start';
      final session = NfcSession(driver: driver);
      final result = session.writeUri(Uint8List(1), lock: true);
      final expected = expectLater(result, throwsStateError);
      await tester.pump();
      if (failure != 'start') {
        await driver.discover(
          FakeTag()
            ..failWrite = failure == 'write'
            ..failLock = failure == 'lock',
        );
      }
      await expected;
      expect(driver.stops, 1);
      driver.failStart = false;
      final retry = session.writeUri(Uint8List(1), lock: false);
      await tester.pump();
      await driver.discover(FakeTag());
      await retry;
      expect(driver.stops, 2);
    });
  }
  testWidgets(
    'timeout during write never locks and ignores duplicate discovery',
    (tester) async {
      final driver = FakeDriver();
      final session = NfcSession(
        driver: driver,
        timeout: const Duration(seconds: 1),
      );
      final operation = session.writeUri(Uint8List(1), lock: true);
      final expectation = expectLater(
        operation,
        throwsA(isA<TimeoutException>()),
      );
      await tester.pump();
      final tag = FakeTag()..writing = Completer();
      final callback = driver.discover(tag);
      await driver.discover(tag);
      expect(tag.writes, 1);
      await tester.pump(const Duration(seconds: 2));
      await expectation;
      tag.writing!.complete();
      await callback;
      expect(tag.locks, 0);
      expect(driver.stops, 1);
    },
  );
}
