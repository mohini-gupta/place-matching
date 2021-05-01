-- FUNCTION: public.newcentroid()

-- DROP FUNCTION public.newcentroid();

CREATE FUNCTION public.newcentroid()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
	rec RECORD;
	payload TEXT;
	column_name TEXT;
	cluster_id_value TEXT;
BEGIN
	 CASE TG_OP
 	 WHEN 'INSERT', 'UPDATE' THEN
      	rec := NEW;
 	 ELSE
 	 	RAISE EXCEPTION 'Unknown TG_OP: "%". Should not occur!', TG_OP;
 	END CASE;
	
	rec := new;
	--payload:= json_build_object('operation',TG_OP,'cluster_id',rec.cluster_id,'id',rec.id,'trip_id',rec.trip_id);
	payload := json_build_object(TG_OP, rec.id);
	-- Notify the channel
	PERFORM pg_notify('db_notifications', payload);
	RETURN rec;
END;
$BODY$;

ALTER FUNCTION public.newcentroid()
    OWNER TO postgres;


-- Trigger: newcentroid_tr

-- DROP TRIGGER newcentroid_tr ON public.stop_episodes;

CREATE TRIGGER newcentroid_tr
    AFTER INSERT OR UPDATE OF centroid
    ON public.stop_episodes
    FOR EACH ROW
    EXECUTE PROCEDURE public.newcentroid();