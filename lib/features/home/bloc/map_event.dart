part of 'map_bloc.dart';

@immutable
sealed class MapEvent extends Equatable {}

class MapCreated extends MapEvent {
  MapCreated(this.controller);

  final MapboxMap controller;

  @override
  List<Object?> get props => [controller];
}

class MapReload extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapCameraIdle extends MapEvent {
  MapCameraIdle(this.cameraState);

  final CameraState cameraState;

  @override
  List<Object?> get props => [cameraState];
}

class MapMoveCamera extends MapEvent {
  final double? zoomLevel;
  final LatLng? targetLocation;

  MapMoveCamera({this.zoomLevel, this.targetLocation});

  @override
  List<Object?> get props => [zoomLevel, targetLocation];
}

class MapChangeStyle extends MapEvent {
  MapChangeStyle(this.styleUri);

  final String styleUri;

  @override
  List<Object?> get props => [styleUri];
}

class MapToggleOverlay extends MapEvent {
  MapToggleOverlay(this.overlayId);

  final String overlayId;

  @override
  List<Object?> get props => [overlayId];
}
