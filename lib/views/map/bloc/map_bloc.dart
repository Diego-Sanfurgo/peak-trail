import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:peak_trail/environment/env.dart';
import 'package:permission_handler/permission_handler.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    _init();
    on<MapCreated>((event, emit) async {
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
      PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(-77.0369, 38.9072)),
        iconImage: "airport-15",
        iconSize: 1.5,
      );
      pointAnnotationManager.createMulti([pointAnnotationOptions]);
      _setupPositionTracking();
    });
  }
  late final MapboxMap _controller;
  StreamSubscription? _userPositionStream;

  Future<void> _init() async {
    MapboxOptions.setAccessToken(Environment.mapboxToken);
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();
    log(statuses.toString());
  }

  Future<void> _setupPositionTracking() async {
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
