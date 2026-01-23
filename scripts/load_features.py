import json
import os
import psycopg2
from psycopg2 import extras

# CONFIGURACIÓN
# Reemplaza con tu cadena de conexión de Supabase (Settings -> Database -> Connection String -> URI)
DB_CONNECTION_STRING = "postgresql://postgres:4DEZ5PpFIsQl7VO4@db.uolttugqyggzheuwblht.supabase.co:5432/postgres"
GEOJSON_FILE_PATH = 'assets/data/points/poi.geojson'

def load_geojson_to_db():
    try:
        # 1. Conexión a Base de Datos
        print("🔌 Conectando a Supabase...")
        conn = psycopg2.connect(DB_CONNECTION_STRING)
        cur = conn.cursor()

        # 2. Leer GeoJSON
        print(f"📂 Leyendo archivo: {GEOJSON_FILE_PATH}")
        with open(GEOJSON_FILE_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)

        features = data.get('features', [])
        print(f"📊 Procesando {len(features)} puntos...")

        # 3. Preparar datos para inserción masiva (Batch Insert)
        records_to_insert = []
        
        for feature in features:
            props = feature.get('properties', {})
            geom = feature.get('geometry', {})
            
            # Extraer coordenadas [lon, lat]
            coords = geom.get('coordinates', [0, 0])
            lon, lat = coords[0], coords[1]
            
            # Datos a insertar
            # Nota: No insertamos state_id ni district_id manualmente. 
            # Dejamos que el TRIGGER de la base de datos los calcule.
            records_to_insert.append((
                props.get('name'),
                props.get('alt'),
                props.get('type', 'unknown'), # Default si es nulo
                f"SRID=4326;POINT({lon} {lat})" # Formato EWKT para PostGIS
            ))

        # 4. Ejecutar INSERT (Upsert si fuera necesario, aqui es Insert simple)
        # Insertamos directamente en geo_core.places
        sql = """
            INSERT INTO geo_core.places (name, alt, type, geom)
            VALUES %s
        """
        
        extras.execute_values(cur, sql, records_to_insert)
        
        conn.commit()
        print(f"✅ Éxito: Se cargaron {len(records_to_insert)} registros.")
        print("   (Los triggers se ejecutaron automáticamente para asignar distritos y estados)")

    except Exception as e:
        print(f"❌ Error crítico: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            cur.close()
            conn.close()

if __name__ == "__main__":
    load_geojson_to_db()