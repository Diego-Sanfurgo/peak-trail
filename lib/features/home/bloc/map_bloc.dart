import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:saltamontes/core/services/layer_service.dart';
import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/features/home/dto/selected_feature_dto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:saltamontes/core/services/location_service.dart';

import 'package:saltamontes/features/home/functions/on_map_tap_listener.dart';

import 'package:saltamontes/data/providers/tracking_database.dart';

import '../functions/filter_mountain_areas.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(const MapState(status: MapStatus.loading)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapReload>(_onReload);
    on<MapCameraIdle>(_onCameraIdle);
    on<MapMoveCamera>(_onMoveCamera);
    on<MapChangeStyle>(_onChangeStyle);
    on<MapToggleOverlay>(_onToggleOverlay);
    on<MapFilterPlaces>(_onFilterPlaces);
  }

  MapboxMap? _controller;
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

    await LayerService.addPlacesSource(_controller!);

    final tapStream = addOnMapTapListener(_controller!, ['places']);

    tapStream.listen((selectedFeature) async {
      if (_selectedFeatureDTO.featureId.isNotEmpty) {
        await _controller!.setFeatureState(
          _selectedFeatureDTO.sourceID,
          null,
          _selectedFeatureDTO.featureId,
          jsonEncode({'selected': false}),
        );

        if (_selectedFeatureDTO.type == 'peak') {
          // await LayerService.addMountainAreaAll(_controller!);
          await filterUserMountains(_controller!, [
            _selectedFeatureDTO.featureId,
          ]);
        }
      }

      await _controller!.setFeatureState(
        selectedFeature.sourceID,
        null,
        selectedFeature.featureId,
        jsonEncode({'selected': true}),
      );
      _selectedFeatureDTO = selectedFeature;
    });

    emit(state.copyWith(status: MapStatus.loaded, places: []));
    add(MapMoveCamera());
  }

  Future<void> _onReload(MapReload event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.initial));
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

  Future<void> _onChangeStyle(
    MapChangeStyle event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;
    await _controller!.loadStyleURI(event.styleUri);

    // Re-add base layers after style change
    await LayerService.addPlacesSource(_controller!);

    // Re-add active overlays
    for (final overlayId in state.activeOverlays) {
      await _addOverlayById(overlayId);
    }

    // Re-apply place type filter if active
    await _applyPlaceTypeFilter(state.placeTypeFilter);

    emit(state.copyWith(styleUri: event.styleUri));
  }

  Future<void> _onToggleOverlay(
    MapToggleOverlay event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    final overlays = Set<String>.from(state.activeOverlays);

    if (overlays.contains(event.overlayId)) {
      // Disable: remove from set and remove layers
      overlays.remove(event.overlayId);
      await _removeOverlayById(event.overlayId);
    } else {
      // Enable: add to set and add layers
      overlays.add(event.overlayId);
      await _addOverlayById(event.overlayId);
    }

    emit(state.copyWith(activeOverlays: overlays));
  }

  Future<void> _addOverlayById(String overlayId) async {
    switch (overlayId) {
      case 'mountains-mvt-source':
        await LayerService.addMountainAreaAll(_controller!);
      default:
        log('Unknown overlay: $overlayId');
    }
  }

  Future<void> _removeOverlayById(String overlayId) async {
    switch (overlayId) {
      case 'mountains-mvt-source':
        await LayerService.removeOverlay(_controller!, 'mountains-mvt-source', [
          'mountains-fill-layer',
          'debug-lines',
        ]);
      default:
        log('Unknown overlay: $overlayId');
    }
  }

  Future<void> _onFilterPlaces(
    MapFilterPlaces event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    // Toggle: if the same type is selected, clear the filter
    final newFilter = event.placeType == state.placeTypeFilter
        ? null
        : event.placeType;

    await _applyPlaceTypeFilter(newFilter);
    emit(state.copyWith(placeTypeFilter: () => newFilter));
  }

  Future<void> _applyPlaceTypeFilter(String? placeType) async {
    if (_controller == null) return;

    const pointsLayerID = 'places-points';

    // Original filter for non-clustered points
    final baseFilter = [
      "!",
      [
        ">",
        [
          "coalesce",
          ["get", "point_count"],
          0,
        ],
        1,
      ],
    ];

    if (placeType != null) {
      // Combine base filter with type filter
      final typeFilter = [
        "all",
        baseFilter,
        [
          "==",
          ["get", "type"],
          placeType,
        ],
      ];
      await _controller!.style.setStyleLayerProperty(
        pointsLayerID,
        'filter',
        typeFilter,
      );
    } else {
      // Restore original filter (show all non-clustered points)
      await _controller!.style.setStyleLayerProperty(
        pointsLayerID,
        'filter',
        baseFilter,
      );
    }
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
