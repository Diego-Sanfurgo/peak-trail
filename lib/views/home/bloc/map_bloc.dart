import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:peak_trail/controllers/location_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/environment/env.dart';
import 'package:peak_trail/models/mountain.dart';
import 'package:peak_trail/persistence/mountains/mountains_repository.dart';
import 'package:peak_trail/views/home/functions/add_mountains.dart';

import '../functions/filter_visible_points.dart';
import '../functions/setup_tracking.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapStatus(isLoading: true)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapReload>(_onReload);
    on<MapCameraChanged>(_onCameraChanged);
    on<MapStyleLoaded>(_onStyleLoaded);
    on<MapCameraToMe>(_onCameraToMe);
  }

  MapboxMap? _controller;
  final MountainsRepository _mountainsRepository = MountainsRepository();
  final LocationService _locationService = LocationService.instance;

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
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
        showAccuracyRing: true,
        pulsingMaxRadius: 50,
        pulsingColor: Colors.green.toARGB32(),
      ),
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
      await _mountainsRepository.getGeoJsonMountains(),
    );

    // setupPositionTracking(_controller!);

    emit(MapStatus(isLoading: false, mountains: []));
    add(MapCameraToMe());
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

  Future<void> _onCameraToMe(
    MapCameraToMe event,
    Emitter<MapState> emit,
  ) async {
    geo.Position? position = _locationService.lastPosition;
    if (position == null) return;

    _controller?.flyTo(
      CameraOptions(
        zoom: 12,
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _onStyleLoaded(
    MapStyleLoaded event,
    Emitter<MapState> emit,
  ) async {}
}
