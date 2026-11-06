import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketmaster/tickets/ticket_image_cropper.dart';

Future<Uint8List> _artwork({bool transparent = false}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (!transparent) {
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, 32, 16), Paint()..color = Colors.red);
    canvas.drawRect(
        const Rect.fromLTWH(0, 16, 32, 16), Paint()..color = Colors.blue);
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(32, 32);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}

TicketCardImageSelection _selection(Uint8List bytes, Rect crop) =>
    TicketCardImageSelection(
      imageBytes: bytes,
      imageWidth: 32,
      imageHeight: 32,
      cropRect: crop,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Shade follows each crop and reuses sampling for unchanged artwork',
      () async {
    final bytes = await _artwork();
    final redCrop = _selection(bytes, const Rect.fromLTWH(0, 0, 1, 0.5));
    final blueCrop = _selection(bytes, const Rect.fromLTWH(0, 0.5, 1, 0.5));
    final redFuture = ticketCardBackgroundShade(redCrop);
    expect(identical(redFuture, ticketCardBackgroundShade(redCrop)), isTrue);
    final red = await redFuture;
    final blue = await ticketCardBackgroundShade(blueCrop);
    expect(red.r, greaterThan(red.b));
    expect(blue.b, greaterThan(blue.r));
    expect(red.a, 1);
    expect(red.computeLuminance(), lessThan(0.15));
    expect(blue.computeLuminance(), lessThan(0.15));
  });

  test('Transparent and unreadable artwork retain the default shade', () async {
    final transparent = _selection(
      await _artwork(transparent: true),
      const Rect.fromLTWH(0, 0, 1, 1),
    );
    expect(await ticketCardBackgroundShade(transparent),
        kDefaultTicketCardBackgroundShade);
    final invalid = _selection(
      Uint8List.fromList([0, 1, 2]),
      const Rect.fromLTWH(0, 0, 1, 1),
    );
    expect(await ticketCardBackgroundShade(invalid),
        kDefaultTicketCardBackgroundShade);
  });
}
