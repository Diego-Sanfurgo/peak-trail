import 'package:peak_trail/models/mountain.dart';

class MountainsRepository {
  factory MountainsRepository() {
    return _instance;
  }
  MountainsRepository._internal();

  Set<Mountain> mountains = {};

  static final MountainsRepository _instance = MountainsRepository._internal();
}
