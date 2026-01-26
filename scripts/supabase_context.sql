-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE geo_core.departments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  in1 text,
  boundary USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT departments_pkey PRIMARY KEY (id)
);
CREATE TABLE geo_core.mountain_areas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  place_id uuid NOT NULL,
  boundary USER-DEFINED,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mountain_areas_pkey PRIMARY KEY (id),
  CONSTRAINT mountain_areas_place_id_fkey FOREIGN KEY (place_id) REFERENCES geo_core.places(id)
);
CREATE TABLE geo_core.places (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text,
  alt integer,
  type text NOT NULL,
  geom USER-DEFINED NOT NULL,
  state_id uuid,
  district_id uuid,
  protected_area_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT places_pkey PRIMARY KEY (id),
  CONSTRAINT places_state_id_fkey FOREIGN KEY (state_id) REFERENCES geo_core.provinces(id),
  CONSTRAINT places_district_id_fkey FOREIGN KEY (district_id) REFERENCES geo_core.departments(id),
  CONSTRAINT places_protected_area_id_fkey FOREIGN KEY (protected_area_id) REFERENCES geo_core.protected_areas(id)
);
CREATE TABLE geo_core.protected_areas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  in1 text,
  boundary USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT protected_areas_pkey PRIMARY KEY (id)
);
CREATE TABLE geo_core.provinces (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  in1 text,
  boundary USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT provinces_pkey PRIMARY KEY (id)
);
CREATE TABLE geo_core.water_fonts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text,
  in1 text,
  boundary USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT water_fonts_pkey PRIMARY KEY (id)
);

CREATE TABLE public.spatial_ref_sys (
  srid integer NOT NULL CHECK (srid > 0 AND srid <= 998999),
  auth_name character varying,
  auth_srid integer,
  srtext character varying,
  proj4text character varying,
  CONSTRAINT spatial_ref_sys_pkey PRIMARY KEY (srid)
);

-- FUNCTION: geo_core.mvt_mountains(integer, integer, integer)
DECLARE
    mvt bytea;
    bbox geometry;
BEGIN
    -- 1. Calcular el bounding box del tile en EPSG:3857
    bbox := ST_TileEnvelope(z, x, y);

    SELECT INTO mvt ST_AsMVT(tile, 'mountain_areas_tiles', 4096, 'geom')
    FROM (
        SELECT 
            place_id,
            -- Transformamos la geometría al sistema del tile (3857) para el dibujo
            ST_AsMVTGeom(
                ST_Transform(boundary, 3857),
                bbox,
                4096, 
                256, 
                true
            ) AS geom
        FROM 
            geo_core.mountain_areas
        WHERE 
            -- OPTIMIZACIÓN: Transformamos el bbox a 4326 para usar el índice de 'boundary'
            -- Esto evita escanear toda la tabla y usa el índice GIST.
            boundary && ST_Transform(bbox, 4326)
            -- Y refinamos con intersección real
            AND ST_Intersects(boundary, ST_Transform(bbox, 4326))
    ) AS tile;

    RETURN mvt;
END;


--EDGE Function que expone la url para mapbox

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Helper para convertir hex string de Postgres (\xdeadbeef...) a Uint8Array
function hexToUint8Array(hexString: string) {
  // Eliminar el prefijo '\x' si existe
  const hex = hexString.startsWith('\\x') ? hexString.slice(2) : hexString;
  
  // Si está vacío, devolver array vacío
  if (!hex) return new Uint8Array(0);

  // Crear el array de bytes
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
  }
  return bytes;
}

serve(async (req) => {
  // 1. Parsear URL
  const url = new URL(req.url);
  const pathParts = url.pathname.split('/'); 
  // Ruta esperada: /mvt-mountains/{z}/{x}/{y}
  const y = parseInt(pathParts.pop()!);
  const x = parseInt(pathParts.pop()!);
  const z = parseInt(pathParts.pop()!);

  if (isNaN(x) || isNaN(y) || isNaN(z)) {
    return new Response("Invalid coordinates", { status: 400 });
  }

  // 2. Cliente Supabase
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  );

  // 3. Llamada RPC
  const { data, error } = await supabase.rpc('get_mountain_mvt', { z, x, y });

  if (error) {
    console.error("RPC Error:", error);
    return new Response(JSON.stringify(error), { status: 500 });
  }

  // 4. DECODIFICACIÓN CRÍTICA
  // Si no hay datos, devolver 204 No Content o un buffer vacío
  if (!data) {
    return new Response(null, { status: 204 });
  }

  // 'data' viene como string hex string (ej: "\x1F8B08..."). Convertir a binario:
  const binaryData = typeof data === 'string' ? hexToUint8Array(data) : data;

  // 5. Devolver Binario
  return new Response(binaryData, {
    headers: {
      "Content-Type": "application/vnd.mapbox-vector-tile",
      "Cache-Control": "public, max-age=3600"
    },
  });
});