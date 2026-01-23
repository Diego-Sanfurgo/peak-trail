import json
import os

def redondear_coords(coords, decimales=6):
    """Redondea coordenadas recursivamente para Polígonos y MultiPolígonos."""
    if isinstance(coords, (list, tuple)):
        if len(coords) > 0 and isinstance(coords[0], (int, float)):
            # Es un par de coordenadas [lon, lat]
            return [round(c, decimales) for c in coords]
        else:
            # Es una lista de listas (anillo o polígono)
            return [redondear_coords(c, decimales) for c in coords]
    return coords

def procesar_geojson(archivo_entrada, archivo_salida):
    print(f"🔄 Procesando: {archivo_entrada}...")
    
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        features_limpios = []
        
        for feature in data.get('features', []):
            props = feature.get('properties', {})
            geom = feature.get('geometry', {})
            
            # 1. Limpieza de Propiedades
            nuevas_props = {
                "name": props.get("name", "Sin Nombre"), # Mapeo fna -> name
            }
            if "in1" in props:
                nuevas_props["in1"] = props["in1"]
            
            # 2. Redondeo de Geometría (Optimización de Peso)
            if geom:
                geom['coordinates'] = redondear_coords(geom['coordinates'], 6)
            
            # 3. Reconstrucción del Feature
            nuevo_feature = {
                "type": "Feature",
                "geometry": geom,
                "properties": nuevas_props
                # Nota: El ID lo generará Supabase, no lo enviamos aquí
            }
            features_limpios.append(nuevo_feature)
            
        nuevo_geojson = {
            "type": "FeatureCollection",
            "features": features_limpios
        }
        
        # Guardar archivo optimizado
        with open(archivo_salida, 'w', encoding='utf-8') as f:
            json.dump(nuevo_geojson, f, separators=(',', ':')) # Separators quita espacios en blanco extra
            
        print(f"✅ Éxito. Archivo guardado en: {archivo_salida}")
        print(f"📉 Cantidad de polígonos procesados: {len(features_limpios)}")
        
    except FileNotFoundError:
        print(f"❌ Error: El archivo {archivo_entrada} no se encontró.")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")

# --- CONFIGURACIÓN ---
# Cambia este nombre por el de tu archivo actual
archivo_origen = 'assets/data/polygons/water_fonts_sim_5.json' 
archivo_destino = 'assets/data/polygons/water_fonts_sim_5_cleaned.json'

# Ejecutar
if __name__ == "__main__":
    procesar_geojson(archivo_origen, archivo_destino)