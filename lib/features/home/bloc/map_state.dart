part of 'map_bloc.dart';

@immutable
sealed class MapState extends Equatable {
  final List<Place> places;
  const MapState({this.places = const []});
}

class MapStatus extends MapState {
  final bool isLoading;
  const MapStatus({this.isLoading = false, super.places = const []});

  MapStatus copyWith({bool? isLoading, List<Place>? places}) {
    return MapStatus(
      isLoading: isLoading ?? this.isLoading,
      places: places ?? this.places,
    );
  }

  @override
  List<Object?> get props => [isLoading, places];
}
