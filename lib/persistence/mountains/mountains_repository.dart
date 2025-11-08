import 'package:peak_trail/models/mountain.dart';

class MountainsRepository {
  Set<Mountain> mountains = {};

  MountainsRepository._internal();

  static final MountainsRepository _instance = MountainsRepository._internal();
  factory MountainsRepository() {
    return _instance;
  }
}
