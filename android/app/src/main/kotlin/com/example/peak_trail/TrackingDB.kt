import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import java.io.File

@Database(entities = [TrackingPointEntity::class], version = 1, exportSchema = false)
abstract class TrackingDatabase : RoomDatabase() {
    abstract fun trackingDao(): TrackingDao

    companion object {
        @Volatile
        private var INSTANCE: TrackingDatabase? = null

        fun getDatabase(context: Context): TrackingDatabase {
            return INSTANCE ?: synchronized(this) {
                // RUTA CRÍTICA: Debe coincidir con Flutter
                // Flutter 'getApplicationDocumentsDirectory' -> context.filesDir.parent + "/app_flutter"
                // Ojo: Verifica la ruta exacta imprimiéndola en Flutter primero. 
                // A menudo es más seguro pasar la ruta desde Flutter al iniciar el servicio nativo.
                
                // Opción A: Asumiendo que Flutter usa getApplicationDocumentsDirectory
                val flutterDir = File(context.filesDir.parent, "app_flutter")
                if (!flutterDir.exists()) flutterDir.mkdirs()
                val dbFile = File(flutterDir, "tracking.db")

                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    TrackingDatabase::class.java,
                    dbFile.absolutePath
                )
                .enableMultiInstanceInvalidation()
                .addCallback(object : RoomDatabase.Callback() {
                    override fun onOpen(db: SupportSQLiteDatabase) {
                        super.onOpen(db)
                        // IMPORTANTE: Habilitar WAL en el lado nativo también
                        db.query("PRAGMA journal_mode=WAL;").close()
                    }
                })
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}