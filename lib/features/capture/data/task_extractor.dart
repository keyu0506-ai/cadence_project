import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/task.dart';

abstract interface class TaskExtractor {
  Future<List<TaskDraft>> extract(String text, {Uint8List? imageBytes});
}

final taskExtractorProvider = Provider<TaskExtractor>(
  (ref) => CloudTaskExtractor(),
);

class CloudTaskExtractor implements TaskExtractor {
  CloudTaskExtractor({
    Future<Object?> Function(Map<String, Object> input)? call,
  }) : _call = call ?? _callFunction;
  final Future<Object?> Function(Map<String, Object>) _call;

  static Future<Object?> _callFunction(Map<String, Object> input) async {
    final function = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable(
          'extractTasks',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 105)),
        );
    return (await function.call<Object?>(input)).data;
  }

  @override
  Future<List<TaskDraft>> extract(String text, {Uint8List? imageBytes}) async {
    final now = DateTime.now();
    final input = <String, Object>{
      'currentDate':
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'timeZone': now.timeZoneName,
      'utcOffsetMinutes': now.timeZoneOffset.inMinutes,
      if (imageBytes != null)
        'imageBase64': base64Encode(imageBytes)
      else
        'text': text.trim(),
    };
    final timer = Stopwatch()..start();
    if (kDebugMode) {
      debugPrint(
        '[TaskExtraction] start region=us-central1 '
        'source=${imageBytes == null ? "text" : "image"} '
        'size=${imageBytes?.length ?? text.length}',
      );
    }
    final Object? response;
    try {
      response = await _call(input);
    } catch (error) {
      if (kDebugMode) {
        final code = error is FirebaseFunctionsException
            ? error.code
            : error.runtimeType;
        debugPrint(
          '[TaskExtraction] failed code=$code elapsedMs=${timer.elapsedMilliseconds}',
        );
      }
      rethrow;
    }
    if (kDebugMode) {
      debugPrint(
        '[TaskExtraction] response received elapsedMs=${timer.elapsedMilliseconds}',
      );
    }
    if (response is! Map ||
        response['tasks'] is! List ||
        (response['tasks'] as List).length > 50) {
      throw const FormatException('Invalid extraction response.');
    }
    final batch =
        '${now.microsecondsSinceEpoch}-${Random.secure().nextInt(0x7fffffff)}';
    return (response['tasks'] as List).asMap().entries.map((entry) {
      final row = entry.value;
      if (row is! Map ||
          row['title'] is! String ||
          (row['title'] as String).trim().isEmpty ||
          (row['title'] as String).length > 200 ||
          (row['subject'] != null &&
              (row['subject'] is! String ||
                  (row['subject'] as String).length > 100)) ||
          (row['notes'] != null &&
              (row['notes'] is! String ||
                  (row['notes'] as String).length > 5000))) {
        throw const FormatException('Invalid extracted task.');
      }
      DateTime? date;
      if (row['dueDate'] != null) {
        // Reuse the date-only serializer's strict calendar validation.
        date = Task.fromMap('validation', {
          'title': row['title'],
          'dueDate': row['dueDate'],
        }).dueDate;
      }
      return TaskDraft(
        id: '$batch-${entry.key}',
        title: (row['title'] as String).trim(),
        dueDate: date,
        subject: row['subject'] as String?,
        notes: row['notes'] as String?,
      );
    }).toList();
  }
}
