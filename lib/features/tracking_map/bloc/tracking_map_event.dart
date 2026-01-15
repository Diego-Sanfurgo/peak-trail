part of 'tracking_map_bloc.dart';

sealed class TrackingMapEvent extends Equatable {
  const TrackingMapEvent();

  @override
  List<Object> get props => [];
}

final class TrackingMapCreated extends TrackingMapEvent {
  const TrackingMapCreated(this.controller);
  final MapboxMap controller;
}

final class TrackingMapStartTracking extends TrackingMapEvent {
  const TrackingMapStartTracking();
}

final class TrackingMapStopTracking extends TrackingMapEvent {
  const TrackingMapStopTracking();
}

final class TrackingMapPauseTracking extends TrackingMapEvent {
  const TrackingMapPauseTracking();
}

final class TrackingMapResumeTracking extends TrackingMapEvent {
  const TrackingMapResumeTracking();
}

final class TrackingMapCenterCameraOnUser extends TrackingMapEvent {
  const TrackingMapCenterCameraOnUser();
}
