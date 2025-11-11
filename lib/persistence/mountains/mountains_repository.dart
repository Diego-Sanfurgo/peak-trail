import 'package:peak_trail/models/mountain.dart';
import 'package:peak_trail/persistence/mountains/mountains_provider.dart';

class MountainsRepository {
  factory MountainsRepository() => _instance;
  MountainsRepository._internal();
  static final MountainsRepository _instance = MountainsRepository._internal();

  final MountainsProvider _provider = MountainsProvider();
  Set<Mountain> mountains = {};

  Future<Set<Mountain>> getMountains() async {
    if (mountains.isNotEmpty) return mountains;

    mountains = await _provider.fetchMountains();
    return mountains;
  }
}
