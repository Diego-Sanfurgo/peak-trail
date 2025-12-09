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

class MapCameraChanged extends MapEvent {
  MapCameraChanged(this.cameraState);

  final CameraState cameraState;

  @override
  List<Object?> get props => [cameraState];
}

class MapStyleLoaded extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapCameraToMe extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapStartTracking extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapNavigateToSearch extends MapEvent {
  @override
  List<Object?> get props => [];
}
