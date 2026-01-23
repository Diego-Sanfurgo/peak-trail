import json
import argparse
import sys
import os

try:
    from shapely.geometry import shape, mapping
    from shapely.geometry import Point
except ImportError:
    print("Error: The 'shapely' library is required. Please install it using 'pip install shapely'.")
    sys.exit(1)

def calculate_centroids(input_path, output_path):
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        if 'features' not in data:
            print("Error: Invalid GeoJSON format. 'features' key missing.")
            return

        new_features = []
        for feature in data['features']:
            geom = shape(feature['geometry'])
            
            # Calculate centroid
            centroid = geom.centroid
            
            # Create new feature with Point geometry
            new_feature = {
                "type": "Feature",
                "id": feature.get("id"),
                "geometry": mapping(centroid),
                "geometry_name": feature.get("geometry_name", "geom"),
                "properties": feature.get("properties", {}),
                "bbox": feature.get("bbox") # Ideally recalculate bbox for point, but keeping original might be intended or just use centroid coords
            }
            
            # Update bbox to be the point itself if we want accuracy for the point, 
            # but usually bbox isn't strictly required for Points. 
            # The user example shows: "bbox": [-69.31624526, -31.78922714, -69.31624526, -31.78922714]
            # So let's match that behavior.
            coords = new_feature['geometry']['coordinates']
            new_feature['bbox'] = [coords[0], coords[1], coords[0], coords[1]]

            new_features.append(new_feature)

        new_geojson = {
            "type": "FeatureCollection",
            "features": new_features
        }
        
        # Preserve other top-level keys if any (like crs), but usually FeatureCollection is enough.
        # The user said "El nuevo documento debe mantener todas las keys del original"
        # So let's copy the original dict and replace features.
        output_data = data.copy()
        output_data['features'] = new_features

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)
            
        print(f"Successfully generated centroids in: {output_path}")

    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert GeoJSON MultiPolygons to Centroid Points.")
    parser.add_argument("input_file", help="Path to input GeoJSON file")
    parser.add_argument("output_file", help="Path to output GeoJSON file")

    args = parser.parse_args()

    if not os.path.exists(args.input_file):
         print(f"Error: Input file not found: {args.input_file}")
         sys.exit(1)

    calculate_centroids(args.input_file, args.output_file)
