import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/core/environment/env.dart';
import 'package:peak_trail/core/services/location_service.dart';
import 'package:peak_trail/core/services/navigation_service.dart';

import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/repositories/peaks_repository.dart';
import 'package:peak_trail/persistence/tracking/tracking_database.dart';

import 'package:peak_trail/features/home/functions/add_mountains.dart';
import 'package:peak_trail/features/home/functions/add_tracking_polyline.dart';

import '../functions/filter_visible_points.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._actualUri) : super(MapStatus(isLoading: true)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapReload>(_onReload);
    on<MapCameraChanged>(_onCameraChanged);
    on<MapStyleLoaded>(_onStyleLoaded);
    on<MapMoveCamera>(_onMoveCamera);
    on<MapStartTracking>(_onStartTracking);
    on<MapNavigateToSearch>(_onNavigateToSearch);
  }

  MapboxMap? _controller;
  final PeaksRepository _mountainsRepository = PeaksRepository();
  final LocationService _locationService = LocationService.instance;
  final Uri _actualUri;

  Future<void> _init() async {
    MapboxOptions.setAccessToken(Environment.mapboxToken);
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

    // PointAnnotationManager pointAnnotationManager = await _controller
    //     .annotations
    //     .createPointAnnotationManager();

    // Set<Mountain> mountainList = await _mountainsRepository.getMountains();

    // final mountainIcon = await ImageController.loadImage(
    //   AppAssets.mountainIcon,
    // );

    // List<PointAnnotationOptions> annotations = [];
    // for (var mountain in mountainList.take(100)) {
    //   annotations.add(
    //     PointAnnotationOptions(
    //       geometry: Point(
    //         coordinates: Position(
    //           mountain.coordinates.lng,
    //           mountain.coordinates.lat,
    //         ),
    //       ),
    //       image: mountainIcon,
    //       // iconImage: "mountain-15",
    //       iconSize: 0.1,
    //       textField: mountain.properties.nam,
    //       textOffset: [0, 1.5],
    //     ),
    //   );
    // }

    // await pointAnnotationManager.createMulti(annotations);
    // pointAnnotationManager.tapEvents(
    //   onTap: (PointAnnotation annotation) {
    //     log('Tapped mountain: ${annotation.textField}');
    //     log(annotation.geometry.coordinates.toJson().toString());
    //   },
    // );

    await addMountainsLayers(
      _controller!,
      await _mountainsRepository.getPeaksJson(),
    );

    // setupPositionTracking(_controller!);

    // _locationTracking();

    emit(MapStatus(isLoading: false, mountains: []));
    add(MapMoveCamera());

    // emit(MapStatus(isLoading: false, mountains: mountainList.toList()));
  }

  Future<void> _onReload(MapReload event, Emitter<MapState> emit) async {
    emit(MapStatus(isLoading: false));
  }

  Future<void> _onCameraChanged(
    MapCameraChanged event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;
    await filterVisiblePoints(_controller!, event.cameraState);
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

  Future<void> _onStyleLoaded(
    MapStyleLoaded event,
    Emitter<MapState> emit,
  ) async {}

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

  Future<void> _onNavigateToSearch(
    MapNavigateToSearch event,
    Emitter<MapState> emit,
  ) async {
    NavigationService.go(Routes.SEARCH, actualUri: _actualUri);
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

Future<void> ajustarCamaraATodaLaRuta(
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
