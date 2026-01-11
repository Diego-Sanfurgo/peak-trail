import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:peak_trail/core/services/location_service.dart';
import 'package:peak_trail/data/providers/tracking_database.dart';
import 'package:peak_trail/data/repositories/map_repository.dart';

import '../functions/add_tracking_polyline.dart';

part 'tracking_map_event.dart';
part 'tracking_map_state.dart';

class TrackingMapBloc extends Bloc<TrackingMapEvent, TrackingMapState> {
  TrackingMapBloc({required MapRepository mapRepository})
    : _mapRepo = mapRepository,
      super(TrackingMapInitial()) {
    on<TrackingMapStartTracking>(_onStartTracking);
    on<TrackingMapStopTracking>(_onStopTracking);
  }

  MapboxMap? _controller;
  final MapRepository _mapRepo;
  final LocationService _locationService = LocationService.instance;

  Future<void> _onStartTracking(
    TrackingMapStartTracking event,
    Emitter<TrackingMapState> emit,
  ) async {
    if (_controller == null) return;

    final TrackingDatabase database = TrackingDatabase();

    geo.Position? position = _locationService.lastPosition;
    if (position == null) return;

    await addTrackingPolilyne(_controller!, position);

    await actualizarRutaEnMapa(await database.getAllPoints(), _controller);
  }
}

// Future<void> _locationTracking() async {
//   final traceService = TraceService();
//   traceService.onLocation.listen((p) {
//     // actualizar UI: velocidad, altitud, desnivel, ETA calculado, etc.
//   });

//   // al iniciar:
//   await traceService.startTracking();

//   // para mostrar trazas offline:
//   final traces = await traceService
//       .getAllTraces(); // ordenadas por id/timestamp
//   // muestra en mapa (e.g. flutter_map o google_maps_flutter)
// }

Future<void> _onStopTracking(
  TrackingMapStopTracking event,
  Emitter<TrackingMapState> emit,
) async {}
