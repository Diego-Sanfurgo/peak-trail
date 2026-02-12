// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:saltamontes/data/models/base_point.dart';

// // Variable de estado en tu clase (State o Controller)
// // Key: ID de tu BasePoint (ej. "cerro_123")
// // Value: La PointAnnotation generada por Mapbox

// Future<void> updateMapMarkers(
//   List<BasePoint> nextVisiblePoints,
//   PointAnnotationManager pointAnnotationManager,
//   Map<String, PointAnnotation> activeAnnotations,
// ) async {
//   // 1. Identificar qué IDs queremos mostrar
//   final Set<String> nextIds = nextVisiblePoints.map((p) => p.id).toSet();

//   // 2. Identificar qué IDs ya tenemos dibujados
//   final Set<String> currentIds = activeAnnotations.keys.toSet();

//   // --- CALCULAR DIFERENCIAS ---

//   // A. Puntos a ELIMINAR (Están dibujados pero ya no son visibles)
//   final List<String> idsToRemove = currentIds.difference(nextIds).toList();

//   // B. Puntos a AGREGAR (Son visibles pero no están dibujados aún)
//   final List<String> idsToAdd = nextIds.difference(currentIds).toList();

//   // --- EJECUTAR CAMBIOS EN MAPBOX ---

//   // 1. Eliminar los que salen de pantalla
//   if (idsToRemove.isNotEmpty) {
//     final List<PointAnnotation> annotationsToRemove = [];
//     for (final id in idsToRemove) {
//       if (activeAnnotations.containsKey(id)) {
//         annotationsToRemove.add(activeAnnotations[id]!);
//         activeAnnotations.remove(id); // Limpiar registro local
//       }
//     }
//     // Borrado en lote (más eficiente)
//     await pointAnnotationManager?.delete(annotationsToRemove);
//   }

//   // 2. Agregar los nuevos que entran en pantalla
//   if (idsToAdd.isNotEmpty) {
//     final List<PointAnnotationOptions> optionsList = [];

//     // Mapeamos los IDs a los objetos BasePoint completos para crear las opciones
//     // Optimizacion: Creamos un mapa temporal para buscar rápido el objeto por ID
//     final pointsMap = {for (var p in nextVisiblePoints) p.id: p};

//     for (final id in idsToAdd) {
//       final pointData = pointsMap[id];
//       if (pointData != null) {
//         // Configuramos el diseño del punto
//         final options = PointAnnotationOptions(
//           geometry: Point(coordinates: pointData.geometry.toMapboxPosition()),
//           icon: 'tu_icono_cerro', // Asegúrate de haber cargado la imagen antes
//           iconSize: 1.0,
//           textField: pointData.properties.name, // Opcional: mostrar nombre
//           textOffset: [0, 2.0],
//           // IMPORTANTE: Guardamos el ID en el data json para recuperarlo en clicks
//           customData: {'id': pointData.properties.id, 'type': 'cerro'},
//         );
//         optionsList.add(options);
//       }
//     }

//     // Creación en lote
//     final newAnnotations = await pointAnnotationManager?.createMulti(
//       optionsList,
//     );

//     // Actualizar nuestro registro local (_activeAnnotations)
//     // Mapbox devuelve las anotaciones creadas en el mismo orden
//     if (newAnnotations != null) {
//       for (int i = 0; i < newAnnotations.length; i++) {
//         // Necesitamos saber a qué ID corresponde esta anotación.
//         // Como 'idsToAdd' y 'optionsList' tienen el mismo orden, usamos el índice.
//         final originalId = idsToAdd[i];
//         activeAnnotations[originalId] = newAnnotations[i]!;
//       }
//     }
//   }

//   // Nota: Los puntos que están en la intersección (visibles antes y ahora)
//   // no se tocan. Se quedan estáticos, evitando el parpadeo.
// }
