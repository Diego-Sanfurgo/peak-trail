import 'package:peak_trail/api/mountains/get_mountains.dart';
import 'package:peak_trail/models/mountain.dart';

class MountainsProvider {
  Future<Set<Mountain>> fetchMountains() async {
    try {
      final Map<String, dynamic>? data = await getMountains();
      if (data == null) {
        return {};
      }

      return Set.from(
        data.entries,
      ).map((e) => Mountain.fromJson(e.value)).toSet();
    } catch (e) {
      return {};
    }
  }
}
