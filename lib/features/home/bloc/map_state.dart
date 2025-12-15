part of 'map_bloc.dart';

@immutable
sealed class MapState extends Equatable {
  final List<Peak> mountains;
  const MapState({this.mountains = const []});
}

class MapStatus extends MapState {
  final bool isLoading;
  const MapStatus({this.isLoading = false, super.mountains = const []});

  MapStatus copyWith({bool? isLoading, List<Peak>? mountains}) {
    return MapStatus(
      isLoading: isLoading ?? this.isLoading,
      mountains: mountains ?? this.mountains,
    );
  }

  @override
  List<Object?> get props => [isLoading, mountains];
}
