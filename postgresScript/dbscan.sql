-- View: public.dbscan

-- DROP MATERIALIZED VIEW public.dbscan;

CREATE MATERIALIZED VIEW public.dbscan
TABLESPACE pg_default
AS
 SELECT sq.clusterid,
    st_transform(st_centroid(st_collect(sq.geom_m)), 4326) AS centroid,
    st_maxdistance(st_centroid(st_collect(sq.geom_m)), st_collect(sq.geom_m)) AS radius,
    min(sq.t_from) AS min_time,
    max(sq.t_from) - min(sq.t_from) AS duration,
    min(sq.id) AS min_id,
    max(sq.id) AS max_id,
    sq.trip_id,
    st_collect(sq.geom_m) AS collectedgeom7794
   FROM ( SELECT st_clusterdbscan(pp.geom_m, eps => 20::double precision, minpoints => 5) OVER (PARTITION BY pp.trip_id ORDER BY pp.id) +
                CASE
                    WHEN (( SELECT (EXISTS ( SELECT 1
                               FROM clusters pm0
                              WHERE pm0.trip_id = pp.trip_id)) AS "exists")) = true THEN ( SELECT max(pm1.cluster_id) AS max
                       FROM clusters pm1
                      WHERE pm1.trip_id = pp.trip_id)
                    ELSE ( SELECT 0)
                END AS clusterid,
            pp.geom_m,
            pp.t_from,
            pp.id,
            pp.trip_id
           FROM person_position pp
          WHERE pp.id >=
                CASE
                    WHEN (( SELECT (EXISTS ( SELECT 1
                               FROM clusters pm2
                              WHERE pm2.trip_id = pp.trip_id)) AS "exists")) = true THEN ( SELECT pm.min_id
                       FROM clusters pm
                      WHERE pm.trip_id = pp.trip_id AND (pm.cluster_id IN ( SELECT max(pm3.cluster_id) AS max
                               FROM clusters pm3
                              WHERE pm3.trip_id = pm.trip_id)))
                    ELSE ( SELECT min(pp1.id) AS min
                       FROM person_position pp1
                      WHERE pp1.trip_id = pp.trip_id)
                END) sq
  WHERE sq.clusterid IS NOT NULL
  GROUP BY sq.clusterid, sq.trip_id
WITH DATA;

ALTER TABLE public.dbscan
    OWNER TO postgres;