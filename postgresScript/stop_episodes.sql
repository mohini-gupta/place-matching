-- Table: public.stop_episodes

-- DROP TABLE public.stop_episodes;

CREATE TABLE public.stop_episodes
(
    id integer NOT NULL DEFAULT nextval('stop_episodes_id_seq'::regclass),
    id_person integer,
    cluster_id integer NOT NULL,
    trip_id integer NOT NULL,
    centroid geometry,
    radius double precision,
    t_from timestamp with time zone,
    duration time without time zone,
    min_id integer,
    max_id integer,
    collectedgeom geometry,
    CONSTRAINT stop_episodes_pkey PRIMARY KEY (cluster_id, trip_id)
)

TABLESPACE pg_default;

ALTER TABLE public.stop_episodes
    OWNER to postgres;

-- Trigger: newcentroid_tr

-- DROP TRIGGER newcentroid_tr ON public.stop_episodes;

CREATE TRIGGER newcentroid_tr
    AFTER INSERT OR UPDATE OF centroid
    ON public.stop_episodes
    FOR EACH ROW
    EXECUTE PROCEDURE public.newcentroid();