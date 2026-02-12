import 'dart:async';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:peak_trail/core/services/navigation_service.dart';
import 'package:peak_trail/features/map/widgets/mocked_search_bar.dart';

import '../home/bloc/map_bloc.dart';
import 'widgets/floating_chips.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MapViewWidget();
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
    return Scaffold(body: SafeArea(child: _Body()));
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _MapboxWidget(),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            spacing: 8,
            children: [
              FloatingActionButton(
                heroTag: Key("tracking_FAB"),
                child: Icon(Icons.play_circle_outlined),
                onPressed: () => NavigationService.go(Routes.TRACKING_MAP),
              ),
              FloatingActionButton(
                heroTag: Key("location_FAB"),
                child: Icon(Icons.my_location_outlined),
                onPressed: () =>
                    BlocProvider.of<MapBloc>(context).add(MapMoveCamera()),
              ),
            ],
          ),
        ),

        Positioned(
          top: 84,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: Key("layer_FAB"),
            child: Icon(Icons.layers_outlined),
            onPressed: () {},
          ),
        ),

        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => NavigationService.go(
                    Routes.SEARCH,
                    actualUri: GoRouterState.of(context).uri,
                  ),
                  child: MockedSearchBar(),
                ),
              ),
              FloatingChips(),
            ],
          ),
        ),
      ],
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
  Timer? idleTimer;

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
          // key: ValueKey("map_widget"),
          key: const PageStorageKey('pathfinder-map'),
          onMapCreated: (controller) {
            mapController = controller;
            controller.attribution.updateSettings(
              AttributionSettings(marginBottom: 24, marginLeft: 88),
            );
            controller.compass.updateSettings(
              CompassSettings(marginTop: 140, marginRight: 16),
            );
            controller.logo.updateSettings(LogoSettings(marginBottom: 24));
            controller.scaleBar.updateSettings(
              ScaleBarSettings(
                position: OrnamentPosition.BOTTOM_LEFT,
                enabled: false,
              ),
            );
            bloc.add(MapCreated(controller));
          },
          styleUri: MapboxStyles.OUTDOORS,
          mapOptions: MapOptions(pixelRatio: 2),
          cameraOptions: CameraOptions(zoom: 5),
          onCameraChangeListener: (cameraChangedEventData) {
            if (mapController == null) return;
            idleTimer?.cancel();
            idleTimer = Timer(const Duration(milliseconds: 500), () async {
              bloc.add(MapCameraIdle(cameraChangedEventData.cameraState));
            });
          },
        );
      },
    );
  }
}
