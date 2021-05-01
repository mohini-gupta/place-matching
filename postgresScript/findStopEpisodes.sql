-- PROCEDURE: public.findstopepisodes()

-- DROP PROCEDURE public.findstopepisodes();

CREATE OR REPLACE PROCEDURE public.findstopepisodes(
	)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	rec_dbscan record;
	cur_dbscan refcursor;
	rec_cluster record;
	cur_cluster refcursor;
BEGIN
	REFRESH MATERIALIZED VIEW DBSCAN;
	
	open cur_cluster for select * from checkdbscan;
	loop 
		fetch cur_cluster into rec_cluster;
		exit when not found;
		if exists (select * from clusters where cluster_id=rec_cluster.clusterid and trip_id=rec_cluster.trip_id) then
			update clusters set min_id=rec_cluster.min_id, max_id=rec_cluster.max_id
					where cluster_id=rec_cluster.clusterid and trip_id = rec_cluster.trip_id;
		else 
			INSERT into clusters(cluster_id,trip_id, min_id, max_id)
				values(rec_cluster.clusterid,rec_cluster.trip_id,rec_cluster.min_id, rec_cluster.max_id);
		end if;
	end loop;
	close cur_cluster;
	

	open cur_dbscan for SELECT * from DBSCAN WHERE duration >= '5 minute'::interval;
	loop
 		fetch cur_dbscan into rec_dbscan;
 		exit when not found;
		
 		IF EXISTS (SELECT * FROM stop_episodes WHERE cluster_id=rec_dbscan.clusterid and trip_id = rec_dbscan.trip_id) THEN
 			IF NOT EXISTS (SELECT * FROM stop_episodes WHERE cluster_id=rec_dbscan.clusterid and trip_id = rec_dbscan.trip_id and
 					   (radius=rec_dbscan.radius or centroid=rec_dbscan.centroid or duration=(rec_dbscan.duration)::time)) THEN
				update stop_episodes set radius=rec_dbscan.radius, centroid=rec_dbscan.centroid, duration = (rec_dbscan.duration)::time, max_id=rec_dbscan.max_id, collectedgeom = rec_dbscan.collectedgeom7794
				where cluster_id=rec_dbscan.clusterid and trip_id = rec_dbscan.trip_id;
				RAISE NOTICE 'update happend for %s ', rec_dbscan.clusterid; 
				
			END IF;
 		ELSE
 			INSERT into stop_episodes(cluster_id,centroid, radius,t_from,duration, min_id, trip_id, max_id, collectedgeom)
 			values(rec_dbscan.clusterid,rec_dbscan.centroid,rec_dbscan.radius, rec_dbscan.min_time,(rec_dbscan.duration)::time,rec_dbscan.min_id,rec_dbscan.trip_id, rec_dbscan.max_id,rec_dbscan.collectedgeom7794);
 			RAISE NOTICE 'insert happend for %s ', rec_dbscan.clusterid;
 		END IF;

 	end loop;
 	close cur_dbscan;
END;
$BODY$;
