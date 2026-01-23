#!/usr/bin/env python3
"""
Script para realizar una interpolación espacial (spatial join) entre puntos y polígonos.
Agrega el nombre del polígono (obtenido de 'fna') a los puntos que caen dentro de cada polígono.

Uso:
    python spatial_join_points_polygons.py --points <archivo_puntos.geojson> \
                                           --polygons <archivo_poligonos.geojson> \
                                           --output <archivo_salida.geojson> \
                                           --attribute <nombre_atributo_nuevo>

Ejemplo:
    python spatial_join_points_polygons.py --points peaks.geojson \
                                           --polygons lakes_polygons.geojson \
                                           --output peaks_with_polygon.geojson \
                                           --attribute polygon_name
"""

import json
import argparse
from pathlib import Path
from typing import Optional


def point_in_polygon(point: list[float], polygon: list[list[float]]) -> bool:
    """
    Determina si un punto está dentro de un polígono usando el algoritmo ray casting.
    
    Args:
        point: Coordenadas [lon, lat] del punto
        polygon: Lista de coordenadas [[lon, lat], ...] del polígono (anillo exterior)
    
    Returns:
        True si el punto está dentro del polígono, False en caso contrario
    """
    x, y = point[0], point[1]
    n = len(polygon)
    inside = False
    
    j = n - 1
    for i in range(n):
        xi, yi = polygon[i][0], polygon[i][1]
        xj, yj = polygon[j][0], polygon[j][1]
        
        if ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi):
            inside = not inside
        j = i
    
    return inside


def point_in_multipolygon(point: list[float], multipolygon: list[list[list[list[float]]]]) -> bool:
    """
    Determina si un punto está dentro de un MultiPolygon.
    Un punto está dentro si está en alguno de los polígonos del MultiPolygon.
    
    Args:
        point: Coordenadas [lon, lat] del punto
        multipolygon: Lista de polígonos, cada uno con anillos [[[[lon, lat], ...], ...], ...]
    
    Returns:
        True si el punto está dentro de algún polígono, False en caso contrario
    """
    for polygon in multipolygon:
        # Cada polígono tiene al menos un anillo exterior (índice 0)
        # Los anillos siguientes son agujeros (holes)
        exterior_ring = polygon[0]
        
        if point_in_polygon(point, exterior_ring):
            # Verificar que no esté en un agujero
            in_hole = False
            for hole in polygon[1:]:
                if point_in_polygon(point, hole):
                    in_hole = True
                    break
            
            if not in_hole:
                return True
    
    return False


def point_in_geometry(point: list[float], geometry: dict) -> bool:
    """
    Determina si un punto está dentro de una geometría (Polygon o MultiPolygon).
    
    Args:
        point: Coordenadas [lon, lat] del punto
        geometry: Diccionario con 'type' y 'coordinates'
    
    Returns:
        True si el punto está dentro de la geometría, False en caso contrario
    """
    geom_type = geometry.get("type")
    coordinates = geometry.get("coordinates", [])
    
    if geom_type == "Polygon":
        # Un Polygon tiene la estructura: [[[lon, lat], ...], ...]
        # El primer elemento es el anillo exterior
        exterior_ring = coordinates[0]
        
        if point_in_polygon(point, exterior_ring):
            # Verificar que no esté en un agujero
            for hole in coordinates[1:]:
                if point_in_polygon(point, hole):
                    return False
            return True
        return False
    
    elif geom_type == "MultiPolygon":
        return point_in_multipolygon(point, coordinates)
    
    return False


def get_polygon_name(feature: dict, name_property: str = "fna") -> Optional[str]:
    """
    Obtiene el nombre de un polígono desde sus propiedades.
    
    Args:
        feature: Feature GeoJSON del polígono
        name_property: Nombre de la propiedad que contiene el nombre (default: "fna")
    
    Returns:
        El nombre del polígono o None si no existe
    """
    properties = feature.get("properties", {})
    return properties.get(name_property)


def find_containing_polygon(point_coords: list[float], polygons: list[dict], name_property: str = "fna") -> Optional[str]:
    """
    Encuentra el polígono que contiene un punto y retorna su nombre.
    
    Args:
        point_coords: Coordenadas [lon, lat] del punto
        polygons: Lista de features GeoJSON de polígonos
        name_property: Nombre de la propiedad que contiene el nombre del polígono
    
    Returns:
        El nombre del polígono que contiene el punto, o None si no hay ninguno
    """
    for polygon_feature in polygons:
        geometry = polygon_feature.get("geometry", {})
        
        if point_in_geometry(point_coords, geometry):
            return get_polygon_name(polygon_feature, name_property)
    
    return None


def spatial_join(
    points_geojson: dict,
    polygons_geojson: dict,
    new_attribute_name: str,
    polygon_name_property: str = "fna"
) -> dict:
    """
    Realiza la interpolación espacial entre puntos y polígonos.
    Agrega el nombre del polígono a cada punto que caiga dentro de él.
    
    Args:
        points_geojson: GeoJSON con los puntos
        polygons_geojson: GeoJSON con los polígonos
        new_attribute_name: Nombre del nuevo atributo a agregar en los puntos
        polygon_name_property: Nombre de la propiedad del polígono que contiene el nombre
    
    Returns:
        GeoJSON de puntos con el nuevo atributo agregado
    """
    # Obtener las features de polígonos
    polygon_features = polygons_geojson.get("features", [])
    
    # Crear una copia del GeoJSON de puntos para no modificar el original
    result = json.loads(json.dumps(points_geojson))
    
    points_processed = 0
    points_matched = 0
    
    for point_feature in result.get("features", []):
        geometry = point_feature.get("geometry", {})
        
        # Solo procesar puntos
        if geometry.get("type") != "Point":
            continue
        
        point_coords = geometry.get("coordinates", [])
        
        if len(point_coords) < 2:
            continue
        
        points_processed += 1
        
        # Buscar el polígono que contiene este punto
        polygon_name = find_containing_polygon(point_coords, polygon_features, polygon_name_property)
        
        # Agregar el atributo a las propiedades del punto
        if "properties" not in point_feature:
            point_feature["properties"] = {}
        
        point_feature["properties"][new_attribute_name] = polygon_name
        
        if polygon_name is not None:
            points_matched += 1
    
    print(f"Puntos procesados: {points_processed}")
    print(f"Puntos dentro de polígonos: {points_matched}")
    print(f"Puntos sin polígono: {points_processed - points_matched}")
    
    return result


def load_geojson(file_path: str) -> dict:
    """Carga un archivo GeoJSON."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_geojson(data: dict, file_path: str) -> None:
    """Guarda datos en un archivo GeoJSON."""
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def main():
    parser = argparse.ArgumentParser(
        description="Interpolación espacial entre puntos y polígonos GeoJSON"
    )
    parser.add_argument(
        "--points", "-p",
        required=True,
        help="Ruta al archivo GeoJSON de puntos"
    )
    parser.add_argument(
        "--polygons", "-g",
        required=True,
        help="Ruta al archivo GeoJSON de polígonos"
    )
    parser.add_argument(
        "--output", "-o",
        required=True,
        help="Ruta al archivo GeoJSON de salida"
    )
    parser.add_argument(
        "--attribute", "-a",
        default="polygon_name",
        help="Nombre del nuevo atributo a agregar (default: polygon_name)"
    )
    parser.add_argument(
        "--polygon-name-property", "-n",
        default="fna",
        help="Propiedad del polígono que contiene el nombre (default: fna)"
    )
    
    args = parser.parse_args()
    
    # Verificar que los archivos existen
    if not Path(args.points).exists():
        print(f"Error: El archivo de puntos no existe: {args.points}")
        return 1
    
    if not Path(args.polygons).exists():
        print(f"Error: El archivo de polígonos no existe: {args.polygons}")
        return 1
    
    print(f"Cargando puntos desde: {args.points}")
    points_data = load_geojson(args.points)
    
    print(f"Cargando polígonos desde: {args.polygons}")
    polygons_data = load_geojson(args.polygons)
    
    print(f"\nRealizando interpolación espacial...")
    print(f"Atributo nuevo: '{args.attribute}'")
    print(f"Propiedad del polígono: '{args.polygon_name_property}'")
    print()
    
    result = spatial_join(
        points_data,
        polygons_data,
        args.attribute,
        args.polygon_name_property
    )
    
    print(f"\nGuardando resultado en: {args.output}")
    save_geojson(result, args.output)
    print("¡Listo!")
    
    return 0


if __name__ == "__main__":
    exit(main())
