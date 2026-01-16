import 'package:flutter/material.dart';
import '../../core/services/trace_service.dart';
import '../../data/providers/tracking_database.dart';

class LocationDebugScreen extends StatefulWidget {
  final TrackingDatabase database; // Pásale la instancia de tu DB

  const LocationDebugScreen({super.key, required this.database});

  @override
  State<LocationDebugScreen> createState() => _LocationDebugScreenState();
}

class _LocationDebugScreenState extends State<LocationDebugScreen> {
  final TraceService _traceService = TraceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug de Ubicación")),
      body: Column(
        children: [
          // Botones de Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _traceService.startTracking(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Iniciar Tracking"),
              ),
              ElevatedButton(
                onPressed: () => _traceService.stopTracking(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Detener"),
              ),
            ],
          ),
          const Divider(),
          // Monitor de Base de Datos
          Expanded(
            child: StreamBuilder<List<TrackingPoint>>(
              stream: Stream.periodic(
                const Duration(seconds: 2),
              ).asyncMap((_) => widget.database.getAllPoints()),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final points = snapshot.data!;

                if (points.isEmpty) {
                  return const Center(child: Text("Esperando puntos..."));
                }

                // Mostrar el último punto arriba
                final lastPoint = points.last;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Puntos capturados: ${points.length}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Último: ${lastPoint.latitude}, ${lastPoint.longitude}",
                      ),
                      subtitle: Text(
                        "Velocidad: ${lastPoint.speed} m/s\nTimestamp: ${lastPoint.timestamp}",
                      ),
                      leading: const Icon(Icons.my_location),
                    ),
                    const Divider(),
                    // Lista de los últimos 10 puntos para ver si fluye
                    Expanded(
                      child: ListView.builder(
                        itemCount: points.length > 20
                            ? 20
                            : points.length, // Mostrar solo últimos 20
                        itemBuilder: (context, index) {
                          // Invertir orden para ver el más nuevo primero
                          final point = points[points.length - 1 - index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              "${point.latitude}, ${point.longitude}",
                            ),
                            subtitle: Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                point.timestamp,
                              ).toString(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
