#!/usr/bin/env python3
"""
Script para combinar múltiples archivos GeoJSON de puntos en un solo archivo.
Junta todas las features sin modificarlas.

Uso:
    python merge_geojson_points.py --output <archivo_salida.geojson> <archivo1.geojson> <archivo2.geojson> ...

Ejemplo:
    python merge_geojson_points.py --output all_points.geojson peaks.geojson lakes.geojson passes.geojson
"""

import json
import argparse
from pathlib import Path


def load_geojson(file_path: str) -> dict:
    """Carga un archivo GeoJSON."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_geojson(data: dict, file_path: str) -> None:
    """Guarda datos en un archivo GeoJSON."""
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def validate_point_geometry(feature: dict, file_name: str) -> bool:
    """
    Valida que una feature tenga geometría de tipo Point.
    
    Args:
        feature: Feature GeoJSON a validar
        file_name: Nombre del archivo (para mensajes de error)
    
    Returns:
        True si es un punto válido, False en caso contrario
    """
    geometry = feature.get("geometry", {})
    geom_type = geometry.get("type")
    
    if geom_type != "Point":
        feature_id = feature.get("id", "sin id")
        print(f"  ⚠️  Advertencia: Feature '{feature_id}' en '{file_name}' tiene geometría '{geom_type}', se omitirá.")
        return False
    
    return True


def merge_geojson_files(input_files: list[str], validate_points: bool = True) -> dict:
    """
    Combina múltiples archivos GeoJSON en uno solo.
    
    Args:
        input_files: Lista de rutas a archivos GeoJSON
        validate_points: Si True, solo incluye features con geometría Point
    
    Returns:
        GeoJSON combinado con todas las features
    """
    all_features = []
    total_files = len(input_files)
    
    for i, file_path in enumerate(input_files, 1):
        file_name = Path(file_path).name
        print(f"[{i}/{total_files}] Procesando: {file_name}")
        
        try:
            geojson_data = load_geojson(file_path)
        except json.JSONDecodeError as e:
            print(f"  ❌ Error al parsear JSON: {e}")
            continue
        except FileNotFoundError:
            print(f"  ❌ Archivo no encontrado: {file_path}")
            continue
        
        features = geojson_data.get("features", [])
        features_count = 0
        
        for feature in features:
            if validate_points:
                if validate_point_geometry(feature, file_name):
                    all_features.append(feature)
                    features_count += 1
            else:
                all_features.append(feature)
                features_count += 1
        
        print(f"  ✓ {features_count} features agregadas")
    
    # Crear el GeoJSON combinado
    merged_geojson = {
        "type": "FeatureCollection",
        "features": all_features
    }
    
    return merged_geojson


def main():
    parser = argparse.ArgumentParser(
        description="Combina múltiples archivos GeoJSON de puntos en uno solo"
    )
    parser.add_argument(
        "input_files",
        nargs="+",
        help="Archivos GeoJSON a combinar (mínimo 2)"
    )
    parser.add_argument(
        "--output", "-o",
        required=True,
        help="Ruta al archivo GeoJSON de salida"
    )
    parser.add_argument(
        "--no-validate",
        action="store_true",
        help="Desactivar validación de geometría Point (incluir cualquier tipo)"
    )
    
    args = parser.parse_args()
    
    # Verificar que se proporcionaron al menos 2 archivos
    if len(args.input_files) < 2:
        print("Error: Se requieren al menos 2 archivos GeoJSON para combinar")
        return 1
    
    # Verificar que los archivos existen
    missing_files = []
    for file_path in args.input_files:
        if not Path(file_path).exists():
            missing_files.append(file_path)
    
    if missing_files:
        print("Error: Los siguientes archivos no existen:")
        for f in missing_files:
            print(f"  - {f}")
        return 1
    
    print(f"\n📁 Combinando {len(args.input_files)} archivos GeoJSON...\n")
    
    # Combinar los archivos
    merged = merge_geojson_files(args.input_files, validate_points=not args.no_validate)
    
    # Guardar el resultado
    print(f"\n💾 Guardando resultado en: {args.output}")
    save_geojson(merged, args.output)
    
    print(f"\n✅ ¡Listo! Total de features combinadas: {len(merged['features'])}")
    
    return 0


if __name__ == "__main__":
    exit(main())
