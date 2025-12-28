import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:peak_trail/core/services/layer_service.dart';
import 'package:peak_trail/features/home/dto/selected_feature_dto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/core/services/location_service.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/repositories/map_repository.dart';

import 'package:peak_trail/features/home/functions/on_map_tap_listener.dart';
import 'package:peak_trail/features/home/functions/add_tracking_polyline.dart';

import 'package:peak_trail/persistence/tracking/tracking_database.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required MapRepository mapRepository})
    : _mapRepo = mapRepository,
      super(MapStatus(isLoading: true)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapReload>(_onReload);
    on<MapCameraIdle>(_onCameraIdle);
    on<MapMoveCamera>(_onMoveCamera);
    on<MapStartTracking>(_onStartTracking);
  }

  MapboxMap? _controller;
  final MapRepository _mapRepo;
  final LocationService _locationService = LocationService.instance;
  SelectedFeatureDTO _selectedFeatureDTO = SelectedFeatureDTO.empty();

  Future<void> _init() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();
    log(statuses.toString());
    add(MapReload());
  }

  Future<void> _onCreated(MapCreated event, Emitter<MapState> emit) async {
    _controller = event.controller;

    _controller!.location.updateSettings(
      LocationComponentSettings(enabled: true, puckBearingEnabled: true),
    );

    await Future.wait([
      LayerService.addSourceAndLayers(
        _controller!,
        await _mapRepo.getWaterfallJson(),
        MapConstants.waterfallID,
      ),
      LayerService.addSourceAndLayers(
        _controller!,
        await _mapRepo.getPeaksJson(asString: true),
        MapConstants.peakID,
      ),
    ]);

    final tapStream = addOnMapTapListener(_controller!, [
      MapConstants.peakID,
      MapConstants.waterfallID,
    ]);

    tapStream.listen((selectedFeature) async {
      if (_selectedFeatureDTO.featureId.isNotEmpty) {
        await _controller!.setFeatureState(
          _selectedFeatureDTO.sourceID,
          null,
          _selectedFeatureDTO.featureId,
          jsonEncode({'selected': false}),
        );
      }

      await _controller!.setFeatureState(
        selectedFeature.sourceID,
        null,
        selectedFeature.featureId,
        jsonEncode({'selected': true}),
      );
      _selectedFeatureDTO = selectedFeature;
    });

    emit(MapStatus(isLoading: false, mountains: []));
    add(MapMoveCamera());
  }

  Future<void> _onReload(MapReload event, Emitter<MapState> emit) async {
    emit(MapStatus(isLoading: false));
  }

  Future<void> _onCameraIdle(
    MapCameraIdle event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;
    // await filterVisiblePoints(_controller!, event.cameraState);
    // final visibleRegion = await _controller!.coordinateBoundsForCamera(
    //   event.cameraState.toCameraOptions(),
    // );

    // final Map<String, dynamic> geoJson = await _mapRepo.getPeaksJson(
    //   asString: false,
    // );
    // final List<BasePoint> visiblePoints = GeoJsonHelper.filterAndMapFeatures(
    //   geoJson: geoJson,
    //   bounds: visibleRegion,
    // );
    // updateMapMarkers(
    //   visiblePoints,
    //   _pointAnnotationManager,
    //   _activeAnnotations,
    // );
  }

  Future<void> _onMoveCamera(
    MapMoveCamera event,
    Emitter<MapState> emit,
  ) async {
    LatLng coords = event.targetLocation == null
        ? LatLng(
            _locationService.lastPosition!.latitude,
            _locationService.lastPosition!.longitude,
          )
        : event.targetLocation!;

    _controller?.flyTo(
      CameraOptions(
        zoom: event.zoomLevel ?? 14.0,
        center: Point(coordinates: Position(coords.longitude, coords.latitude)),
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _onStartTracking(
    MapStartTracking event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    // final TrackingDatabase database = TrackingDatabase();

    geo.Position? position = _locationService.lastPosition;
    if (position == null) return;

    await addTrackingPolilyne(_controller!, position);

    // await actualizarRutaEnMapa(await database.getAllPoints(), _controller);
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

Future<void> adjustCameraToTrack(
  List<TrackingPoint> puntosBackend,
  MapboxMap? controller,
) async {
  if (controller == null || puntosBackend.isEmpty) return;

  List<Point> coordenadas = puntosBackend
      .map((p) => Point(coordinates: Position(p.longitude, p.latitude)))
      .toList();

  // 1. Crear las opciones de cámara basándose en las coordenadas
  // Mapbox tiene un método nativo para calcular esto sin que hagas matemáticas manuales
  CameraOptions cameraOptions = await controller.cameraForCoordinatesPadding(
    coordenadas,
    CameraOptions(),
    MbxEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), // Padding
    null,
    null,
  );

  // 2. Mover la cámara suavemente
  await controller.flyTo(
    cameraOptions,
    MapAnimationOptions(duration: 1000), // 1 segundo de animación
  );
}
