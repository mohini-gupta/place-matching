-- Table: public.clusters

-- DROP TABLE public.clusters;

CREATE TABLE public.clusters
(
    id integer NOT NULL DEFAULT nextval('clusters_id_seq'::regclass),
    cluster_id integer,
    trip_id integer,
    min_id integer,
    max_id integer,
    CONSTRAINT clusters_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.clusters
    OWNER to postgres;