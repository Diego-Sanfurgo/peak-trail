import 'dart:developer';

import 'package:peak_trail/api/mountains/get_mountains.dart';
import 'package:peak_trail/models/mountain.dart';

class MountainsProvider {
  factory MountainsProvider() => _instance;
  MountainsProvider._internal();
  static final MountainsProvider _instance = MountainsProvider._internal();

  Future<Set<Mountain>> fetchMountains() async {
    try {
      final List<Map>? data = await getMountains();
      if (data == null) return {};

      // for (var rawMountain in data) {}

      return data
          .map((e) => Mountain.fromJson(e as Map<String, dynamic>))
          .toSet();

      // return Set.from(
      //   data.entries,
      // ).map((e) => Mountain.fromJson(e.value)).toSet();
    } catch (e) {
      log(e.toString());
      return {};
    }
  }
}
