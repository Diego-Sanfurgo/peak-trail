part of 'tracking_map_bloc.dart';

sealed class TrackingMapState extends Equatable {
  const TrackingMapState();
  
  @override
  List<Object> get props => [];
}

final class TrackingMapInitial extends TrackingMapState {}
