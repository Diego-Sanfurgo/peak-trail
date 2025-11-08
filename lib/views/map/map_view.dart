import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'bloc/map_bloc.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // MapboxMap? mapboxMap;
  // StreamSubscription? userPositionStream;

  // _onMapCreated(MapboxMap mapboxMap) {
  //   this.mapboxMap = mapboxMap;

  //   mapboxMap.location.updateSettings(
  //     LocationComponentSettings(
  //       enabled: true,
  //       pulsingEnabled: true,
  //       // showAccuracyRing: true,
  //       // locationPuck: LocationPuck(
  //       //   locationPuck2D: LocationPuck2D(),
  //       //   // locationPuck3D: LocationPuck3D(
  //       //   //   modelUri:
  //       //   //       "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf",
  //       //   // ),
  //       // ),
  //     ),
  //   );
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    // _init();
  }

  // void _init() async {
  //   MapboxOptions.setAccessToken(Environment.mapboxToken);
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.location,
  //     Permission.locationAlways,
  //     Permission.locationWhenInUse,
  //   ].request();
  //   // position = await Geolocator.getCurrentPosition();
  //   log(statuses.toString());
  //   setupPositionTracking();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Map View')),
        body: _MapboxWidget(),
      ),
    );
  }

  // setupPositionTracking() async {
  //   geo.LocationSettings settings = geo.LocationSettings(
  //     accuracy: geo.LocationAccuracy.best,
  //     distanceFilter: 50,
  //   );
  //   userPositionStream?.cancel();
  //   userPositionStream =
  //       geo.Geolocator.getPositionStream(locationSettings: settings).listen((
  //         geo.Position? position,
  //       ) {
  //         if (position != null && mapboxMap != null) {
  //           mapboxMap?.setCamera(
  //             CameraOptions(
  //               zoom: 12,
  //               center: Point(
  //                 coordinates: Position(position.longitude, position.latitude),
  //               ),
  //             ),
  //           );
  //         }
  //       });
  // }
}

class _MapboxWidget extends StatelessWidget {
  const _MapboxWidget();

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: ValueKey("map_widget"),
      onMapCreated: (controller) =>
          context.read<MapBloc>().add(MapCreated(controller)),
      mapOptions: MapOptions(pixelRatio: 2),
      cameraOptions: CameraOptions(zoom: 5),
    );
  }
}
