-- FUNCTION: public.trajectory_identification()

-- DROP FUNCTION public.trajectory_identification();

CREATE FUNCTION public.trajectory_identification()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	durationlarge interval;
	rec record;
	lastinsertedtime timestamp; 
	lastinsertedgeom geometry; 
	lastinsertedLon double precision;
	lastinsertedLat double precision;
	
BEGIN
	CASE TG_OP
		WHEN 'INSERT' THEN
			rec := NEW;
		ELSE
			RAISE EXCEPTION 'Unknown TG_OP: "%". Should not occur!', TG_OP;
	END CASE;
	
	
	-- New TRIP definition
	
	/*
	Given a large time interval durationlarge, if two consecutive GPS records, pi(xi, yi, ti)
	and pi+1(xi+1, yi+1, ti+1), are such that the temporal gap (ti+1)−(ti) > durationlarge, then
	pi is the ending point of the current trajectory while pi+1 is the starting point of
	the next trajectory. In short, we add new trip_id to the pi+1.
	*/
	
	durationlarge := '0 day 4 hour'::interval; -- If a person stays at a POI for minimum 4 hours
	
	EXECUTE 'select t_from, ST_MakePoint(longitudine::float,latitudine::float),longitudine,latitudine from person_position ORDER BY id DESC LIMIT 1'
	INTO lastinsertedtime,lastinsertedgeom,lastinsertedLon, lastinsertedLat;
	
	
	/*
	Case 1: when lastinsertedtime is NOT NULL and the difference between the timestamp of new point and lastinsertedtime is greater than 
	durationlarge then increment the trip_id.
	
	Case 2: when lastinsertedtime is NULL, meaning this is the first trip
	
	Case 3: when lastinsertedtime is NOT NULL, and the difference between the timestamp of new point and lastinsertedtime is less than 
	durationlarge then the trip_id is not incremented and it is same as the previous trip_id
	*/
	IF ((rec.t_from)::timestamp - lastinsertedtime) > durationlarge THEN
		
		EXECUTE 'select trip_id + 1 from person_position ORDER BY id DESC LIMIT 1'
		INTO rec.trip_id;	
	
	ELSEIF (lastinsertedtime IS null) THEN 
		rec.trip_id := 4;
	
	ELSE
		EXECUTE 'select trip_id from person_position ORDER BY id DESC LIMIT 1'
		INTO rec.trip_id;
	END IF;		
	
	/*
	Update the geom (4326 SRID) and geom_m(7794)for meters
	*/
	
	rec.geom := ST_SetSRID(ST_MakePoint(rec.longitudine, rec.latitudine), 4326);
	rec.geom_m := ST_TRANSFORM(rec.geom,7794);
	
	IF (lastinsertedtime IS null) THEN
	rec.speed := 0;
	ELSE
	rec.speed := (ST_DistanceSphere(ST_MakePoint(rec.longitudine,rec.latitudine),ST_MakePoint(lastinsertedLon,lastinsertedLat)))/(EXTRACT(epoch from (rec.t_from-lastinsertedtime))); 
	END IF;
	

	RETURN rec;
END;
$BODY$;

ALTER FUNCTION public.trajectory_identification()
    OWNER TO postgres;
	
-- Trigger: trajectory_identification_tr

-- DROP TRIGGER trajectory_identification_tr ON public.person_position;

CREATE TRIGGER trajectory_identification_tr
    BEFORE INSERT
    ON public.person_position
    FOR EACH ROW
    EXECUTE PROCEDURE public.trajectory_identification();
