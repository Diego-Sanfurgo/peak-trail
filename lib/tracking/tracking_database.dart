import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'tracking_database.g.dart';

// Definición de la tabla
class TrackingPoints extends Table {
  // Drift generará "id" automáticamente como PK autoincrementable
  IntColumn get id => integer().autoIncrement()();

  // Nombres explícitos para coincidir con el nativo
  RealColumn get latitude => real().named('latitude')();
  RealColumn get longitude => real().named('longitude')();
  RealColumn get altitude => real().nullable().named('altitude')();
  RealColumn get speed => real().nullable().named('speed')();
  RealColumn get accuracy => real().nullable().named('accuracy')();

  // Guardamos timestamp como entero (milisegundos) para facilitar interoperabilidad
  IntColumn get timestamp => integer().named('timestamp')();
}

@DriftDatabase(tables: [TrackingPoints])
class TrackingDatabase extends _$TrackingDatabase {
  TrackingDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Stream para ver el track en vivo en el mapa
  Stream<List<TrackingPoint>> watchAllPoints() {
    return (select(
      trackingPoints,
    )..orderBy([(t) => OrderingTerm(expression: t.timestamp)])).watch();
  }

  // Obtener todo el historial
  Future<List<TrackingPoint>> getAllPoints() => select(trackingPoints).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // IMPORTANTE: Esta carpeta debe ser accesible por el código nativo también.
    // En Android, getApplicationDocumentsDirectory suele ser 'app_flutter'.
    // A veces es mejor usar getDatabasesPath() de sqflite si quieres la carpeta standard de DBs.
    // Por ahora usaremos Documents que es seguro.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tracking.db'));

    return NativeDatabase(
      file,
      // Habilitar WAL es OBLIGATORIO para lectura/escritura simultánea
      setup: (database) {
        database.execute('PRAGMA journal_mode=WAL;');
      },
    );
  });
}
