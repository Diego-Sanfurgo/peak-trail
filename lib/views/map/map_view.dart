import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'bloc/map_bloc.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(),
      child: const _MapViewWidget(),
    );
  }
}

class _MapViewWidget extends StatefulWidget {
  const _MapViewWidget();

  @override
  State<_MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<_MapViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: _MapboxWidget(),
    );
  }
}

class _MapboxWidget extends StatefulWidget {
  const _MapboxWidget();

  @override
  State<_MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<_MapboxWidget> {
  MapboxMap? mapController;
  late final MapBloc bloc;
  // Timer? idleTimer;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MapBloc>(context);
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        state as MapStatus;

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return MapWidget(
          key: ValueKey("map_widget"),
          onMapCreated: (controller) {
            mapController = controller;
            bloc.add(MapCreated(controller));
          },
          mapOptions: MapOptions(pixelRatio: 2),
          cameraOptions: CameraOptions(zoom: 5),
          onCameraChangeListener: (cameraChangedEventData) {
            if (mapController == null) return;
            // idleTimer?.cancel();
            // idleTimer = Timer(const Duration(milliseconds: 600), () async {
            //   // await _onCameraIdle();
            //   bloc.add(MapCameraChanged(cameraChangedEventData.cameraState));
            // });
            bloc.add(MapCameraChanged(cameraChangedEventData.cameraState));
          },
        );
      },
    );
  }
}
