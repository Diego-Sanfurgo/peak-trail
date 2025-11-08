import 'dart:convert';
import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>?> getMountains() async {
  try {
    final String jsonString = await rootBundle.loadString('data/peaks.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    return data;
  } on Exception catch (e) {
    log(e.toString());
    return null;
  }
}
