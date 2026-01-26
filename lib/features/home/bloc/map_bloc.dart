import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:peak_trail/core/services/layer_service.dart';
import 'package:peak_trail/features/home/dto/selected_feature_dto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/core/services/location_service.dart';
import 'package:peak_trail/core/utils/constant_and_variables.dart';

import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/repositories/map_repository.dart';

import 'package:peak_trail/features/home/functions/on_map_tap_listener.dart';

import 'package:peak_trail/data/providers/tracking_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required TrackingMapRepository mapRepository})
    : _mapRepo = mapRepository,
      super(MapStatus(isLoading: true)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapReload>(_onReload);
    on<MapCameraIdle>(_onCameraIdle);
    on<MapMoveCamera>(_onMoveCamera);
  }

  MapboxMap? _controller;
  final TrackingMapRepository _mapRepo;
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

    // await LayerService.addMountainAreaAll(_controller!);
    await LayerService.addPlacesSource(_controller!);

    // final supabase = Supabase.instance.client;

    // final List<FileObject> layers = await supabase.storage
    //     .from('map_layers')
    //     .list(path: 'points/poi.geojson');

    // for (var layer in layers) {
    //   try {
    //     if (layer.name == '.emptyFolderPlaceholder') continue;

    //     log('Downloading layer: ${layer.name}');
    //     final Uint8List bytes = await supabase.storage
    //         .from('map_layers')
    //         .download(layer.name);

    //     final String geoJson = utf8.decode(bytes);
    //     final Map<String, dynamic> data = jsonDecode(geoJson);

    //     final String sourceId = layer.name
    //         .replaceAll('.geojson', '')
    //         .replaceAll('.json', '');

    //     // Determine geometry type
    //     String? geometryType;
    //     final type = data['type'];
    //     if (type == 'FeatureCollection') {
    //       final List features = data['features'];
    //       if (features.isNotEmpty) {
    //         geometryType = features[0]['geometry']['type'];
    //       }
    //     } else if (type == 'Feature') {
    //       geometryType = data['geometry']?['type'];
    //     }

    //     if (geometryType != null) {
    //       log('Layer ${layer.name} type: $geometryType');
    //       if (geometryType.contains('Polygon')) {
    //         await LayerService.addPolygonLayers(
    //           _controller!,
    //           geoJson,
    //           sourceId,
    //         );
    //       } else if (geometryType.contains('Point')) {
    //         final sourceIdFinal = sourceId.contains('cerro')
    //             ? MapConstants.peakID
    //             : sourceId.contains('cascada')
    //             ? MapConstants.waterfallID
    //             : sourceId.contains('portezuelo')
    //             ? MapConstants.mountainPassID
    //             : sourceId;
    //         LayerService.addPointLayers(_controller!, geoJson, sourceIdFinal);
    //       } else if (geometryType.contains('LineString')) {
    //         await LayerService.addPolygonLayers(
    //           _controller!,
    //           geoJson,
    //           sourceId,
    //         );
    //       }
    //     }
    //   } catch (e) {
    //     log('Error processing layer ${layer.name}: $e');
    //   }
    // }

    // await Future.wait([
    //   LayerService.addPointLayers(
    //     _controller!,
    //     await _mapRepo.getPeaksJson(asString: true),
    //     MapConstants.peakID,
    //   ),
    //   LayerService.addPointLayers(
    //     _controller!,
    //     await _mapRepo.getWaterfallJson(),
    //     MapConstants.waterfallID,
    //   ),
    //   LayerService.addPointLayers(
    //     _controller!,
    //     await _mapRepo.getPassJson(),
    //     MapConstants.mountainPassID,
    //   ),
    // ]);

    // final tapStream = addOnMapTapListener(_controller!, [
    //   MapConstants.peakID,
    //   MapConstants.waterfallID,
    //   MapConstants.mountainPassID,
    // ]);

    // tapStream.listen((selectedFeature) async {
    //   if (_selectedFeatureDTO.featureId.isNotEmpty) {
    //     await _controller!.setFeatureState(
    //       _selectedFeatureDTO.sourceID,
    //       null,
    //       _selectedFeatureDTO.featureId,
    //       jsonEncode({'selected': false}),
    //     );
    //   }

    //   await _controller!.setFeatureState(
    //     selectedFeature.sourceID,
    //     null,
    //     selectedFeature.featureId,
    //     jsonEncode({'selected': true}),
    //   );
    //   _selectedFeatureDTO = selectedFeature;
    // });

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
}

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
