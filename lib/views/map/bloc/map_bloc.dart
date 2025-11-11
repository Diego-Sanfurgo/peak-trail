import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:peak_trail/controllers/image_controller.dart';
import 'package:peak_trail/environment/env.dart';
import 'package:peak_trail/models/mountain.dart';
import 'package:peak_trail/persistence/mountains/mountains_repository.dart';
import 'package:permission_handler/permission_handler.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapStatus(isLoading: true)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapLoad>(_onLoad);
  }

  late final MapboxMap _controller;
  StreamSubscription? _userPositionStream;
  final MountainsRepository _mountainsRepository = MountainsRepository();

  Future<void> _init() async {
    MapboxOptions.setAccessToken(Environment.mapboxToken);
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();
    log(statuses.toString());
    add(MapLoad());
  }

  Future<void> _onCreated(MapCreated event, Emitter<MapState> emit) async {
    _controller = event.controller;

    _controller.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        // showAccuracyRing: true,
        // locationPuck: LocationPuck(
        //   locationPuck2D: LocationPuck2D(),
        //   // locationPuck3D: LocationPuck3D(
        //   //   modelUri:
        //   //       "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf",
        //   // ),
        // ),
      ),
    );

    PointAnnotationManager pointAnnotationManager = await _controller
        .annotations
        .createPointAnnotationManager();

    Set<Mountain> mountainList = await _mountainsRepository.getMountains();

    final mountainIcon = await ImageController.loadImage(
      AppAssets.mountainIcon,
    );

    List<PointAnnotationOptions> annotations = [];
    for (var mountain in mountainList.take(100)) {
      annotations.add(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              mountain.coordinates.lng,
              mountain.coordinates.lat,
            ),
          ),
          image: mountainIcon,
          // iconImage: "mountain-15",
          iconSize: 0.1,
          textField: mountain.properties.nam,
          textOffset: [0, 1.5],
        ),
      );
    }

    await pointAnnotationManager.createMulti(annotations);
    pointAnnotationManager.tapEvents(
      onTap: (PointAnnotation annotation) {
        log('Tapped mountain: ${annotation.textField}');
        log(annotation.geometry.coordinates.toJson().toString());
      },
    );
    _setupPositionTracking();

    emit(MapStatus(isLoading: false, mountains: mountainList.toList()));
  }

  Future<void> _onLoad(MapLoad event, Emitter<MapState> emit) async {
    emit(MapStatus(isLoading: false));
  }

  void _setupPositionTracking() {
    geo.LocationSettings settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.best,
      distanceFilter: 50,
    );
    _userPositionStream?.cancel();
    _userPositionStream =
        geo.Geolocator.getPositionStream(locationSettings: settings).listen((
          geo.Position? position,
        ) {
          if (position != null) {
            _controller.setCamera(
              CameraOptions(
                zoom: 12,
                center: Point(
                  coordinates: Position(position.longitude, position.latitude),
                ),
              ),
            );
          }
        });
  }
}
