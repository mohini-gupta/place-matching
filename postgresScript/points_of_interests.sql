-- Table: public.point_of_interests

-- DROP TABLE public.point_of_interests;

CREATE TABLE public.point_of_interests
(
    id integer NOT NULL DEFAULT nextval('point_of_interests_id_seq'::regclass),
    id_person integer,
    trip_id integer NOT NULL,
    cluster_id integer NOT NULL,
    t_from timestamp with time zone,
    places json,
    CONSTRAINT point_of_interests_pkey PRIMARY KEY (id, cluster_id, trip_id)
)

TABLESPACE pg_default;

ALTER TABLE public.point_of_interests
    OWNER to postgres;