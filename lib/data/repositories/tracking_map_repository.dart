import '../providers/tracking_database.dart';

class TrackingMapRepository {
  final TrackingDatabase _database;

  TrackingMapRepository({required TrackingDatabase database})
    : _database = database;
}
