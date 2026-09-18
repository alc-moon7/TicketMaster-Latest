import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum TicketImageSource { gallery, camera }

const MethodChannel _ticketImagePickerChannel = MethodChannel(
  'ticketmaster/ticket_image_picker',
);

Future<Uint8List?> pickTicketImage(TicketImageSource source) async {
  if (kIsWeb) {
    throw UnsupportedError('Image picking is not available on web yet.');
  }

  final result = await _ticketImagePickerChannel.invokeMethod<Object?>(
    'pickTicketImage',
    {'source': source.name},
  );

  if (result == null) {
    return null;
  }
  if (result is Uint8List) {
    return result;
  }

  throw const FormatException('Unexpected image picker response.');
}
