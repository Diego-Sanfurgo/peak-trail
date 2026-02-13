part of 'map_bloc.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final String styleUri;
  final Set<String> activeOverlays;
  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.styleUri = MapboxStyles.OUTDOORS,
    this.activeOverlays = const {},
  });

  MapState copyWith({
    MapStatus? status,
    List<Place>? places,
    String? styleUri,
    Set<String>? activeOverlays,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      styleUri: styleUri ?? this.styleUri,
      activeOverlays: activeOverlays ?? this.activeOverlays,
    );
  }

  @override
  List<Object?> get props => [status, places, styleUri, activeOverlays];
}
