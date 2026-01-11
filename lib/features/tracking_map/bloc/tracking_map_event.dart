part of 'tracking_map_bloc.dart';

sealed class TrackingMapEvent extends Equatable {
  const TrackingMapEvent();

  @override
  List<Object> get props => [];
}

final class TrackingMapStartTracking extends TrackingMapEvent {
  const TrackingMapStartTracking();
}

final class TrackingMapStopTracking extends TrackingMapEvent {
  const TrackingMapStopTracking();
}
