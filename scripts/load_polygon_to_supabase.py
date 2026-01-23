import json
import psycopg2
import os
from urllib.parse import quote_plus  # <--- IMPORTANTE: Importar esto

# --- CONFIGURACIÓN ---

# 1. Coloca tu contraseña real aquí
RAW_PASSWORD = "8rXnjzoiMhyQ6e48" 

# 2. Codificamos la contraseña para que los símbolos (%, #, !) no rompan la URL
ENCODED_PASSWORD = quote_plus(RAW_PASSWORD)

# 3. Construimos la cadena de conexión con la contraseña codificada
# Reemplaza 'db.tu_proyecto.supabase.co' con tu host real
HOST = "db.uolttugqyggzheuwblht.supabase.co" 
PORT = "5432"
DB_NAME = "postgres"

DB_CONNECTION = f"postgresql://postgres:{ENCODED_PASSWORD}@{HOST}:{PORT}/{DB_NAME}"

# ... (El resto del script load_all_layers sigue igual)
# Mapeo: 'Nombre de tu archivo JSON' : 'Nombre de la tabla en geo_core'
FILES_CONFIG = {
    # 'assets/data/polygons/departments_sim_1_cleaned.json': 'departments',
    # 'assets/data/polygons/provinces_sim_1_cleaned.json': 'provinces',
    # 'assets/data/polygons/protected_areas_sim_5_cleaned.json': 'protected_areas',
    'assets/data/polygons/water_fonts_sim_5_cleaned.json': 'water_fonts'
}

def load_all_layers():
    conn = None
    try:
        print("🔌 Conectando a Supabase...")
        conn = psycopg2.connect(DB_CONNECTION)
        conn.autocommit = False # Controlamos la transacción manualmente
        cursor = conn.cursor()

        for file_name, table_name in FILES_CONFIG.items():
            
            if not os.path.exists(file_name):
                print(f"⚠️ Archivo no encontrado: {file_name}. Saltando...")
                continue

            print(f"\n📂 Procesando: {file_name} -> Tabla: geo_core.{table_name}")
            
            with open(file_name, 'r', encoding='utf-8') as f:
                data = json.load(f)

            features = data.get('features', [])
            print(f"   ↳ Insertando {len(features)} registros...")

            count = 0
            for feature in features:
                props = feature.get('properties', {})
                geometry = feature.get('geometry', {})
                
                # Ajusta estas claves según el JSON específico de cada archivo
                name = props.get('name', 'Sin Nombre')
                # Algunos JSONs usan 'in1', otros 'id', otros 'code'. Ajustar aquí si varía.
                external_code = props.get('in1', props.get('id', None)) 
                
                geojson_str = json.dumps(geometry)

                # Inyección SQL segura del nombre de la tabla (validado contra el dict arriba)
                sql = f"""
                    INSERT INTO geo_core.{table_name} (name, in1, boundary)
                    VALUES (
                        %s, 
                        %s, 
                        ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))::geography
                    );
                """

                cursor.execute(sql, (name, external_code, geojson_str))
                count += 1
            
            print(f"   ✅ {table_name}: {count} insertados.")

        conn.commit()
        print("\n🚀 PROCESO FINALIZADO CON ÉXITO.")

    except Exception as e:
        print(f"\n❌ ERROR CRÍTICO: {e}")
        if conn:
            print("   Revertiendo cambios (Rollback)...")
            conn.rollback()
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    load_all_layers()