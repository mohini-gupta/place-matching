-- Table: public.person_position

-- DROP TABLE public.person_position;

CREATE TABLE public.person_position
(
    id integer NOT NULL DEFAULT nextval('person_position_id_seq'::regclass),
    id_person integer,
    latitudine double precision,
    longitudine double precision,
    t_from timestamp with time zone NOT NULL,
    t_to timestamp with time zone,
    geom geometry(Point,4326),
    geom_m geometry,
    trip_id integer,
    speed double precision,
    CONSTRAINT person_position_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.person_position
    OWNER to postgres;
-- Index: geom_m_idx

-- DROP INDEX public.geom_m_idx;

CREATE INDEX geom_m_idx
    ON public.person_position USING gist
    (geom_m)
    TABLESPACE pg_default;
-- Index: pp_trip_id_idx

-- DROP INDEX public.pp_trip_id_idx;

CREATE INDEX pp_trip_id_idx
    ON public.person_position USING btree
    (trip_id ASC NULLS LAST)
    TABLESPACE pg_default;

-- Trigger: trajectory_identification_tr

-- DROP TRIGGER trajectory_identification_tr ON public.person_position;

CREATE TRIGGER trajectory_identification_tr
    BEFORE INSERT
    ON public.person_position
    FOR EACH ROW
    EXECUTE PROCEDURE public.trajectory_identification();