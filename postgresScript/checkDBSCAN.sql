-- View: public.checkdbscan

-- DROP VIEW public.checkdbscan;

CREATE OR REPLACE VIEW public.checkdbscan
 AS
 SELECT sq.clusterid,
    st_centroid(st_collect(sq.geom)) AS centroid43260,
    st_equals(st_centroid(st_collect(sq.geom)), st_transform(st_centroid(st_collect(sq.geom_m)), 4326)) AS st_equals,
    st_transform(st_centroid(st_collect(sq.geom_m)), 4326) AS centroid4326,
    st_centroid(st_collect(sq.geom_m)) AS centroid4480,
    st_transform(st_minimumboundingcircle(st_collect(sq.geom_m)), 4326) AS circle,
    st_numgeometries(st_collect(sq.geom_m)) AS numgeom,
    min(sq.t_from) AS mintime,
    max(sq.t_from) - min(sq.t_from) AS duration,
    min(sq.id) AS min_id,
    max(sq.id) AS max_id,
    sq.trip_id,
    st_transform(st_longestline(st_centroid(st_collect(sq.geom_m)), st_collect(sq.geom_m)), 4326) AS longestline,
    st_maxdistance(st_centroid(st_collect(sq.geom_m)), st_collect(sq.geom_m)) AS radiusfrommaxdistance,
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
            pp.trip_id,
            pp.geom,
            pp.speed
           FROM person_position pp
          WHERE pp.trip_id >= 2 AND pp.id >=
                CASE
                    WHEN (( SELECT (EXISTS ( SELECT 1
                               FROM clusters pm2
                              WHERE pm2.trip_id = pp.trip_id AND pm2.cluster_id IS NULL AND (pm2.max_id IN ( SELECT max(clusters.max_id) AS max
                                       FROM clusters)))) AS "exists")) = true THEN ( SELECT c1.max_id
                       FROM clusters c1
                      WHERE c1.trip_id = pp.trip_id AND c1.cluster_id IS NULL AND (c1.max_id IN ( SELECT max(clusters.max_id) AS max
                               FROM clusters)))
                    WHEN (( SELECT (EXISTS ( SELECT 1
                               FROM clusters cx
                              WHERE cx.trip_id = pp.trip_id AND cx.cluster_id IS NOT NULL AND (cx.max_id IN ( SELECT max(clusters.max_id) AS max
                                       FROM clusters)))) AS "exists")) = true THEN ( SELECT pm.min_id
                       FROM clusters pm
                      WHERE pm.trip_id = pp.trip_id AND pm.cluster_id IS NOT NULL AND (pm.max_id IN ( SELECT max(clusters.max_id) AS max
                               FROM clusters)))
                    ELSE ( SELECT min(pp1.id) AS min
                       FROM person_position pp1
                      WHERE pp1.trip_id = pp.trip_id)
                END) sq
  GROUP BY sq.clusterid, sq.trip_id
  ORDER BY sq.clusterid;

ALTER TABLE public.checkdbscan
    OWNER TO postgres;

