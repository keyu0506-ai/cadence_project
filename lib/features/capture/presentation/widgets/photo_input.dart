import 'package:flutter/material.dart';
import '../../data/local_image_picker.dart';

class PhotoInput extends StatelessWidget {
  const PhotoInput({
    super.key,
    required this.image,
    required this.busy,
    required this.onChoose,
    required this.onRemove,
  });
  final NoteImage? image;
  final bool busy;
  final VoidCallback onChoose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFB695FF)),
            SizedBox(height: 16),
            Text('Loading image…', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
    final selected = image;
    if (selected == null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          key: const ValueKey('photo-upload-area'),
          onTap: onChoose,
          borderRadius: BorderRadius.circular(24),
          mouseCursor: SystemMouseCursors.click,
          child: Semantics(
            button: true,
            label: 'Upload image. Choose a local JPG or PNG up to 10 MB.',
            excludeSemantics: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 64,
                      color: Color(0xFFB695FF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose a local JPG or PNG · Up to 10 MB',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFAAA1C2), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                selected.bytes,
                fit: BoxFit.contain,
                cacheWidth: 1200,
                semanticLabel: 'Selected image: ${selected.name}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  selected.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              IconButton(
                tooltip: 'Replace image',
                onPressed: onChoose,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFFB695FF),
                ),
              ),
              IconButton(
                tooltip: 'Remove image',
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, color: Color(0xFFB695FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
