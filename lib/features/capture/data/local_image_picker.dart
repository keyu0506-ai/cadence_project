import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteImage {
  const NoteImage({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
}

final localImagePickerProvider = Provider<LocalImagePicker>(
  (ref) => LocalImagePicker(),
);

class LocalImagePicker {
  LocalImagePicker({Future<XFile?> Function()? selectFile})
    : _selectFile = selectFile ?? _openImage;
  final Future<XFile?> Function() _selectFile;
  static const maxBytes = 10 * 1024 * 1024;

  static Future<XFile?> _openImage() => openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png'],
        mimeTypes: ['image/jpeg', 'image/png'],
        uniformTypeIdentifiers: ['public.jpeg', 'public.png'],
      ),
    ],
  );

  Future<NoteImage?> pick() async {
    final file = await _selectFile();
    if (file == null) return null;
    if (!RegExp(r'\.(png|jpe?g)$', caseSensitive: false).hasMatch(file.name)) {
      throw const FormatException('Choose a JPG or PNG image.');
    }
    if (await file.length() > maxBytes) {
      throw const FormatException('Choose an image smaller than 10 MB.');
    }
    final bytes = await file.readAsBytes();
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71;
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    if (bytes.length > maxBytes || (!png && !jpeg)) {
      throw const FormatException('This file is not a valid JPG or PNG image.');
    }
    // Validate decoding before enabling extraction, rather than accepting a
    // renamed or corrupt file that cannot actually be previewed.
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1200);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
    } catch (_) {
      throw const FormatException(
        'This image could not be opened. Try another JPG or PNG.',
      );
    }
    return NoteImage(name: file.name, bytes: bytes);
  }
}
