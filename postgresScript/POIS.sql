-- View: public.pois

-- DROP VIEW public.pois;

CREATE OR REPLACE VIEW public.pois
 AS
 SELECT stop.id,
    stop.cluster_id,
    stop.trip_id,
    stop.t_from,
    (stop.places -> 0) -> 'Name'::text,
    st_setsrid(st_makepoint((((stop.places -> 0) -> 'LatLon'::text) ->> 1)::double precision, (((stop.places -> 0) -> 'LatLon'::text) ->> 0)::double precision), 4326) AS poi
   FROM point_of_interests stop
  WHERE stop.places IS NOT NULL;

ALTER TABLE public.pois
    OWNER TO postgres;

