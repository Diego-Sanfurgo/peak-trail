part of 'map_bloc.dart';

@immutable
sealed class MapEvent extends Equatable {}

class MapCreated extends MapEvent {
  final MapboxMap controller;

  MapCreated(this.controller);

  @override
  List<Object?> get props => [controller];
}
