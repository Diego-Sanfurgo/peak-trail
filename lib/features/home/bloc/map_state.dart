part of 'map_bloc.dart';

enum MapStatus { initial, loading, loaded, error }

class MapState extends Equatable {
  final MapStatus status;
  final List<Place> places;
  final String styleUri;
  final Set<String> activeOverlays;
  final String? placeTypeFilter;
  const MapState({
    this.status = MapStatus.initial,
    this.places = const [],
    this.styleUri = MapboxStyles.OUTDOORS,
    this.activeOverlays = const {},
    this.placeTypeFilter,
  });

  MapState copyWith({
    MapStatus? status,
    List<Place>? places,
    String? styleUri,
    Set<String>? activeOverlays,
    String? Function()? placeTypeFilter,
  }) {
    return MapState(
      status: status ?? this.status,
      places: places ?? this.places,
      styleUri: styleUri ?? this.styleUri,
      activeOverlays: activeOverlays ?? this.activeOverlays,
      placeTypeFilter: placeTypeFilter != null
          ? placeTypeFilter()
          : this.placeTypeFilter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    places,
    styleUri,
    activeOverlays,
    placeTypeFilter,
  ];
}
