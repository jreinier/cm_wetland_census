-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.2-beta
-- PostgreSQL version: 9.5
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: "CM" | type: DATABASE --
-- -- DROP DATABASE IF EXISTS "CM";
-- CREATE DATABASE "CM"
-- 	ENCODING = 'UTF8'
-- 	LC_COLLATE = 'English_United States.UTF8'
-- 	LC_CTYPE = 'English_United States.UTF8'
-- 	TABLESPACE = pg_default
-- 	OWNER = postgres
-- ;
-- -- ddl-end --
-- 

-- object: wetland_census | type: SCHEMA --
-- DROP SCHEMA IF EXISTS wetland_census CASCADE;
CREATE SCHEMA wetland_census;
-- ddl-end --
ALTER SCHEMA wetland_census OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,wetland_census;
-- ddl-end --

-- object: wetland_census.change_trigger | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.change_trigger() CASCADE;
CREATE FUNCTION wetland_census.change_trigger ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY DEFINER
	COST 100
	AS $$

 
        BEGIN
 
                IF      TG_OP = 'INSERT'
 
                THEN
 
                        INSERT INTO logging.t_history (tabname, schemaname, operation, new_val)
 
                                VALUES (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, hstore(NEW));
 
                        RETURN NEW;
 
                ELSIF   TG_OP = 'UPDATE'
 
                THEN
 
                        INSERT INTO logging.t_history (tabname, schemaname, operation, new_val, old_val)
 
                                VALUES (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP,
 
                                        hstore(NEW), hstore(OLD));
 
                        RETURN NEW;
 
                ELSIF   TG_OP = 'DELETE'
 
                THEN
 
                        INSERT INTO logging.t_history (tabname, schemaname, operation, old_val)
 
                                VALUES (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, hstore(OLD));
 
                        RETURN OLD;
 
                END IF;
 
        END;
 

$$;
-- ddl-end --
ALTER FUNCTION wetland_census.change_trigger() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_insert | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.cm_wetland_classification_insert() CASCADE;
CREATE FUNCTION wetland_census.cm_wetland_classification_insert ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN
WITH class_all_id AS (
SELECT fulcrum_id, created_at, updated_at, created_by, updated_by, system_created_at, system_updated_at, version, 
status, project, assigned_to, latitude, longitude, geometry, reservation, polygon_id, data_recorded_by_initials, classification_level, landscape_position, inland_landform, water_flow_path, llww_modifiers, cowardin_classification, 
cowardin_water_regime, cowardin_special_modifier, cowardin_special_modifier_other, plant_community, 
plant_community_other, sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, sp9, sp10, notes, photos, photos_caption, photos_url, 
nextval ('wetland_census.wetland_classification_id_seq'::regclass) AS classification_id FROM wetland_census.wetland_classification wetland_class
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_id WHERE fulcrum_id = wetland_class.fulcrum_id
	)),

class_landscape AS (SELECT regexp_split_to_table(landscape_position, ',') AS landscape_position, classification_id FROM class_all_id),

class_landform AS (SELECT regexp_split_to_table(inland_landform, ',') AS inland_landform, classification_id FROM class_all_id),

class_waterflow AS (SELECT regexp_split_to_table(water_flow_path, ',') AS water_flow_path, classification_id FROM class_all_id),

class_llww_modifiers AS (SELECT regexp_split_to_table(llww_modifiers, ',') AS llww_modifiers, classification_id FROM class_all_id),

class_cowardin AS (SELECT regexp_split_to_table(cowardin_classification, ',') AS cowardin_classification, classification_id FROM class_all_id),

class_cowardin_special AS (SELECT regexp_split_to_table(cowardin_special_modifier, ',') AS cowardin_special_modifier, classification_id FROM class_all_id),

class_cowardin_special_other AS (SELECT regexp_split_to_table(cowardin_special_modifier_other, ',') AS cowardin_special_modifier_other, classification_id FROM class_all_id),

class_cowardin_water AS (SELECT regexp_split_to_table(cowardin_water_regime, ',') AS cowardin_water_regime, classification_id FROM class_all_id),

class_plant_community AS (SELECT regexp_split_to_table(plant_community, ',') AS plant_community, classification_id FROM class_all_id),

class_plant_community_other AS (SELECT regexp_split_to_table(plant_community_other, ',') AS plant_community_other, classification_id FROM class_all_id),

class_coord AS (SELECT latitude, longitude, classification_id FROM class_all_id),

class_geom AS (SELECT regexp_split_to_table(geometry, ',') AS geometry, classification_id FROM class_all_id),

class_reservation AS (SELECT reservation, classification_id FROM class_all_id),

class_poly_id AS (SELECT polygon_id, classification_id FROM class_all_id),

class_recorder AS (SELECT regexp_split_to_table(data_recorded_by_initials, ',') AS data_recorded_by_initials, classification_id FROM class_all_id),

class_sp1 AS (SELECT classification_id, sp1 FROM class_all_id),
class_sp2 AS (SELECT classification_id, sp2 FROM class_all_id),
class_sp3 AS (SELECT classification_id, sp3 FROM class_all_id),
class_sp4 AS (SELECT classification_id, sp4 FROM class_all_id),
class_sp5 AS (SELECT classification_id, sp5 FROM class_all_id),
class_sp6 AS (SELECT classification_id, sp6 FROM class_all_id),
class_sp7 AS (SELECT classification_id, sp7 FROM class_all_id),
class_sp8 AS (SELECT classification_id, sp8 FROM class_all_id),
class_sp9 AS (SELECT classification_id, sp9 FROM class_all_id),
class_sp10 AS (SELECT classification_id, sp10 FROM class_all_id),
class_notes AS (SELECT classification_id, notes FROM class_all_id),

class_photos AS (SELECT regexp_split_to_table(photos, ',') AS photos, classification_id FROM class_all_id),
class_photos_caption AS (SELECT regexp_split_to_table(photos_caption, ',') AS photos_caption, classification_id FROM class_all_id),
class_photos_url AS (SELECT regexp_split_to_table(photos_url, ',') AS photos_url, classification_id FROM class_all_id),




ins1 AS (INSERT INTO wetland_census.cm_wetland_classification_id SELECT polygon_id, reservation, classification_level, classification_id, fulcrum_id FROM class_all_id
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_id WHERE fulcrum_id = class_all_id.fulcrum_id
	)),

ins2 AS (INSERT INTO wetland_census.cm_wetland_landscape_position_norm SELECT classification_id,landscape_position FROM class_landscape
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_landscape_position_norm WHERE classification_id = class_landscape.classification_id
	)),
	
ins3 AS (INSERT INTO wetland_census.cm_wetland_inland_landform_norm	SELECT classification_id,inland_landform FROM class_landform
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_inland_landform_norm WHERE classification_id = class_landform.classification_id
	)),
	
ins4 AS (INSERT INTO wetland_census.cm_wetland_water_flow_path SELECT classification_id,water_flow_path FROM class_waterflow
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_water_flow_path WHERE classification_id = class_waterflow.classification_id
	)),
	
ins5 AS (INSERT INTO wetland_census.cm_wetland_llww_modifiers SELECT classification_id,llww_modifiers FROM class_llww_modifiers
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_llww_modifiers WHERE classification_id = class_llww_modifiers.classification_id
	)),
	
ins6 AS (INSERT INTO wetland_census.cm_wetland_cowardin_classification SELECT classification_id,cowardin_classification FROM class_cowardin
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_cowardin_classification WHERE classification_id = class_cowardin.classification_id
	)),
	
ins7 AS (INSERT INTO wetland_census.cm_wetland_cowardin_water_regime SELECT classification_id,cowardin_water_regime FROM class_cowardin_water
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_cowardin_water_regime WHERE classification_id = class_cowardin_water.classification_id
	)),
	
ins8 AS (INSERT INTO wetland_census.cm_wetland_cowardin_special_modifier SELECT classification_id,cowardin_special_modifier FROM class_cowardin_special
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_cowardin_special_modifier WHERE classification_id = class_cowardin_special.classification_id
	)),
	
ins9 AS (INSERT INTO wetland_census.cm_wetland_plant_community_norm SELECT classification_id, plant_community FROM class_plant_community
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_plant_community_norm WHERE classification_id = class_plant_community.classification_id
	)),
	
ins10 AS (INSERT INTO wetland_census.cm_wetland_cowardin_special_modifier_other SELECT classification_id, cowardin_special_modifier_other FROM class_cowardin_special_other
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_cowardin_special_modifier_other WHERE classification_id = class_cowardin_special_other.classification_id
	)),
	
ins11 AS (INSERT INTO wetland_census.cm_wetland_plant_community_other SELECT classification_id, plant_community_other FROM class_plant_community_other
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_plant_community_other WHERE classification_id = class_plant_community_other.classification_id
	)),
	
ins12 AS (INSERT INTO wetland_census.cm_wetland_classification_coordinates SELECT classification_id, latitude, longitude FROM class_coord
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_coordinates WHERE classification_id = class_coord.classification_id
	)),
	
ins13 AS (INSERT INTO wetland_census.cm_wetland_classification_geometry SELECT classification_id, geometry FROM class_geom
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_geometry WHERE classification_id = class_geom.classification_id
	)),
	
ins14 AS (INSERT INTO wetland_census.cm_wetland_classification_reservation SELECT classification_id, reservation FROM class_reservation
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_reservation WHERE classification_id = class_reservation.classification_id
	)),
	
ins15 AS (INSERT INTO wetland_census.cm_wetland_classification_polygon_id SELECT classification_id, polygon_id FROM class_poly_id
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_polygon_id WHERE classification_id = class_poly_id.classification_id
	)),
	
ins16 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp1 FROM class_sp1
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp1.classification_id AND plant_species = class_sp1.sp1
	) AND class_sp1.sp1 IS NOT NULL),
	
ins17 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp2 FROM class_sp2
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp2.classification_id AND plant_species = class_sp2.sp2
	)AND class_sp2.sp2 IS NOT NULL),
	
ins18 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp3 FROM class_sp3
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp3.classification_id AND plant_species = class_sp3.sp3
	)AND class_sp3.sp3 IS NOT NULL),
	
ins19 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp4 FROM class_sp4
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp4.classification_id AND plant_species = class_sp4.sp4
	)AND class_sp4.sp4 IS NOT NULL),
	
ins20 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp5 FROM class_sp5
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp5.classification_id AND plant_species = class_sp5.sp5
	)AND class_sp5.sp5 IS NOT NULL),
	
ins21 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp6 FROM class_sp6
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp6.classification_id AND plant_species = class_sp6.sp6
	)AND class_sp6.sp6 IS NOT NULL),
	
ins22 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp7 FROM class_sp7
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp7.classification_id AND plant_species = class_sp7.sp7
	)AND class_sp7.sp7 IS NOT NULL),
	
ins23 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp8 FROM class_sp8
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp8.classification_id AND plant_species = class_sp8.sp8
	)AND class_sp8.sp8 IS NOT NULL),
	
ins24 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp9 FROM class_sp9
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp9.classification_id AND plant_species = class_sp9.sp9
	)AND class_sp9.sp9 IS NOT NULL),
	
ins25 AS (INSERT INTO wetland_census.cm_wetland_dominant_species SELECT classification_id, sp10 FROM class_sp10
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_dominant_species WHERE classification_id = class_sp10.classification_id AND plant_species = class_sp10.sp10
	)AND class_sp10.sp10 IS NOT NULL),
	
ins26 AS (INSERT INTO wetland_census.cm_wetland_classification_notes SELECT classification_id, notes FROM class_notes
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_classification_notes WHERE classification_id = class_notes.classification_id) 
	AND class_notes.notes IS NOT NULL),
	
ins27 AS (INSERT INTO wetland_census.cm_wetland_photos_norm SELECT classification_id, photos FROM class_photos
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_photos_norm WHERE classification_id = class_photos.classification_id AND photos = class_photos.photos
	)AND class_photos.photos IS NOT NULL),

ins28 AS (INSERT INTO wetland_census.cm_wetland_photos_caption_norm SELECT classification_id, photos_caption FROM class_photos_caption
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_photos_caption_norm WHERE classification_id = class_photos_caption.classification_id AND photos_caption = class_photos_caption.photos_caption
	)AND class_photos_caption.photos_caption IS NOT NULL)

INSERT INTO wetland_census.cm_wetland_photos_url_norm SELECT classification_id, photos_url FROM class_photos_url
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.cm_wetland_photos_url_norm WHERE classification_id = class_photos_url.classification_id AND photos_url = class_photos_url.photos_url
	)AND class_photos_url.photos_url IS NOT NULL
;	
	
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.cm_wetland_classification_insert() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric1_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric1_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric1_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric1_value_temp AS (
SELECT norm1.oram_id, norm1.selection, lookup.value AS metric1_value, lookup.lookup_id FROM wetland_census.metric1_norm norm1 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm1.selection),
	
upsert1 AS (UPDATE wetland_census.metric1_value value1 SET oram_id = value1_temp.oram_id, selection = value1_temp.selection, metric1_value = value1_temp.metric1_value,
lookup_id = value1_temp.lookup_id
FROM metric1_value_temp value1_temp 
WHERE value1.oram_id = value1_temp.oram_id AND value1.selection = value1_temp.selection)
	
INSERT INTO wetland_census.metric1_value SELECT oram_id, selection, metric1_value, lookup_id FROM metric1_value_temp value1_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric1_value value1 WHERE value1.oram_id = value1_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric1_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric2a_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric2a_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric2a_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric2a_value_temp AS (
SELECT norm2a.oram_id, norm2a.selection, lookup.value AS metric2a_value, lookup.lookup_id FROM wetland_census.metric2a_norm norm2a LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm2a.selection),
	
upsert2a AS (UPDATE wetland_census.metric2a_value value2a SET oram_id = value2a_temp.oram_id, selection = value2a_temp.selection, metric2a_value = value2a_temp.metric2a_value,
lookup_id = value2a_temp.lookup_id
FROM metric2a_value_temp value2a_temp 
WHERE value2a.oram_id = value2a_temp.oram_id AND value2a.selection = value2a_temp.selection)
	
INSERT INTO wetland_census.metric2a_value SELECT oram_id, selection, metric2a_value, lookup_id FROM metric2a_value_temp value2a_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric2a_value value2a WHERE value2a.oram_id = value2a_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric2a_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric2b_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric2b_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric2b_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric2b_value_temp AS (
SELECT norm2b.oram_id, norm2b.selection, lookup.value AS metric2b_value, lookup.lookup_id FROM wetland_census.metric2b_norm norm2b LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm2b.selection),
	
upsert2b AS (UPDATE wetland_census.metric2b_value value2b SET oram_id = value2b_temp.oram_id, selection = value2b_temp.selection, metric2b_value = value2b_temp.metric2b_value,
lookup_id = value2b_temp.lookup_id
FROM metric2b_value_temp value2b_temp 
WHERE value2b.oram_id = value2b_temp.oram_id AND value2b.selection = value2b_temp.selection)
	
INSERT INTO wetland_census.metric2b_value SELECT oram_id, selection, metric2b_value, lookup_id FROM metric2b_value_temp value2b_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric2b_value value2b WHERE value2b.oram_id = value2b_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric2b_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric3a_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric3a_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric3a_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric3a_value_temp AS (
SELECT norm3a.oram_id, norm3a.selection, lookup.value AS metric3a_value, lookup.lookup_id FROM wetland_census.metric3a_norm norm3a LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm3a.selection),
	
upsert3a AS (UPDATE wetland_census.metric3a_value value3a SET oram_id = value3a_temp.oram_id, selection = value3a_temp.selection, metric3a_value = value3a_temp.metric3a_value,
lookup_id = value3a_temp.lookup_id
FROM metric3a_value_temp value3a_temp 
WHERE value3a.oram_id = value3a_temp.oram_id AND value3a.selection = value3a_temp.selection)
	
INSERT INTO wetland_census.metric3a_value SELECT oram_id, selection, metric3a_value, lookup_id FROM metric3a_value_temp value3a_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3a_value value3a WHERE value3a.oram_id = value3a_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric3a_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric3b_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric3b_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric3b_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric3b_value_temp AS (
SELECT norm3b.oram_id, norm3b.selection, lookup.value AS metric3b_value, lookup.lookup_id FROM wetland_census.metric3b_norm norm3b LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm3b.selection),
	
upsert3b AS (UPDATE wetland_census.metric3b_value value3b SET oram_id = value3b_temp.oram_id, selection = value3b_temp.selection, metric3b_value = value3b_temp.metric3b_value,
lookup_id = value3b_temp.lookup_id
FROM metric3b_value_temp value3b_temp 
WHERE value3b.oram_id = value3b_temp.oram_id AND value3b.selection = value3b_temp.selection)
	
INSERT INTO wetland_census.metric3b_value SELECT oram_id, selection, metric3b_value, lookup_id FROM metric3b_value_temp value3b_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3b_value value3b WHERE value3b.oram_id = value3b_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric3b_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric3c_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric3c_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric3c_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric3c_value_temp AS (
SELECT norm3c.oram_id, norm3c.selection, lookup.value AS metric3c_value, lookup.lookup_id FROM wetland_census.metric3c_norm norm3c LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm3c.selection),
	
upsert3c AS (UPDATE wetland_census.metric3c_value value3c SET oram_id = value3c_temp.oram_id, selection = value3c_temp.selection, metric3c_value = value3c_temp.metric3c_value,
lookup_id = value3c_temp.lookup_id
FROM metric3c_value_temp value3c_temp 
WHERE value3c.oram_id = value3c_temp.oram_id AND value3c.selection = value3c_temp.selection)
	
INSERT INTO wetland_census.metric3c_value SELECT oram_id, selection, metric3c_value, lookup_id FROM metric3c_value_temp value3c_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3c_value value3c WHERE value3c.oram_id = value3c_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric3c_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric3d_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric3d_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric3d_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric3d_value_temp AS (
SELECT norm3d.oram_id, norm3d.selection, lookup.value AS metric3d_value, lookup.lookup_id FROM wetland_census.metric3d_norm norm3d LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm3d.selection),
	
upsert3d AS (UPDATE wetland_census.metric3d_value value3d SET oram_id = value3d_temp.oram_id, selection = value3d_temp.selection, metric3d_value = value3d_temp.metric3d_value,
lookup_id = value3d_temp.lookup_id
FROM metric3d_value_temp value3d_temp 
WHERE value3d.oram_id = value3d_temp.oram_id AND value3d.selection = value3d_temp.selection)
	
INSERT INTO wetland_census.metric3d_value SELECT oram_id, selection, metric3d_value, lookup_id FROM metric3d_value_temp value3d_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3d_value value3d WHERE value3d.oram_id = value3d_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric3d_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric3e_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric3e_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric3e_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric3e_value_temp AS (
SELECT norm3e.oram_id, norm3e.selection, lookup.value AS metric3e_value, lookup.lookup_id FROM wetland_census.metric3e_norm norm3e LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm3e.selection AND lookup.metric = 'm3e_modifications_to_hydrologic_regime'),
	
upsert3e AS (UPDATE wetland_census.metric3e_value value3e SET oram_id = value3e_temp.oram_id, selection = value3e_temp.selection, metric3e_value = value3e_temp.metric3e_value,
lookup_id = value3e_temp.lookup_id
FROM metric3e_value_temp value3e_temp 
WHERE value3e.oram_id = value3e_temp.oram_id AND value3e.selection = value3e_temp.selection)
	
INSERT INTO wetland_census.metric3e_value SELECT oram_id, selection, metric3e_value, lookup_id FROM metric3e_value_temp value3e_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3e_value value3e WHERE value3e.oram_id = value3e_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric3e_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric4a_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric4a_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric4a_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric4a_value_temp AS (
SELECT norm4a.oram_id, norm4a.selection, lookup.value AS metric4a_value, lookup.lookup_id FROM wetland_census.metric4a_norm norm4a LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm4a.selection AND lookup.metric = 'm4a_substrate_disturbance'),
	
upsert4a AS (UPDATE wetland_census.metric4a_value value4a SET oram_id = value4a_temp.oram_id, selection = value4a_temp.selection, metric4a_value = value4a_temp.metric4a_value,
lookup_id = value4a_temp.lookup_id
FROM metric4a_value_temp value4a_temp 
WHERE value4a.oram_id = value4a_temp.oram_id AND value4a.selection = value4a_temp.selection)
	
INSERT INTO wetland_census.metric4a_value SELECT oram_id, selection, metric4a_value, lookup_id FROM metric4a_value_temp value4a_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric4a_value value4a WHERE value4a.oram_id = value4a_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric4a_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric4b_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric4b_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric4b_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric4b_value_temp AS (
SELECT norm4b.oram_id, norm4b.selection, lookup.value AS metric4b_value, lookup.lookup_id FROM wetland_census.metric4b_norm norm4b LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm4b.selection),
	
upsert4b AS (UPDATE wetland_census.metric4b_value value4b SET oram_id = value4b_temp.oram_id, selection = value4b_temp.selection, metric4b_value = value4b_temp.metric4b_value,
lookup_id = value4b_temp.lookup_id
FROM metric4b_value_temp value4b_temp 
WHERE value4b.oram_id = value4b_temp.oram_id AND value4b.selection = value4b_temp.selection)
	
INSERT INTO wetland_census.metric4b_value SELECT oram_id, selection, metric4b_value, lookup_id FROM metric4b_value_temp value4b_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric4b_value value4b WHERE value4b.oram_id = value4b_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric4b_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric4c_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric4c_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric4c_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric4c_value_temp AS (
SELECT norm4c.oram_id, norm4c.selection, lookup.value AS metric4c_value, lookup.lookup_id FROM wetland_census.metric4c_norm norm4c LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm4c.selection AND lookup.metric =
'm4c_habitat_alteration'),
	
upsert4c AS (UPDATE wetland_census.metric4c_value value4c SET oram_id = value4c_temp.oram_id, selection = value4c_temp.selection, metric4c_value = value4c_temp.metric4c_value,
lookup_id = value4c_temp.lookup_id
FROM metric4c_value_temp value4c_temp 
WHERE value4c.oram_id = value4c_temp.oram_id AND value4c.selection = value4c_temp.selection)
	
INSERT INTO wetland_census.metric4c_value SELECT oram_id, selection, metric4c_value, lookup_id FROM metric4c_value_temp value4c_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric4c_value value4c WHERE value4c.oram_id = value4c_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric4c_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric5_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric5_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric5_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric5_value_temp AS (
SELECT norm5.oram_id, norm5.selection, lookup.value AS metric5_value, lookup.lookup_id FROM wetland_census.metric5_norm norm5 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm5.selection),
	
upsert5 AS (UPDATE wetland_census.metric5_value value5 SET oram_id = value5_temp.oram_id, selection = value5_temp.selection, metric5_value = value5_temp.metric5_value,
lookup_id = value5_temp.lookup_id
FROM metric5_value_temp value5_temp 
WHERE value5.oram_id = value5_temp.oram_id AND value5.selection = value5_temp.selection)
	
INSERT INTO wetland_census.metric5_value SELECT oram_id, selection, metric5_value, lookup_id FROM metric5_value_temp value5_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric5_value value5 WHERE value5.oram_id = value5_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric5_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a1_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a1_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a1_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a1_value_temp AS (
SELECT norm6a1.oram_id, norm6a1.selection, lookup.value AS metric6a1_value, lookup.lookup_id FROM wetland_census.metric6a1_norm norm6a1 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a1.selection AND lookup.metric =
'm6a_aquatic_bed'),
	
upsert6a1 AS (UPDATE wetland_census.metric6a1_value value6a1 SET oram_id = value6a1_temp.oram_id, selection = value6a1_temp.selection, metric6a1_value = value6a1_temp.metric6a1_value,
lookup_id = value6a1_temp.lookup_id
FROM metric6a1_value_temp value6a1_temp 
WHERE value6a1.oram_id = value6a1_temp.oram_id AND value6a1.selection = value6a1_temp.selection)
	
INSERT INTO wetland_census.metric6a1_value SELECT oram_id, selection, metric6a1_value, lookup_id FROM metric6a1_value_temp value6a1_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a1_value value6a1 WHERE value6a1.oram_id = value6a1_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a1_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a2_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a2_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a2_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a2_value_temp AS (
SELECT norm6a2.oram_id, norm6a2.selection, lookup.value AS metric6a2_value, lookup.lookup_id FROM wetland_census.metric6a2_norm norm6a2 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a2.selection AND lookup.metric =
'm6a_emergent'),
	
upsert6a2 AS (UPDATE wetland_census.metric6a2_value value6a2 SET oram_id = value6a2_temp.oram_id, selection = value6a2_temp.selection, metric6a2_value = value6a2_temp.metric6a2_value,
lookup_id = value6a2_temp.lookup_id
FROM metric6a2_value_temp value6a2_temp 
WHERE value6a2.oram_id = value6a2_temp.oram_id AND value6a2.selection = value6a2_temp.selection)
	
INSERT INTO wetland_census.metric6a2_value SELECT oram_id, selection, metric6a2_value, lookup_id FROM metric6a2_value_temp value6a2_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a2_value value6a2 WHERE value6a2.oram_id = value6a2_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a2_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a3_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a3_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a3_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a3_value_temp AS (
SELECT norm6a3.oram_id, norm6a3.selection, lookup.value AS metric6a3_value, lookup.lookup_id FROM wetland_census.metric6a3_norm norm6a3 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a3.selection AND lookup.metric =
'm6a_shrub'),
	
upsert6a3 AS (UPDATE wetland_census.metric6a3_value value6a3 SET oram_id = value6a3_temp.oram_id, selection = value6a3_temp.selection, metric6a3_value = value6a3_temp.metric6a3_value,
lookup_id = value6a3_temp.lookup_id
FROM metric6a3_value_temp value6a3_temp 
WHERE value6a3.oram_id = value6a3_temp.oram_id AND value6a3.selection = value6a3_temp.selection)
	
INSERT INTO wetland_census.metric6a3_value SELECT oram_id, selection, metric6a3_value, lookup_id FROM metric6a3_value_temp value6a3_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a3_value value6a3 WHERE value6a3.oram_id = value6a3_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a3_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a4_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a4_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a4_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a4_value_temp AS (
SELECT norm6a4.oram_id, norm6a4.selection, lookup.value AS metric6a4_value, lookup.lookup_id FROM wetland_census.metric6a4_norm norm6a4 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a4.selection AND lookup.metric = 'm6a_forest'),
	
upsert6a4 AS (UPDATE wetland_census.metric6a4_value value6a4 SET oram_id = value6a4_temp.oram_id, selection = value6a4_temp.selection, metric6a4_value = value6a4_temp.metric6a4_value,
lookup_id = value6a4_temp.lookup_id
FROM metric6a4_value_temp value6a4_temp 
WHERE value6a4.oram_id = value6a4_temp.oram_id AND value6a4.selection = value6a4_temp.selection)
	
INSERT INTO wetland_census.metric6a4_value SELECT oram_id, selection, metric6a4_value, lookup_id FROM metric6a4_value_temp value6a4_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a4_value value6a4 WHERE value6a4.oram_id = value6a4_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a4_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a5_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a5_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a5_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a5_value_temp AS (
SELECT norm6a5.oram_id, norm6a5.selection, lookup.value AS metric6a5_value, lookup.lookup_id FROM wetland_census.metric6a5_norm norm6a5 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a5.selection AND lookup.metric = 'm6a_mudflats'),
	
upsert6a5 AS (UPDATE wetland_census.metric6a5_value value6a5 SET oram_id = value6a5_temp.oram_id, selection = value6a5_temp.selection, metric6a5_value = value6a5_temp.metric6a5_value,
lookup_id = value6a5_temp.lookup_id
FROM metric6a5_value_temp value6a5_temp 
WHERE value6a5.oram_id = value6a5_temp.oram_id AND value6a5.selection = value6a5_temp.selection)
	
INSERT INTO wetland_census.metric6a5_value SELECT oram_id, selection, metric6a5_value, lookup_id FROM metric6a5_value_temp value6a5_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a5_value value6a5 WHERE value6a5.oram_id = value6a5_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a5_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a6_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a6_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a6_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a6_value_temp AS (
SELECT norm6a6.oram_id, norm6a6.selection, lookup.value AS metric6a6_value, lookup.lookup_id FROM wetland_census.metric6a6_norm norm6a6 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a6.selection AND lookup.metric = 'm6a_open_water'),
	
upsert6a6 AS (UPDATE wetland_census.metric6a6_value value6a6 SET oram_id = value6a6_temp.oram_id, selection = value6a6_temp.selection, metric6a6_value = value6a6_temp.metric6a6_value,
lookup_id = value6a6_temp.lookup_id
FROM metric6a6_value_temp value6a6_temp 
WHERE value6a6.oram_id = value6a6_temp.oram_id AND value6a6.selection = value6a6_temp.selection)
	
INSERT INTO wetland_census.metric6a6_value SELECT oram_id, selection, metric6a6_value, lookup_id FROM metric6a6_value_temp value6a6_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a6_value value6a6 WHERE value6a6.oram_id = value6a6_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a6_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6a7_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6a7_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6a7_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6a7_value_temp AS (
SELECT norm6a7.oram_id, norm6a7.selection, lookup.value AS metric6a7_value, lookup.lookup_id FROM wetland_census.metric6a7_norm norm6a7 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6a7.selection AND lookup.metric = 'm6a_other'),
	
upsert6a7 AS (UPDATE wetland_census.metric6a7_value value6a7 SET oram_id = value6a7_temp.oram_id, selection = value6a7_temp.selection, metric6a7_value = value6a7_temp.metric6a7_value,
lookup_id = value6a7_temp.lookup_id
FROM metric6a7_value_temp value6a7_temp 
WHERE value6a7.oram_id = value6a7_temp.oram_id AND value6a7.selection = value6a7_temp.selection)
	
INSERT INTO wetland_census.metric6a7_value SELECT oram_id, selection, metric6a7_value, lookup_id FROM metric6a7_value_temp value6a7_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a7_value value6a7 WHERE value6a7.oram_id = value6a7_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6a7_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6b_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6b_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6b_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6b_value_temp AS (
SELECT norm6b.oram_id, norm6b.selection, lookup.value AS metric6b_value, lookup.lookup_id FROM wetland_census.metric6b_norm norm6b LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6b.selection),
	
upsert6b AS (UPDATE wetland_census.metric6b_value value6b SET oram_id = value6b_temp.oram_id, selection = value6b_temp.selection, metric6b_value = value6b_temp.metric6b_value,
lookup_id = value6b_temp.lookup_id
FROM metric6b_value_temp value6b_temp 
WHERE value6b.oram_id = value6b_temp.oram_id AND value6b.selection = value6b_temp.selection)
	
INSERT INTO wetland_census.metric6b_value SELECT oram_id, selection, metric6b_value, lookup_id FROM metric6b_value_temp value6b_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6b_value value6b WHERE value6b.oram_id = value6b_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6b_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6c_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6c_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6c_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6c_value_temp AS (
SELECT norm6c.oram_id, norm6c.selection, lookup.value AS metric6c_value, lookup.lookup_id FROM wetland_census.metric6c_norm norm6c LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6c.selection),
	
upsert6c AS (UPDATE wetland_census.metric6c_value value6c SET oram_id = value6c_temp.oram_id, selection = value6c_temp.selection, metric6c_value = value6c_temp.metric6c_value,
lookup_id = value6c_temp.lookup_id
FROM metric6c_value_temp value6c_temp 
WHERE value6c.oram_id = value6c_temp.oram_id AND value6c.selection = value6c_temp.selection)
	
INSERT INTO wetland_census.metric6c_value SELECT oram_id, selection, metric6c_value, lookup_id FROM metric6c_value_temp value6c_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6c_value value6c WHERE value6c.oram_id = value6c_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6c_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6d1_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6d1_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6d1_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6d1_value_temp AS (
SELECT norm6d1.oram_id, norm6d1.selection, lookup.value AS metric6d1_value, lookup.lookup_id FROM wetland_census.metric6d1_norm norm6d1 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6d1.selection AND lookup.metric = 'm6d_microtopography_vegetation_hummuckstussuck'),
	
upsert6d1 AS (UPDATE wetland_census.metric6d1_value value6d1 SET oram_id = value6d1_temp.oram_id, selection = value6d1_temp.selection, metric6d1_value = value6d1_temp.metric6d1_value,
lookup_id = value6d1_temp.lookup_id
FROM metric6d1_value_temp value6d1_temp 
WHERE value6d1.oram_id = value6d1_temp.oram_id AND value6d1.selection = value6d1_temp.selection)
	
INSERT INTO wetland_census.metric6d1_value SELECT oram_id, selection, metric6d1_value, lookup_id FROM metric6d1_value_temp value6d1_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d1_value value6d1 WHERE value6d1.oram_id = value6d1_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6d1_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6d2_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6d2_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6d2_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6d2_value_temp AS (
SELECT norm6d2.oram_id, norm6d2.selection, lookup.value AS metric6d2_value, lookup.lookup_id FROM wetland_census.metric6d2_norm norm6d2 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6d2.selection AND lookup.metric = 'm6d_microtopography_course_woody_debris_15cm_6in'),
	
upsert6d2 AS (UPDATE wetland_census.metric6d2_value value6d2 SET oram_id = value6d2_temp.oram_id, selection = value6d2_temp.selection, metric6d2_value = value6d2_temp.metric6d2_value,
lookup_id = value6d2_temp.lookup_id
FROM metric6d2_value_temp value6d2_temp 
WHERE value6d2.oram_id = value6d2_temp.oram_id AND value6d2.selection = value6d2_temp.selection)
	
INSERT INTO wetland_census.metric6d2_value SELECT oram_id, selection, metric6d2_value, lookup_id FROM metric6d2_value_temp value6d2_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d2_value value6d2 WHERE value6d2.oram_id = value6d2_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6d2_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6d3_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6d3_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6d3_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6d3_value_temp AS (
SELECT norm6d3.oram_id, norm6d3.selection, lookup.value AS metric6d3_value, lookup.lookup_id FROM wetland_census.metric6d3_norm norm6d3 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6d3.selection AND lookup.metric = 'm6d_microtopography_standing_dead_25cm_10in_dbh'),
	
upsert6d3 AS (UPDATE wetland_census.metric6d3_value value6d3 SET oram_id = value6d3_temp.oram_id, selection = value6d3_temp.selection, metric6d3_value = value6d3_temp.metric6d3_value,
lookup_id = value6d3_temp.lookup_id
FROM metric6d3_value_temp value6d3_temp 
WHERE value6d3.oram_id = value6d3_temp.oram_id AND value6d3.selection = value6d3_temp.selection)
	
INSERT INTO wetland_census.metric6d3_value SELECT oram_id, selection, metric6d3_value, lookup_id FROM metric6d3_value_temp value6d3_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d3_value value6d3 WHERE value6d3.oram_id = value6d3_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6d3_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric6d4_value | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric6d4_value() CASCADE;
CREATE FUNCTION wetland_census.oram_metric6d4_value ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN	
WITH metric6d4_value_temp AS (
SELECT norm6d4.oram_id, norm6d4.selection, lookup.value AS metric6d4_value, lookup.lookup_id FROM wetland_census.metric6d4_norm norm6d4 LEFT OUTER JOIN
	wetland_census.oram_score_lookup_all lookup ON lookup.selection  = norm6d4.selection AND lookup.metric = 'm6d_microtopography_amphibian_breeding_pools'),
	
upsert6d4 AS (UPDATE wetland_census.metric6d4_value value6d4 SET oram_id = value6d4_temp.oram_id, selection = value6d4_temp.selection, metric6d4_value = value6d4_temp.metric6d4_value,
lookup_id = value6d4_temp.lookup_id
FROM metric6d4_value_temp value6d4_temp 
WHERE value6d4.oram_id = value6d4_temp.oram_id AND value6d4.selection = value6d4_temp.selection)
	
INSERT INTO wetland_census.metric6d4_value SELECT oram_id, selection, metric6d4_value, lookup_id FROM metric6d4_value_temp value6d4_temp
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d4_value value6d4 WHERE value6d4.oram_id = value6d4_temp.oram_id
	)
;
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric6d4_value() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_metric_insert_all | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_metric_insert_all() CASCADE;
CREATE FUNCTION wetland_census.oram_metric_insert_all ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN
WITH oram_all_id AS ( SELECT fulcrum_id, created_at, updated_at, created_by, updated_by, system_created_at, system_updated_at, version, status, project, assigned_to, latitude, longitude, geometry, reservation, polygon_id, date, data_recorded_by_initials, m1_wetland_area, m2a_upland_buffer_width, m2b_surrounding_land_use, m3a_sources_of_water, m3b_connectivity, m3c_maximum_water_depth, m3d_duration_inundation_saturation, m3e_modifications_to_hydrologic_regime, disturbances_hydro, m4a_substrate_disturbance, m4b_habitat_development, m4c_habitat_alteration, disturbances_substrate, disturbances_substrate_other, m6a_aquatic_bed, m6a_emergent, m6a_shrub, m6a_forest, m6a_mudflats, m6a_open_water, m6a_other, m6a_other_list, m6b_horizontal_plan_view_interspersion, m6c_coverage_of_invasive_plants, m6d_microtopography_vegetation_hummuckstussuck, m6d_microtopography_course_woody_debris_15cm_6in, m6d_microtopography_standing_dead_25cm_10in_dbh, m6d_microtopography_amphibian_breeding_pools, m5_special_wetlands, notes, photos, photos_caption, photos_url, nextval ('wetland_census.wetland_oram_id_seq'::regclass) AS oram_id FROM wetland_census.oram_v2 oram_v2
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_id WHERE fulcrum_id = oram_v2.fulcrum_id
	)),
oram_id_new AS(
SELECT oram_id, fulcrum_id FROM oram_all_id
),
metric1_split AS(
SELECT oram_id, regexp_split_to_table(m1_wetland_area, ',') AS selection1 FROM oram_all_id
),
metric2a_split AS(
SELECT oram_id, regexp_split_to_table(m2a_upland_buffer_width, ',') AS selection2a FROM oram_all_id
),
metric2b_split AS(
SELECT oram_id, regexp_split_to_table(m2b_surrounding_land_use, ',') AS selection2b FROM oram_all_id
),
metric3a_split AS(
SELECT oram_id, regexp_split_to_table(m3a_sources_of_water, ',') AS selection3a FROM oram_all_id
),
metric3b_split AS(
SELECT oram_id, regexp_split_to_table(m3b_connectivity, ',') AS selection3b FROM oram_all_id
),
metric3c_split AS(
SELECT oram_id, regexp_split_to_table(m3c_maximum_water_depth, ',') AS selection3c FROM oram_all_id
),
metric3d_split AS(
SELECT oram_id, regexp_split_to_table(m3d_duration_inundation_saturation, ',') AS selection3d FROM oram_all_id
),
metric3e_split AS(
SELECT oram_id, regexp_split_to_table(m3e_modifications_to_hydrologic_regime, ',') AS selection3e FROM oram_all_id
),
metric4a_split AS(
SELECT oram_id, regexp_split_to_table(m4a_substrate_disturbance, ',') AS selection4a FROM oram_all_id
),
metric4b_split AS(
SELECT oram_id, regexp_split_to_table(m4b_habitat_development, ',') AS selection4b FROM oram_all_id
),
metric4c_split AS(
SELECT oram_id, regexp_split_to_table(m4c_habitat_alteration, ',') AS selection4c FROM oram_all_id
),
metric5_split AS(
SELECT oram_id, regexp_split_to_table(m5_special_wetlands, ',') AS selection5 FROM oram_all_id
),
metric6a1_split AS(
SELECT oram_id, regexp_split_to_table(m6a_aquatic_bed, ',') AS selection6a1 FROM oram_all_id
),
metric6a2_split AS(
SELECT oram_id, regexp_split_to_table(m6a_emergent, ',') AS selection6a2 FROM oram_all_id
),
metric6a3_split AS(
SELECT oram_id, regexp_split_to_table(m6a_shrub, ',') AS selection6a3 FROM oram_all_id
),
metric6a4_split AS(
SELECT oram_id, regexp_split_to_table(m6a_forest, ',') AS selection6a4 FROM oram_all_id
),
metric6a5_split AS(
SELECT oram_id, regexp_split_to_table(m6a_mudflats, ',') AS selection6a5 FROM oram_all_id
),
metric6a6_split AS(
SELECT oram_id, regexp_split_to_table(m6a_open_water, ',') AS selection6a6 FROM oram_all_id
),
metric6a7_split AS(
SELECT oram_id, regexp_split_to_table(m6a_other, ',') AS selection6a7 FROM oram_all_id
),
metric6b_split AS(
SELECT oram_id, regexp_split_to_table(m6b_horizontal_plan_view_interspersion, ',') AS selection6b FROM oram_all_id
),
metric6c_split AS(
SELECT oram_id, regexp_split_to_table(m6c_coverage_of_invasive_plants, ',') AS selection6c FROM oram_all_id
),
metric6d1_split AS(
SELECT oram_id, regexp_split_to_table(m6d_microtopography_vegetation_hummuckstussuck, ',') AS selection6d1 FROM oram_all_id
),
metric6d2_split AS(
SELECT oram_id, regexp_split_to_table(m6d_microtopography_course_woody_debris_15cm_6in, ',') AS selection6d2 FROM oram_all_id
),
metric6d3_split AS(
SELECT oram_id, regexp_split_to_table(m6d_microtopography_standing_dead_25cm_10in_dbh, ',') AS selection6d3 FROM oram_all_id
),
metric6d4_split AS(
SELECT oram_id, regexp_split_to_table(m6d_microtopography_amphibian_breeding_pools, ',') AS selection6d4 FROM oram_all_id
),
polygon_id_split AS(
SELECT oram_id, regexp_split_to_table(polygon_id, ',') AS polygon_id FROM oram_all_id
),
data_recorded_by_initials_split AS(
SELECT oram_id, regexp_split_to_table(data_recorded_by_initials, ',') AS data_recorded_by_initials FROM oram_all_id
),
reservation_split AS(
SELECT oram_id, regexp_split_to_table(reservation, ',') AS reservation FROM oram_all_id
),
disturbances_hydro_split AS(
SELECT oram_id, regexp_split_to_table(disturbances_hydro, ',') AS disturbances_hydro FROM oram_all_id
),
disturbances_substrate_split AS(
SELECT oram_id, regexp_split_to_table(disturbances_substrate, ',') AS disturbances_substrate FROM oram_all_id
),
oram_notes AS(
SELECT oram_id, notes FROM oram_all_id
),
oram_photos AS (SELECT oram_id, regexp_split_to_table(photos, ',') AS photos FROM oram_all_id),
oram_photos_caption AS (SELECT oram_id, regexp_split_to_table(photos_caption, ',') AS photos_caption FROM oram_all_id),
oram_photos_url AS (SELECT oram_id, regexp_split_to_table(photos_url, ',') AS photos_url FROM oram_all_id),

ins_id AS (INSERT INTO wetland_census.oram_id SELECT oram_id, fulcrum_id FROM oram_id_new
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_id WHERE fulcrum_id = oram_id_new.fulcrum_id
	)),
ins1 AS (INSERT INTO wetland_census.metric1_norm SELECT oram_id, selection1 FROM metric1_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric1_norm norm1 WHERE oram_id = metric1_split.oram_id
	)),
ins2 AS (INSERT INTO wetland_census.metric2a_norm SELECT oram_id, selection2a FROM metric2a_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric2a_norm norm2a WHERE oram_id = metric2a_split.oram_id
	)),
ins3 AS (INSERT INTO wetland_census.metric2b_norm SELECT oram_id, selection2b FROM metric2b_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric2b_norm norm2b WHERE oram_id = metric2b_split.oram_id
	)),
ins4 AS (INSERT INTO wetland_census.metric3a_norm SELECT oram_id, selection3a FROM metric3a_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3a_norm norm3a WHERE oram_id = metric3a_split.oram_id
	)),
ins5 AS (INSERT INTO wetland_census.metric3b_norm SELECT oram_id, selection3b FROM metric3b_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3b_norm norm3b WHERE oram_id = metric3b_split.oram_id
	)),
ins6 AS (INSERT INTO wetland_census.metric3c_norm SELECT oram_id, selection3c FROM metric3c_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3c_norm norm3c WHERE oram_id = metric3c_split.oram_id
	)),
ins7 AS (INSERT INTO wetland_census.metric3d_norm SELECT oram_id, selection3d FROM metric3d_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3d_norm norm3d WHERE oram_id = metric3d_split.oram_id
	)),
ins8 AS (INSERT INTO wetland_census.metric3e_norm SELECT oram_id, selection3e FROM metric3e_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric3e_norm norm3e WHERE oram_id = metric3e_split.oram_id
	)),
ins9 AS (INSERT INTO wetland_census.metric4a_norm SELECT oram_id, selection4a FROM metric4a_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric4a_norm norm4a WHERE oram_id = metric4a_split.oram_id
	)),
ins10 AS (INSERT INTO wetland_census.metric4b_norm SELECT oram_id, selection4b FROM metric4b_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric4b_norm norm4b WHERE oram_id = metric4b_split.oram_id
	)),
ins11 AS (INSERT INTO wetland_census.metric4c_norm SELECT oram_id, selection4c FROM metric4c_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric4c_norm norm4c WHERE oram_id = metric4c_split.oram_id
	)),
ins12 AS (INSERT INTO wetland_census.metric5_norm SELECT oram_id, selection5 FROM metric5_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric5_norm norm5 WHERE oram_id = metric5_split.oram_id
	)),
ins13 AS (INSERT INTO wetland_census.metric6a1_norm SELECT oram_id, selection6a1 FROM metric6a1_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a1_norm norm6a1 WHERE oram_id = metric6a1_split.oram_id
	)),
ins14 AS (INSERT INTO wetland_census.metric6a2_norm SELECT oram_id, selection6a2 FROM metric6a2_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a2_norm norm6a2 WHERE oram_id = metric6a2_split.oram_id
	)),
ins15 AS (INSERT INTO wetland_census.metric6a3_norm SELECT oram_id, selection6a3 FROM metric6a3_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a3_norm norm6a3 WHERE oram_id = metric6a3_split.oram_id
	)),
ins16 AS (INSERT INTO wetland_census.metric6a4_norm SELECT oram_id, selection6a4 FROM metric6a4_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a4_norm norm6a4 WHERE oram_id = metric6a4_split.oram_id
	)),
ins17 AS (INSERT INTO wetland_census.metric6a5_norm SELECT oram_id, selection6a5 FROM metric6a5_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a5_norm norm6a5 WHERE oram_id = metric6a5_split.oram_id
	)),
ins18 AS (INSERT INTO wetland_census.metric6a6_norm SELECT oram_id, selection6a6 FROM metric6a6_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a6_norm norm6a6 WHERE oram_id = metric6a6_split.oram_id
	)),
ins19 AS (INSERT INTO wetland_census.metric6a7_norm SELECT oram_id, selection6a7 FROM metric6a7_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6a7_norm norm6a7 WHERE oram_id = metric6a7_split.oram_id
	)),
ins20 AS (INSERT INTO wetland_census.metric6b_norm SELECT oram_id, selection6b FROM metric6b_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6b_norm norm6b WHERE oram_id = metric6b_split.oram_id
	)),
ins21 AS (INSERT INTO wetland_census.metric6c_norm SELECT oram_id, selection6c FROM metric6c_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6c_norm norm6c WHERE oram_id = metric6c_split.oram_id
	)),
ins22 AS (INSERT INTO wetland_census.metric6d1_norm SELECT oram_id, selection6d1 FROM metric6d1_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d1_norm norm6d1 WHERE oram_id = metric6d1_split.oram_id
	)),
ins23 AS (INSERT INTO wetland_census.metric6d2_norm SELECT oram_id, selection6d2 FROM metric6d2_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d2_norm norm6d2 WHERE oram_id = metric6d2_split.oram_id
	)),
ins24 AS (INSERT INTO wetland_census.metric6d3_norm SELECT oram_id, selection6d3 FROM metric6d3_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d3_norm norm6d3 WHERE oram_id = metric6d3_split.oram_id
	)),
ins25 AS (INSERT INTO wetland_census.metric6d4_norm SELECT oram_id, selection6d4 FROM metric6d4_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.metric6d4_norm norm6d4 WHERE oram_id = metric6d4_split.oram_id
	)),	
ins27 AS (INSERT INTO wetland_census.oram_poly_id_norm SELECT oram_id, polygon_id FROM polygon_id_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_poly_id_norm norm_poly_id WHERE oram_id = polygon_id_split.oram_id 
	)),
ins28 AS (INSERT INTO wetland_census.oram_recorder_norm SELECT oram_id, data_recorded_by_initials FROM data_recorded_by_initials_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_recorder_norm norm_recorder WHERE oram_id = data_recorded_by_initials_split.oram_id
	)),
ins29 AS (INSERT INTO wetland_census.oram_reservation_norm SELECT oram_id, reservation FROM reservation_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_reservation_norm norm_res WHERE oram_id = reservation_split.oram_id
	)),
ins30 AS (INSERT INTO wetland_census.hydro_disturbances_norm SELECT oram_id, disturbances_hydro FROM disturbances_hydro_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.hydro_disturbances_norm norm_disturbances_hydro WHERE oram_id = disturbances_hydro_split.oram_id
	)),
ins31 AS (INSERT INTO wetland_census.substrate_disturbances_norm SELECT oram_id, disturbances_substrate FROM disturbances_substrate_split
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.substrate_disturbances_norm WHERE oram_id = disturbances_substrate_split.oram_id
	)),
ins32 AS (INSERT INTO wetland_census.oram_notes SELECT oram_id, notes FROM oram_notes
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_notes WHERE oram_id = oram_notes.oram_id
	) AND oram_notes.notes IS NOT NULL),
ins33 AS (INSERT INTO wetland_census.oram_photos_norm SELECT oram_id, photos FROM oram_photos
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_photos_norm WHERE oram_id = oram_photos.oram_id AND photos = oram_photos.photos
	)AND oram_photos.photos IS NOT NULL),

ins34 AS (INSERT INTO wetland_census.oram_photos_caption_norm SELECT oram_id, photos_caption FROM oram_photos_caption
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_photos_caption_norm WHERE oram_id = oram_photos_caption.oram_id AND photos_caption = oram_photos_caption.photos_caption
	)AND oram_photos_caption.photos_caption IS NOT NULL)

INSERT INTO wetland_census.oram_photos_url_norm SELECT oram_id, photos_url FROM oram_photos_url
WHERE NOT EXISTS
	(
	SELECT 1 FROM wetland_census.oram_photos_url_norm WHERE oram_id = oram_photos_url.oram_id AND photos_url = oram_photos_url.photos_url
	)AND oram_photos_url.photos_url IS NOT NULL
;

RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_metric_insert_all() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_oram_data | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_oram_data CASCADE;
CREATE TABLE wetland_census.cm_oram_data(
	fulcrum_id text,
	created_at timestamp,
	updated_at timestamp,
	created_by text,
	updated_by text,
	system_created_at timestamp,
	system_updated_at timestamp,
	version bigint,
	status text,
	project text,
	assigned_to text,
	latitude numeric,
	longitude numeric,
	geometry geometry,
	reservation text,
	polygon_id text,
	oram_id text NOT NULL,
	date text,
	data_recorded_by_initials text,
	m1_wetland_area text,
	m2a_upland_buffer_width text,
	m2b_surrounding_land_use text,
	m3a_sources_of_water text,
	m3b_connectivity text,
	m3c_maximum_water_depth text,
	m3d_duration_inundation_saturation text,
	m3e_modifications_to_hydrologic_regime text,
	disturbances_hydro text,
	disturbances_hydro_other text,
	m4a_substrate_disturbance text,
	m4b_habitat_development text,
	m4c_habitat_alteration text,
	disturbances_substrate text,
	disturbances_substrate_other text,
	m6a_aquatic_bed text,
	m6a_emergent text,
	m6a_shrub text,
	m6a_forest text,
	m6a_mudflats text,
	m6a_open_water text,
	m6a_other text,
	m6a_other_list text,
	m6b_horizontal_plan_view_interspersion text,
	m6c_coverage_of_invasive_plants text,
	m6d_microtopography_vegetation_hummuckstussuck text,
	m6d_microtopography_course_woody_debris_15cm_6in text,
	m6d_microtopography_standing_dead_25cm_10in_dbh text,
	m6d_microtopography_amphibian_breeding_pools text,
	m5_special_wetlands text,
	photos text,
	photos_caption text,
	photos_url text,
	CONSTRAINT cm_oram_data_pkey PRIMARY KEY (oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_oram_data OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_oram_data_photos | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_oram_data_photos CASCADE;
CREATE TABLE wetland_census.cm_oram_data_photos(
	fulcrum_id text,
	fulcrum_parent_id text,
	fulcrum_record_id text,
	version bigint,
	caption text,
	latitude double precision,
	longitude double precision,
	geometry geometry,
	file_size bigint,
	uploaded_at timestamp,
	exif_date_time text,
	exif_gps_altitude text,
	exif_gps_date_stamp text,
	exif_gps_time_stamp text,
	exif_gps_dop text,
	exif_gps_img_direction text,
	exif_gps_img_direction_ref text,
	exif_gps_latitude text,
	exif_gps_latitude_ref text,
	exif_gps_longitude text,
	exif_gps_longitude_ref text,
	exif_make text,
	exif_model text,
	exif_orientation text,
	exif_pixel_x_dimension text,
	exif_pixel_y_dimension text,
	exif_software text,
	exif_x_resolution text,
	exif_y_resolution text
);
-- ddl-end --
ALTER TABLE wetland_census.cm_oram_data_photos OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_id | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_id CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_id(
	polygon_id text,
	reservation text,
	classification_level text,
	classification_id bigint NOT NULL,
	fulcrum_id character varying(100),
	CONSTRAINT cm_wetland_classification_id_pkey PRIMARY KEY (classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_id OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_cowardin_classification | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_cowardin_classification CASCADE;
CREATE TABLE wetland_census.cm_wetland_cowardin_classification(
	classification_id bigint NOT NULL,
	cowardin_classification text NOT NULL,
	CONSTRAINT cm_wetland_cowardin_classification_pkey PRIMARY KEY (cowardin_classification,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_cowardin_classification OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_cowardin_special_modifier | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_cowardin_special_modifier CASCADE;
CREATE TABLE wetland_census.cm_wetland_cowardin_special_modifier(
	classification_id bigint NOT NULL,
	cowardin_special_modifier text NOT NULL,
	CONSTRAINT cm_wetland_cowardin_special_modifier_pkey PRIMARY KEY (cowardin_special_modifier,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_cowardin_special_modifier OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_cowardin_water_regime | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_cowardin_water_regime CASCADE;
CREATE TABLE wetland_census.cm_wetland_cowardin_water_regime(
	classification_id bigint NOT NULL,
	cowardin_water_regime text NOT NULL,
	CONSTRAINT cm_wetland_cowardin_water_regime_pkey PRIMARY KEY (cowardin_water_regime,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_cowardin_water_regime OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_inland_landform_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_inland_landform_norm CASCADE;
CREATE TABLE wetland_census.cm_wetland_inland_landform_norm(
	classification_id bigint NOT NULL,
	inland_landform text NOT NULL,
	CONSTRAINT cm_wetland_inland_landform_norm_pkey PRIMARY KEY (inland_landform,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_inland_landform_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_landscape_position_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_landscape_position_norm CASCADE;
CREATE TABLE wetland_census.cm_wetland_landscape_position_norm(
	classification_id bigint NOT NULL,
	landscape_position text NOT NULL,
	CONSTRAINT cm_wetland_landscape_position_norm_pkey PRIMARY KEY (landscape_position,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_landscape_position_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_llww_modifiers | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_llww_modifiers CASCADE;
CREATE TABLE wetland_census.cm_wetland_llww_modifiers(
	classification_id bigint NOT NULL,
	llww_modifiers text NOT NULL,
	CONSTRAINT cm_wetland_llww_modifiers_pkey PRIMARY KEY (llww_modifiers,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_llww_modifiers OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric1_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric1_value CASCADE;
CREATE TABLE wetland_census.metric1_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric1_value numeric,
	lookup_id integer,
	CONSTRAINT metric1_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric1_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric2a_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric2a_value CASCADE;
CREATE TABLE wetland_census.metric2a_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric2a_value numeric,
	lookup_id integer,
	CONSTRAINT metric2a_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric2a_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric2b_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric2b_value CASCADE;
CREATE TABLE wetland_census.metric2b_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric2b_value numeric,
	lookup_id integer,
	CONSTRAINT metric2b_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric2b_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3a_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3a_value CASCADE;
CREATE TABLE wetland_census.metric3a_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric3a_value numeric,
	lookup_id integer,
	CONSTRAINT metric3a_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3a_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3b_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3b_value CASCADE;
CREATE TABLE wetland_census.metric3b_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric3b_value numeric,
	lookup_id integer,
	CONSTRAINT metric3b_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3b_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3c_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3c_value CASCADE;
CREATE TABLE wetland_census.metric3c_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric3c_value numeric,
	lookup_id integer,
	CONSTRAINT metric3c_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3c_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3d_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3d_value CASCADE;
CREATE TABLE wetland_census.metric3d_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric3d_value numeric,
	lookup_id integer,
	CONSTRAINT metric3d_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3d_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3e_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3e_value CASCADE;
CREATE TABLE wetland_census.metric3e_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric3e_value numeric,
	lookup_id integer,
	CONSTRAINT metric3e_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3e_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric4a_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric4a_value CASCADE;
CREATE TABLE wetland_census.metric4a_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric4a_value numeric,
	lookup_id integer,
	CONSTRAINT metric4a_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric4a_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric4b_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric4b_value CASCADE;
CREATE TABLE wetland_census.metric4b_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric4b_value numeric,
	lookup_id integer,
	CONSTRAINT metric4b_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric4b_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric4c_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric4c_value CASCADE;
CREATE TABLE wetland_census.metric4c_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric4c_value numeric,
	lookup_id integer,
	CONSTRAINT metric4c_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric4c_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric5_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric5_value CASCADE;
CREATE TABLE wetland_census.metric5_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric5_value numeric,
	lookup_id integer,
	CONSTRAINT metric5_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric5_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a1_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a1_value CASCADE;
CREATE TABLE wetland_census.metric6a1_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a1_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a1_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a1_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a2_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a2_value CASCADE;
CREATE TABLE wetland_census.metric6a2_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a2_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a2_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a2_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a3_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a3_value CASCADE;
CREATE TABLE wetland_census.metric6a3_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a3_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a3_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a3_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a4_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a4_value CASCADE;
CREATE TABLE wetland_census.metric6a4_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a4_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a4_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a4_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a5_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a5_value CASCADE;
CREATE TABLE wetland_census.metric6a5_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a5_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a5_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a5_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a6_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a6_value CASCADE;
CREATE TABLE wetland_census.metric6a6_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a6_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a6_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a6_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a7_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a7_value CASCADE;
CREATE TABLE wetland_census.metric6a7_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6a7_value numeric,
	lookup_id integer,
	CONSTRAINT metric6a7_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a7_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6b_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6b_value CASCADE;
CREATE TABLE wetland_census.metric6b_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6b_value numeric,
	lookup_id integer,
	CONSTRAINT metric6b_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6b_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6c_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6c_value CASCADE;
CREATE TABLE wetland_census.metric6c_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6c_value numeric,
	lookup_id integer,
	CONSTRAINT metric6c_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6c_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d1_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d1_value CASCADE;
CREATE TABLE wetland_census.metric6d1_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6d1_value numeric,
	lookup_id integer,
	CONSTRAINT metric6d1_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d1_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d2_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d2_value CASCADE;
CREATE TABLE wetland_census.metric6d2_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6d2_value numeric,
	lookup_id integer,
	CONSTRAINT metric6d2_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d2_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d3_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d3_value CASCADE;
CREATE TABLE wetland_census.metric6d3_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6d3_value numeric,
	lookup_id integer,
	CONSTRAINT metric6d3_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d3_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d4_value | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d4_value CASCADE;
CREATE TABLE wetland_census.metric6d4_value(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	metric6d4_value numeric,
	lookup_id integer,
	CONSTRAINT metric6d4_value_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d4_value OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_oram_calcs | type: VIEW --
-- DROP VIEW IF EXISTS wetland_census.cm_wetland_oram_calcs CASCADE;
CREATE VIEW wetland_census.cm_wetland_oram_calcs
AS 

WITH metric1 AS (
         SELECT metric1_value.oram_id,
            avg(metric1_value.metric1_value) AS metric1_score
           FROM metric1_value
          GROUP BY metric1_value.oram_id
        ), metric2a AS (
         SELECT metric2a_value.oram_id,
            avg(metric2a_value.metric2a_value) AS metric2a_score
           FROM metric2a_value
          GROUP BY metric2a_value.oram_id
        ), metric2b AS (
         SELECT metric2b_value.oram_id,
            avg(metric2b_value.metric2b_value) AS metric2b_score
           FROM metric2b_value
          GROUP BY metric2b_value.oram_id
        ), metric3a AS (
         SELECT metric3a_value.oram_id,
            sum(metric3a_value.metric3a_value) AS metric3a_score
           FROM metric3a_value
          GROUP BY metric3a_value.oram_id
        ), metric3b AS (
         SELECT metric3b_value.oram_id,
            sum(metric3b_value.metric3b_value) AS metric3b_score
           FROM metric3b_value
          GROUP BY metric3b_value.oram_id
        ), metric3c AS (
         SELECT metric3c_value.oram_id,
            avg(metric3c_value.metric3c_value) AS metric3c_score
           FROM metric3c_value
          GROUP BY metric3c_value.oram_id
        ), metric3d AS (
         SELECT metric3d_value.oram_id,
            avg(metric3d_value.metric3d_value) AS metric3d_score
           FROM metric3d_value
          GROUP BY metric3d_value.oram_id
        ), metric3e AS (
         SELECT metric3e_value.oram_id,
            avg(metric3e_value.metric3e_value) AS metric3e_score
           FROM metric3e_value
          GROUP BY metric3e_value.oram_id
        ), metric4a AS (
         SELECT metric4a_value.oram_id,
            avg(metric4a_value.metric4a_value) AS metric4a_score
           FROM metric4a_value
          GROUP BY metric4a_value.oram_id
        ), metric4b AS (
         SELECT metric4b_value.oram_id,
            avg(metric4b_value.metric4b_value) AS metric4b_score
           FROM metric4b_value
          GROUP BY metric4b_value.oram_id
        ), metric4c AS (
         SELECT metric4c_value.oram_id,
            avg(metric4c_value.metric4c_value) AS metric4c_score
           FROM metric4c_value
          GROUP BY metric4c_value.oram_id
        ), metric5 AS (
         SELECT metric5_value.oram_id,
            avg(metric5_value.metric5_value) AS metric5_score
           FROM metric5_value
          GROUP BY metric5_value.oram_id
        ), metric6a1 AS (
         SELECT metric6a1_value.oram_id,
            avg(metric6a1_value.metric6a1_value) AS metric6a1_score
           FROM metric6a1_value
          GROUP BY metric6a1_value.oram_id
        ), metric6a2 AS (
         SELECT metric6a2_value.oram_id,
            avg(metric6a2_value.metric6a2_value) AS metric6a2_score
           FROM metric6a2_value
          GROUP BY metric6a2_value.oram_id
        ), metric6a3 AS (
         SELECT metric6a3_value.oram_id,
            avg(metric6a3_value.metric6a3_value) AS metric6a3_score
           FROM metric6a3_value
          GROUP BY metric6a3_value.oram_id
        ), metric6a4 AS (
         SELECT metric6a4_value.oram_id,
            avg(metric6a4_value.metric6a4_value) AS metric6a4_score
           FROM metric6a4_value
          GROUP BY metric6a4_value.oram_id
        ), metric6a5 AS (
         SELECT metric6a5_value.oram_id,
            avg(metric6a5_value.metric6a5_value) AS metric6a5_score
           FROM metric6a5_value
          GROUP BY metric6a5_value.oram_id
        ), metric6a6 AS (
         SELECT metric6a6_value.oram_id,
            avg(metric6a6_value.metric6a6_value) AS metric6a6_score
           FROM metric6a6_value
          GROUP BY metric6a6_value.oram_id
        ), metric6a7 AS (
         SELECT metric6a7_value.oram_id,
            avg(metric6a7_value.metric6a7_value) AS metric6a7_score
           FROM metric6a7_value
          GROUP BY metric6a7_value.oram_id
        ), metric6b AS (
         SELECT metric6b_value.oram_id,
            avg(metric6b_value.metric6b_value) AS metric6b_score
           FROM metric6b_value
          GROUP BY metric6b_value.oram_id
        ), metric6c AS (
         SELECT metric6c_value.oram_id,
            avg(metric6c_value.metric6c_value) AS metric6c_score
           FROM metric6c_value
          GROUP BY metric6c_value.oram_id
        ), metric6d1 AS (
         SELECT metric6d1_value.oram_id,
            avg(metric6d1_value.metric6d1_value) AS metric6d1_score
           FROM metric6d1_value
          GROUP BY metric6d1_value.oram_id
        ), metric6d2 AS (
         SELECT metric6d2_value.oram_id,
            avg(metric6d2_value.metric6d2_value) AS metric6d2_score
           FROM metric6d2_value
          GROUP BY metric6d2_value.oram_id
        ), metric6d3 AS (
         SELECT metric6d3_value.oram_id,
            avg(metric6d3_value.metric6d3_value) AS metric6d3_score
           FROM metric6d3_value
          GROUP BY metric6d3_value.oram_id
        ), metric6d4 AS (
         SELECT metric6d4_value.oram_id,
            avg(metric6d4_value.metric6d4_value) AS metric6d4_score
           FROM metric6d4_value
          GROUP BY metric6d4_value.oram_id
        )
 SELECT metric1.oram_id,
    metric1.metric1_score,
    metric2a.metric2a_score,
    metric2b.metric2b_score,
    metric3a.metric3a_score,
    metric3b.metric3b_score,
    metric3c.metric3c_score,
    metric3d.metric3d_score,
    metric3e.metric3e_score,
    metric4a.metric4a_score,
    metric4b.metric4b_score,
    metric4c.metric4c_score,
        CASE
            WHEN (metric5.metric5_score > (10)::numeric) THEN (10)::numeric
            ELSE metric5.metric5_score
        END AS metric5_score,
    metric6a1.metric6a1_score,
    metric6a2.metric6a2_score,
    metric6a3.metric6a3_score,
    metric6a4.metric6a4_score,
    metric6a5.metric6a5_score,
    metric6a6.metric6a6_score,
    metric6a7.metric6a7_score,
    metric6b.metric6b_score,
    metric6c.metric6c_score,
    metric6d1.metric6d1_score,
    metric6d2.metric6d2_score,
    metric6d3.metric6d3_score,
    metric6d4.metric6d4_score,
    ((((((((((((((((((((((((metric1.metric1_score + metric2a.metric2a_score) + metric2b.metric2b_score) + metric3a.metric3a_score) + COALESCE(metric3b.metric3b_score, (0)::numeric)) + metric3c.metric3c_score) + metric3d.metric3d_score) + metric3e.metric3e_score) + metric4a.metric4a_score) + metric4b.metric4b_score) + metric4c.metric4c_score) + COALESCE(metric5.metric5_score, (0)::numeric)) + COALESCE(metric6a1.metric6a1_score, (0)::numeric)) + COALESCE(metric6a2.metric6a2_score, (0)::numeric)) + COALESCE(metric6a3.metric6a3_score, (0)::numeric)) + COALESCE(metric6a4.metric6a4_score, (0)::numeric)) + COALESCE(metric6a5.metric6a5_score, (0)::numeric)) + COALESCE(metric6a6.metric6a6_score, (0)::numeric)) + COALESCE(metric6a7.metric6a7_score, (0)::numeric)) + metric6b.metric6b_score) + metric6c.metric6c_score) + COALESCE(metric6d1.metric6d1_score, (0)::numeric)) + COALESCE(metric6d2.metric6d2_score, (0)::numeric)) + COALESCE(metric6d3.metric6d3_score, (0)::numeric)) + COALESCE(metric6d4.metric6d4_score, (0)::numeric)) AS grand_total
   FROM ((((((((((((((((((((((((metric1
     LEFT JOIN metric2a ON ((metric1.oram_id = metric2a.oram_id)))
     LEFT JOIN metric2b ON ((metric1.oram_id = metric2b.oram_id)))
     LEFT JOIN metric3a ON ((metric1.oram_id = metric3a.oram_id)))
     LEFT JOIN metric3b ON ((metric1.oram_id = metric3b.oram_id)))
     LEFT JOIN metric3c ON ((metric1.oram_id = metric3c.oram_id)))
     LEFT JOIN metric3d ON ((metric1.oram_id = metric3d.oram_id)))
     LEFT JOIN metric3e ON ((metric1.oram_id = metric3e.oram_id)))
     LEFT JOIN metric4a ON ((metric1.oram_id = metric4a.oram_id)))
     LEFT JOIN metric4b ON ((metric1.oram_id = metric4b.oram_id)))
     LEFT JOIN metric4c ON ((metric1.oram_id = metric4c.oram_id)))
     LEFT JOIN metric5 ON ((metric1.oram_id = metric5.oram_id)))
     LEFT JOIN metric6a1 ON ((metric1.oram_id = metric6a1.oram_id)))
     LEFT JOIN metric6a2 ON ((metric1.oram_id = metric6a2.oram_id)))
     LEFT JOIN metric6a3 ON ((metric1.oram_id = metric6a3.oram_id)))
     LEFT JOIN metric6a4 ON ((metric1.oram_id = metric6a4.oram_id)))
     LEFT JOIN metric6a5 ON ((metric1.oram_id = metric6a5.oram_id)))
     LEFT JOIN metric6a6 ON ((metric1.oram_id = metric6a6.oram_id)))
     LEFT JOIN metric6a7 ON ((metric1.oram_id = metric6a7.oram_id)))
     LEFT JOIN metric6b ON ((metric1.oram_id = metric6b.oram_id)))
     LEFT JOIN metric6c ON ((metric1.oram_id = metric6c.oram_id)))
     LEFT JOIN metric6d1 ON ((metric1.oram_id = metric6d1.oram_id)))
     LEFT JOIN metric6d2 ON ((metric1.oram_id = metric6d2.oram_id)))
     LEFT JOIN metric6d3 ON ((metric1.oram_id = metric6d3.oram_id)))
     LEFT JOIN metric6d4 ON ((metric1.oram_id = metric6d4.oram_id)));
-- ddl-end --
ALTER VIEW wetland_census.cm_wetland_oram_calcs OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_oram_category | type: VIEW --
-- DROP VIEW IF EXISTS wetland_census.cm_wetland_oram_category CASCADE;
CREATE VIEW wetland_census.cm_wetland_oram_category
AS 

SELECT cm_wetland_oram_calcs.oram_id,
    cm_wetland_oram_calcs.grand_total,
        CASE
            WHEN (cm_wetland_oram_calcs.grand_total < 30.0) THEN '1'::text
            WHEN ((cm_wetland_oram_calcs.grand_total > 29.9) AND (cm_wetland_oram_calcs.grand_total < 50.0)) THEN '2a'::text
            WHEN ((cm_wetland_oram_calcs.grand_total > 49.9) AND (cm_wetland_oram_calcs.grand_total < 60.0)) THEN '2b'::text
            WHEN (cm_wetland_oram_calcs.grand_total > 59.9) THEN '3'::text
            ELSE NULL::text
        END AS category
   FROM cm_wetland_oram_calcs;
-- ddl-end --
ALTER VIEW wetland_census.cm_wetland_oram_category OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_plant_community_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_plant_community_norm CASCADE;
CREATE TABLE wetland_census.cm_wetland_plant_community_norm(
	classification_id bigint NOT NULL,
	plant_community text NOT NULL,
	CONSTRAINT cm_wetland_plant_community_norm_pkey PRIMARY KEY (plant_community,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_plant_community_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_water_flow_path | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_water_flow_path CASCADE;
CREATE TABLE wetland_census.cm_wetland_water_flow_path(
	classification_id bigint NOT NULL,
	water_flow_path text NOT NULL,
	CONSTRAINT cm_wetland_water_flow_path_pkey PRIMARY KEY (water_flow_path,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_water_flow_path OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_poly_id_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_poly_id_norm CASCADE;
CREATE TABLE wetland_census.oram_poly_id_norm(
	oram_id bigint NOT NULL,
	polygon_id text NOT NULL,
	CONSTRAINT oram_poly_id_norm_pkey PRIMARY KEY (oram_id,polygon_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_poly_id_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_reservation_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_reservation_norm CASCADE;
CREATE TABLE wetland_census.oram_reservation_norm(
	oram_id bigint NOT NULL,
	reservation text,
	CONSTRAINT oram_reservation_norm_pkey PRIMARY KEY (oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_reservation_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetlands_all_cm_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.cm_wetlands_all_cm_id_seq CASCADE;
CREATE SEQUENCE wetland_census.cm_wetlands_all_cm_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.cm_wetlands_all_cm_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_coordinates | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_coordinates CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_coordinates(
	classification_id bigint NOT NULL,
	latitude numeric NOT NULL,
	longitude numeric NOT NULL,
	CONSTRAINT cm_wetland_classification_coordinates_pkey PRIMARY KEY (latitude,longitude,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_coordinates OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_geometry | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_geometry CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_geometry(
	classification_id bigint NOT NULL,
	geometry geometry,
	CONSTRAINT cm_wetland_classification_geometry_pkey PRIMARY KEY (classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_geometry OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_notes | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_notes CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_notes(
	classification_id bigint NOT NULL,
	notes text,
	CONSTRAINT cm_wetland_classification_notes_pkey PRIMARY KEY (classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_notes OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_polygon_id | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_polygon_id CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_polygon_id(
	classification_id bigint NOT NULL,
	polygon_id text NOT NULL,
	CONSTRAINT cm_wetland_classification_polygon_id_pkey PRIMARY KEY (polygon_id,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_polygon_id OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_recorder | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_recorder CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_recorder(
	classification_id bigint NOT NULL,
	data_recorded_by_initials text NOT NULL
);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_recorder OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_reservation | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_reservation CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_reservation(
	classification_id bigint NOT NULL,
	reservation text NOT NULL,
	CONSTRAINT cm_wetland_classification_reservation_pkey PRIMARY KEY (reservation,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_reservation OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_to_fulcrum_form_classification_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.cm_wetland_classification_to_fulcrum_form_classification_id_seq CASCADE;
CREATE SEQUENCE wetland_census.cm_wetland_classification_to_fulcrum_form_classification_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.cm_wetland_classification_to_fulcrum_form_classification_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_classification_to_fulcrum_format | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_classification_to_fulcrum_format CASCADE;
CREATE TABLE wetland_census.cm_wetland_classification_to_fulcrum_format(
	fulcrum_id text,
	created_at timestamp,
	updated_at timestamp,
	created_by text,
	updated_by text,
	system_created_at timestamp,
	system_updated_at timestamp,
	version bigint,
	status text,
	project text,
	assigned_to text,
	latitude numeric,
	longitude numeric,
	eight_digit_huc text,
	twelve_digit_huc text,
	geometry geometry,
	polygon_id text,
	reservation text,
	data_recorded_by_initials text,
	classification_level text,
	plant_community text,
	plant_community_other text,
	landscape_position text,
	inland_landform text,
	water_flow_path text,
	llww_modifiers text,
	cowardin_classification text,
	cowardin_water_regime text,
	cowardin_special_modifier text,
	sp1 text,
	sp2 text,
	sp3 text,
	sp4 text,
	sp5 text,
	sp6 text,
	sp7 text,
	sp8 text,
	sp9 text,
	sp10 text,
	classification_id bigint NOT NULL DEFAULT nextval('wetland_census.cm_wetland_classification_to_fulcrum_form_classification_id_seq'::regclass),
	CONSTRAINT cm_wetland_classification_to_fulcrum_format_pkey PRIMARY KEY (classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_classification_to_fulcrum_format OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_cowardin_special_modifier_other | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_cowardin_special_modifier_other CASCADE;
CREATE TABLE wetland_census.cm_wetland_cowardin_special_modifier_other(
	classification_id bigint NOT NULL,
	cowardin_special_modifier_other text NOT NULL,
	CONSTRAINT cm_wetland_cowardin_special_modifier_other_pkey PRIMARY KEY (cowardin_special_modifier_other,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_cowardin_special_modifier_other OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_dominant_species | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_dominant_species CASCADE;
CREATE TABLE wetland_census.cm_wetland_dominant_species(
	classification_id bigint NOT NULL,
	plant_species text
);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_dominant_species OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_photos_caption_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_photos_caption_norm CASCADE;
CREATE TABLE wetland_census.cm_wetland_photos_caption_norm(
	classification_id bigint NOT NULL,
	photos_caption text NOT NULL,
	CONSTRAINT cm_wetland_photos_caption_norm_pkey PRIMARY KEY (photos_caption,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_photos_caption_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_photos_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_photos_norm CASCADE;
CREATE TABLE wetland_census.cm_wetland_photos_norm(
	classification_id bigint NOT NULL,
	photos text NOT NULL,
	CONSTRAINT cm_wetland_photos_norm_pkey PRIMARY KEY (photos,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_photos_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_photos_url_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_photos_url_norm CASCADE;
CREATE TABLE wetland_census.cm_wetland_photos_url_norm(
	classification_id bigint NOT NULL,
	photos_url text NOT NULL,
	CONSTRAINT cm_wetland_photos_url_norm_pkey PRIMARY KEY (photos_url,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_photos_url_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetland_plant_community_other | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetland_plant_community_other CASCADE;
CREATE TABLE wetland_census.cm_wetland_plant_community_other(
	classification_id bigint NOT NULL,
	plant_community_other text NOT NULL,
	CONSTRAINT cm_wetland_plant_community_other_pkey PRIMARY KEY (plant_community_other,classification_id)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetland_plant_community_other OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cuy_ssurgo_with_compnents | type: VIEW --
-- DROP VIEW IF EXISTS wetland_census.cuy_ssurgo_with_compnents CASCADE;
CREATE VIEW wetland_census.cuy_ssurgo_with_compnents
AS 

SELECT unit.musym,
    unit.muname,
    co.comppct_l,
    co.comppct_r,
    co.comppct_h,
    co.compname,
    co.compkind,
    co.majcompflag,
    co.otherph,
    co.localphase,
    co.slope_l,
    co.slope_r,
    co.slope_h,
    co.slopelenusle_l,
    co.slopelenusle_r,
    co.slopelenusle_h,
    co.runoff,
    co.tfact,
    co.wei,
    co.weg,
    co.erocl,
    co.earthcovkind1,
    co.earthcovkind2,
    co.hydricon,
    co.hydricrating,
    co.drainagecl,
    co.elev_l,
    co.elev_r,
    co.elev_h,
    co.aspectccwise,
    co.aspectrep,
    co.aspectcwise,
    co.geomdesc,
    co.albedodry_l,
    co.albedodry_r,
    co.albedodry_h,
    co.airtempa_l,
    co.airtempa_r,
    co.airtempa_h,
    co.map_l,
    co.map_r,
    co.map_h,
    co.reannualprecip_l,
    co.reannualprecip_r,
    co.reannualprecip_h,
    co.ffd_l,
    co.ffd_r,
    co.ffd_h,
    co.nirrcapcl,
    co.nirrcapscl,
    co.nirrcapunit,
    co.irrcapcl,
    co.irrcapscl,
    co.irrcapunit,
    co.cropprodindex,
    co.constreeshrubgrp,
    co.wndbrksuitgrp,
    co.rsprod_l,
    co.rsprod_r,
    co.rsprod_h,
    co.foragesuitgrpid,
    co.wlgrain,
    co.wlgrass,
    co.wlherbaceous,
    co.wlshrub,
    co.wlconiferous,
    co.wlhardwood,
    co.wlwetplant,
    co.wlshallowwat,
    co.wlrangeland,
    co.wlopenland,
    co.wlwoodland,
    co.wlwetland,
    co.soilslippot,
    co.frostact,
    co.initsub_l,
    co.initsub_r,
    co.initsub_h,
    co.totalsub_l,
    co.totalsub_r,
    co.totalsub_h,
    co.hydgrp,
    co.corcon,
    co.corsteel,
    co.taxclname,
    co.taxorder,
    co.taxsuborder,
    co.taxgrtgroup,
    co.taxsubgrp,
    co.taxpartsize,
    co.taxpartsizemod,
    co.taxceactcl,
    co.taxreaction,
    co.taxtempcl,
    co.taxmoistscl,
    co.taxtempregime,
    co.soiltaxedition,
    co.castorieindex,
    co.flecolcomnum,
    co.flhe,
    co.flphe,
    co.flsoilleachpot,
    co.flsoirunoffpot,
    co.fltemik2use,
    co.fltriumph2use,
    co.indraingrp,
    co.innitrateleachi,
    co.misoimgmtgrp,
    co.vasoimgtgrp,
    co.mukey,
    co.cokey
   FROM (nr_misc.mapunit unit
     LEFT JOIN nr_misc.component co ON (((unit.mukey)::text = (co.mukey)::text)));
-- ddl-end --
ALTER VIEW wetland_census.cuy_ssurgo_with_compnents OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hydro_disturbances_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.hydro_disturbances_norm CASCADE;
CREATE TABLE wetland_census.hydro_disturbances_norm(
	oram_id bigint NOT NULL,
	disturbances_hydro text NOT NULL,
	CONSTRAINT hydro_disturbances_norm_pkey PRIMARY KEY (oram_id,disturbances_hydro)

);
-- ddl-end --
ALTER TABLE wetland_census.hydro_disturbances_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hydro_test | type: VIEW --
-- DROP VIEW IF EXISTS wetland_census.hydro_test CASCADE;
CREATE VIEW wetland_census.hydro_test
AS 

SELECT water_level_data."timestamp",
    water_level_data.level_cm,
    water_level_data.serial
   FROM nr_misc.water_level_data
  WHERE (((water_level_data.serial)::text = '00001130D339'::text) AND ((water_level_data."timestamp" >= '2009-11-24 16:00:00'::timestamp without time zone) AND (water_level_data."timestamp" <= '2009-12-24 16:00:00'::timestamp without time zone)));
-- ddl-end --
ALTER VIEW wetland_census.hydro_test OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric1_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric1_norm CASCADE;
CREATE TABLE wetland_census.metric1_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric1_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric1_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric2a_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric2a_norm CASCADE;
CREATE TABLE wetland_census.metric2a_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric2a_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric2a_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric2b_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric2b_norm CASCADE;
CREATE TABLE wetland_census.metric2b_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric2b_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric2b_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3a_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3a_norm CASCADE;
CREATE TABLE wetland_census.metric3a_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric3a_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3a_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3b_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3b_norm CASCADE;
CREATE TABLE wetland_census.metric3b_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric3b_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3b_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3c_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3c_norm CASCADE;
CREATE TABLE wetland_census.metric3c_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric3c_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3c_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3d_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3d_norm CASCADE;
CREATE TABLE wetland_census.metric3d_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric3d_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3d_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric3e_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric3e_norm CASCADE;
CREATE TABLE wetland_census.metric3e_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric3e_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric3e_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric4a_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric4a_norm CASCADE;
CREATE TABLE wetland_census.metric4a_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric4a_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric4a_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric4b_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric4b_norm CASCADE;
CREATE TABLE wetland_census.metric4b_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric4b_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric4b_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric4c_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric4c_norm CASCADE;
CREATE TABLE wetland_census.metric4c_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric4c_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric4c_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric5_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric5_norm CASCADE;
CREATE TABLE wetland_census.metric5_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric5_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric5_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a1_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a1_norm CASCADE;
CREATE TABLE wetland_census.metric6a1_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a1_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a1_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a2_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a2_norm CASCADE;
CREATE TABLE wetland_census.metric6a2_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a2_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a2_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a3_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a3_norm CASCADE;
CREATE TABLE wetland_census.metric6a3_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a3_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a3_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a4_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a4_norm CASCADE;
CREATE TABLE wetland_census.metric6a4_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a4_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a4_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a5_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a5_norm CASCADE;
CREATE TABLE wetland_census.metric6a5_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a5_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a5_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a6_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a6_norm CASCADE;
CREATE TABLE wetland_census.metric6a6_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a6_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a6_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6a7_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6a7_norm CASCADE;
CREATE TABLE wetland_census.metric6a7_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6a7_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6a7_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6b_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6b_norm CASCADE;
CREATE TABLE wetland_census.metric6b_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6b_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6b_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6c_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6c_norm CASCADE;
CREATE TABLE wetland_census.metric6c_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6c_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6c_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d1_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d1_norm CASCADE;
CREATE TABLE wetland_census.metric6d1_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6d1_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d1_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d2_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d2_norm CASCADE;
CREATE TABLE wetland_census.metric6d2_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6d2_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d2_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d3_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d3_norm CASCADE;
CREATE TABLE wetland_census.metric6d3_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6d3_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d3_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.metric6d4_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.metric6d4_norm CASCADE;
CREATE TABLE wetland_census.metric6d4_norm(
	oram_id bigint NOT NULL,
	selection text NOT NULL,
	CONSTRAINT metric6d4_norm_pkey PRIMARY KEY (oram_id,selection)

);
-- ddl-end --
ALTER TABLE wetland_census.metric6d4_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_id | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_id CASCADE;
CREATE TABLE wetland_census.oram_id(
	oram_id bigint NOT NULL,
	fulcrum_id character varying(100),
	CONSTRAINT oram_id_pkey PRIMARY KEY (oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_id OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_notes | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_notes CASCADE;
CREATE TABLE wetland_census.oram_notes(
	oram_id bigint NOT NULL,
	notes text,
	CONSTRAINT oram_notes_pkey PRIMARY KEY (oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_notes OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_photos_caption_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_photos_caption_norm CASCADE;
CREATE TABLE wetland_census.oram_photos_caption_norm(
	oram_id bigint NOT NULL,
	photos_caption text NOT NULL,
	CONSTRAINT oram_photos_caption_norm_pkey PRIMARY KEY (photos_caption,oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_photos_caption_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_photos_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_photos_norm CASCADE;
CREATE TABLE wetland_census.oram_photos_norm(
	oram_id bigint NOT NULL,
	photos text NOT NULL,
	CONSTRAINT oram_photos_norm_pkey PRIMARY KEY (photos,oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_photos_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_photos_url_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_photos_url_norm CASCADE;
CREATE TABLE wetland_census.oram_photos_url_norm(
	oram_id bigint NOT NULL,
	photos_url text NOT NULL,
	CONSTRAINT oram_photos_url_norm_pkey PRIMARY KEY (photos_url,oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_photos_url_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_recorder_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_recorder_norm CASCADE;
CREATE TABLE wetland_census.oram_recorder_norm(
	oram_id bigint NOT NULL,
	data_recorded_by_initials text NOT NULL,
	CONSTRAINT oram_recorder_norm_pkey PRIMARY KEY (oram_id,data_recorded_by_initials)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_recorder_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_score_lookup_all_lookup_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.oram_score_lookup_all_lookup_id_seq CASCADE;
CREATE SEQUENCE wetland_census.oram_score_lookup_all_lookup_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.oram_score_lookup_all_lookup_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_score_lookup_all | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_score_lookup_all CASCADE;
CREATE TABLE wetland_census.oram_score_lookup_all(
	metric text NOT NULL,
	selection text NOT NULL,
	value numeric NOT NULL,
	lookup_id integer NOT NULL DEFAULT nextval('wetland_census.oram_score_lookup_all_lookup_id_seq'::regclass),
	CONSTRAINT oram_score_lookup_all_pkey PRIMARY KEY (value,lookup_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_score_lookup_all OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_v2 | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_v2 CASCADE;
CREATE TABLE wetland_census.oram_v2(
	fulcrum_id character varying(100),
	created_at timestamp,
	updated_at timestamp,
	created_by text,
	updated_by text,
	system_created_at timestamp,
	system_updated_at timestamp,
	version bigint,
	status text,
	project text,
	assigned_to text,
	latitude double precision,
	longitude double precision,
	geometry geometry,
	reservation text,
	polygon_id text,
	date text,
	data_recorded_by_initials text,
	m1_wetland_area text,
	m2a_upland_buffer_width text,
	m2b_surrounding_land_use text,
	m3a_sources_of_water text,
	m3b_connectivity text,
	m3c_maximum_water_depth text,
	m3d_duration_inundation_saturation text,
	m3e_modifications_to_hydrologic_regime text,
	disturbances_hydro text,
	m4a_substrate_disturbance text,
	m4b_habitat_development text,
	m4c_habitat_alteration text,
	disturbances_substrate text,
	disturbances_substrate_other text,
	m6a_aquatic_bed text,
	m6a_emergent text,
	m6a_shrub text,
	m6a_forest text,
	m6a_mudflats text,
	m6a_open_water text,
	m6a_other text,
	m6a_other_list text,
	m6b_horizontal_plan_view_interspersion text,
	m6c_coverage_of_invasive_plants text,
	m6d_microtopography_vegetation_hummuckstussuck text,
	m6d_microtopography_course_woody_debris_15cm_6in text,
	m6d_microtopography_standing_dead_25cm_10in_dbh text,
	m6d_microtopography_amphibian_breeding_pools text,
	m5_special_wetlands text,
	notes text,
	photos text,
	photos_caption text,
	photos_url text
);
-- ddl-end --
ALTER TABLE wetland_census.oram_v2 OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_v2_photos | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_v2_photos CASCADE;
CREATE TABLE wetland_census.oram_v2_photos(
	fulcrum_id text,
	fulcrum_parent_id text,
	fulcrum_record_id text,
	version bigint,
	caption text,
	latitude double precision,
	longitude double precision,
	geometry geometry,
	file_size bigint,
	uploaded_at timestamp,
	exif_date_time text,
	exif_gps_altitude text,
	exif_gps_date_stamp text,
	exif_gps_time_stamp text,
	exif_gps_dop text,
	exif_gps_img_direction text,
	exif_gps_img_direction_ref text,
	exif_gps_latitude text,
	exif_gps_latitude_ref text,
	exif_gps_longitude text,
	exif_gps_longitude_ref text,
	exif_make text,
	exif_model text,
	exif_orientation text,
	exif_pixel_x_dimension text,
	exif_pixel_y_dimension text,
	exif_software text,
	exif_x_resolution text,
	exif_y_resolution text
);
-- ddl-end --
ALTER TABLE wetland_census.oram_v2_photos OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.seq_test | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.seq_test CASCADE;
CREATE SEQUENCE wetland_census.seq_test
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.seq_test OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.substrate_disturbances_norm | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.substrate_disturbances_norm CASCADE;
CREATE TABLE wetland_census.substrate_disturbances_norm(
	oram_id bigint NOT NULL,
	disturbances_substrate text NOT NULL,
	CONSTRAINT substrate_disturbances_norm_pkey PRIMARY KEY (oram_id,disturbances_substrate)

);
-- ddl-end --
ALTER TABLE wetland_census.substrate_disturbances_norm OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_classification | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.wetland_classification CASCADE;
CREATE TABLE wetland_census.wetland_classification(
	fulcrum_id character varying(100) NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	created_by text,
	updated_by text,
	system_created_at timestamp,
	system_updated_at timestamp,
	version bigint,
	status text,
	project text,
	assigned_to text,
	latitude double precision,
	longitude double precision,
	geometry geometry,
	reservation text,
	polygon_id text,
	data_recorded_by_initials text,
	classification_level text,
	landscape_position text,
	inland_landform text,
	water_flow_path text,
	llww_modifiers text,
	cowardin_classification text,
	cowardin_water_regime text,
	cowardin_special_modifier text,
	cowardin_special_modifier_other text,
	plant_community text,
	plant_community_other text,
	sp1 text,
	sp2 text,
	sp3 text,
	sp4 text,
	sp5 text,
	sp6 text,
	sp7 text,
	sp8 text,
	sp9 text,
	sp10 text,
	notes text,
	photos text,
	photos_caption text,
	photos_url text,
	CONSTRAINT wetland_classification_pkey PRIMARY KEY (fulcrum_id)

);
-- ddl-end --
ALTER TABLE wetland_census.wetland_classification OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_classification_data_serial_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.wetland_classification_data_serial_id_seq CASCADE;
CREATE SEQUENCE wetland_census.wetland_classification_data_serial_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.wetland_classification_data_serial_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_classification_pre_fulcrum | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.wetland_classification_pre_fulcrum CASCADE;
CREATE TABLE wetland_census.wetland_classification_pre_fulcrum(
	project_label character varying(80),
	investigators character varying(80),
	start_date date,
	end_date date,
	photos character varying(80),
	unique_id character varying(20) NOT NULL,
	state character varying(80),
	county character varying(80),
	reserv character varying(20) NOT NULL,
	eight_digit_huc character varying(80),
	twelve_digit_huc character varying(80),
	p_class character varying(80),
	p_subclass character varying(80),
	p_comp character varying(80),
	s_class character varying(80),
	s_subclass character varying(80),
	s_comp character varying(80),
	o1_class character varying(80),
	o1_subclass character varying(80),
	o1_comp character varying(80),
	o2_class character varying(80),
	o2_subclass character varying(80),
	o2_comp character varying(80),
	o3_class character varying(80),
	o3_subclass character varying(80),
	o3_comp character varying(80),
	o4_class character varying(80),
	o4_subclass character varying(80),
	o4_comp character varying(80),
	o5_class character varying(80),
	o5_subclass character varying(80),
	o5_comp character varying(80),
	o6_class character varying(80),
	o6_subclass character varying(80),
	o6_comp character varying(80),
	p_landscape character varying(80),
	p_gradient_type character varying(80),
	p_ls_mod character varying(80),
	p_landform character varying(80),
	p_lf_mod character varying(80),
	p_waterflow character varying(80),
	p_wf_mod character varying(80),
	p_other_mod1 character varying(80),
	p_other_mod2 character varying(80),
	p_other_mod3 character varying(80),
	s_landscape character varying(80),
	s_gradient_type character varying(80),
	s_ls_mod character varying(80),
	s_landform character varying(80),
	s_lf_mod character varying(80),
	s_waterflow character varying(80),
	s_wf_mod character varying(80),
	s_other_mod1 character varying(80),
	s_other_mod2 character varying(80),
	s_other_mod3 character varying(80),
	o1_landscape character varying(80),
	o1_gradient_type character varying(80),
	o1_ls_mod character varying(80),
	o1_landform character varying(80),
	o1_lf_mod character varying(80),
	o1_waterflow character varying(80),
	o1_wf_mod character varying(80),
	o1_other_mod1 character varying(80),
	o1_other_mod2 character varying(80),
	o1_other_mod3 character varying(80),
	o2_landscape character varying(80),
	o2_gradient_type character varying(80),
	o2_ls_mod character varying(80),
	o2_landform character varying(80),
	o2_lf_mod character varying(80),
	o2_waterflow character varying(80),
	o2_wf_mod character varying(80),
	o2_other_mod1 character varying(80),
	o2_other_mod2 character varying(80),
	o2_other_mod3 character varying(80),
	p_cow_system character varying(80),
	p_cow_class character varying(80),
	p_cow_water character varying(80),
	p_cow_special character varying(80),
	s_cow_system character varying(80),
	s_cow_class character varying(80),
	s_cow_water character varying(80),
	s_cow_special character varying(80),
	o1_cow_system character varying(80),
	o1_cow_class character varying(80),
	o1_cow_water character varying(80),
	o1_cow_special character varying(80),
	o2_cow_system character varying(80),
	o2_cow_class character varying(80),
	o2_cow_water character varying(80),
	o2_cow_special character varying(80),
	o3_cow_system character varying(80),
	o3_cow_class character varying(80),
	o3_cow_water character varying(80),
	o3_cow_special character varying(80),
	o4_cow_system character varying(80),
	o4_cow_class character varying(80),
	o4_cow_water character varying(80),
	o4_cow_special character varying(80),
	serial_id bigint NOT NULL DEFAULT nextval('wetland_census.wetland_classification_data_serial_id_seq'::regclass),
	CONSTRAINT class_pkey PRIMARY KEY (unique_id,reserv)

);
-- ddl-end --
ALTER TABLE wetland_census.wetland_classification_pre_fulcrum OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_classification_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.wetland_classification_id_seq CASCADE;
CREATE SEQUENCE wetland_census.wetland_classification_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 2705
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.wetland_classification_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_classification_photos | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.wetland_classification_photos CASCADE;
CREATE TABLE wetland_census.wetland_classification_photos(
	fulcrum_id text,
	fulcrum_parent_id text,
	fulcrum_record_id text,
	version bigint,
	caption text,
	latitude double precision,
	longitude double precision,
	geometry geometry,
	file_size bigint,
	uploaded_at timestamp,
	exif_date_time text,
	exif_gps_altitude text,
	exif_gps_date_stamp text,
	exif_gps_time_stamp text,
	exif_gps_dop text,
	exif_gps_img_direction text,
	exif_gps_img_direction_ref text,
	exif_gps_latitude text,
	exif_gps_latitude_ref text,
	exif_gps_longitude text,
	exif_gps_longitude_ref text,
	exif_make text,
	exif_model text,
	exif_orientation text,
	exif_pixel_x_dimension text,
	exif_pixel_y_dimension text,
	exif_software text,
	exif_x_resolution text,
	exif_y_resolution text
);
-- ddl-end --
ALTER TABLE wetland_census.wetland_classification_photos OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_oram_data_serial_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.wetland_oram_data_serial_id_seq CASCADE;
CREATE SEQUENCE wetland_census.wetland_oram_data_serial_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.wetland_oram_data_serial_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_oram_data_pre_fulcrum | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.wetland_oram_data_pre_fulcrum CASCADE;
CREATE TABLE wetland_census.wetland_oram_data_pre_fulcrum(
	reserv character varying(80) NOT NULL,
	unique_id character varying(80) NOT NULL,
	oram_id text NOT NULL,
	date date,
	recorder character varying(80),
	m1_less_01 character varying(80),
	m1_01_to_03 character varying(80),
	m1_03_to_3 character varying(80),
	m1_3_to_10 character varying(80),
	m1_10_to_25 character varying(80),
	m1_25_to_50 character varying(80),
	m1_greater_50 character varying(80),
	m1_score numeric,
	m2a_wide character varying(80),
	m2a_medium character varying(80),
	m2a_narrow character varying(80),
	m2a_very_narrow character varying(80),
	m2a_score numeric,
	m2b_very_low character varying(80),
	m2b_low character varying(80),
	m2b_mod_high character varying(80),
	m2b_high character varying(80),
	m2b_score numeric,
	m3a_high_ph_gw character varying(80),
	m3a_other_gw character varying(80),
	m3a_precip character varying(80),
	m3a_sisw character varying(80),
	m3a_psw character varying(80),
	m3a_score numeric,
	m3b_hndrd_yr_fp character varying(80),
	m3b_bt_water_human character varying(80),
	m3b_wl_up_complex character varying(80),
	m3b_riparian character varying(80),
	m3b_score numeric,
	m3c_greater_07m character varying(80),
	m3c_04_to_07m character varying(80),
	m3c_less_04m character varying(80),
	m3c_score numeric,
	m3d_perm_i_s character varying(80),
	m3d_reg_i_s character varying(80),
	m3d_season_i character varying(80),
	m3d_season_s character varying(80),
	m3d_score numeric,
	m3e_none character varying(80),
	m3e_recovered character varying(80),
	m3e_recovering character varying(80),
	m3e_no_recovery character varying(80),
	m3e_score numeric,
	m3_ditch character varying(80),
	m3_dike character varying(80),
	m3_sw character varying(80),
	m3_fill_grade character varying(80),
	m3_dredging character varying(80),
	m3_tile character varying(80),
	m3_weir character varying(80),
	m3_point_source character varying(80),
	m3_roadbed character varying(80),
	m3_other character varying(80),
	m4_mowing character varying(80),
	m4_grazing character varying(80),
	m4_clearcut character varying(80),
	m4_sel_cut character varying(80),
	m4_cwd_remove character varying(80),
	m4_sedimentation character varying(80),
	m4_tox_poll character varying(80),
	m4_shrub_remove character varying(80),
	m4_ab_remove character varying(80),
	m4_farming character varying(80),
	m4_nutrients character varying(80),
	m4_dredging character varying(80),
	m4_other character varying(80),
	m4a_none character varying(80),
	m4a_recovered character varying(80),
	m4a_recovering character varying(80),
	m4a_no_recovery character varying(80),
	m4a_score numeric,
	m4b_excellent character varying(80),
	m4b_very_good character varying(80),
	m4b_good character varying(80),
	m4b_mod_good character varying(80),
	m4b_fair character varying(80),
	m4b_poor_fair character varying(80),
	m4b_poor character varying(80),
	m4b_score numeric,
	m4c_none character varying(80),
	m4c_recovered character varying(80),
	m4c_recovering character varying(80),
	m4c_no_recovery character varying(80),
	m4c_score numeric,
	m6a_ab numeric,
	m6a_emergent numeric,
	m6a_shrub numeric,
	m6a_forest numeric,
	m6a_mudflat numeric,
	m6a_open_water numeric,
	m6a_other numeric,
	m6a_score numeric,
	m6b_high character varying(80),
	m6b_mod_high character varying(80),
	m6b_moderate character varying(80),
	m6b_mod_low character varying(80),
	m6b_low character varying(80),
	m6b_none character varying(80),
	m6b_score numeric,
	m6c_extensive character varying(80),
	m6c_moderate character varying(80),
	m6c_sparse character varying(80),
	m6c_n_absent character varying(80),
	m6c_absent character varying(80),
	m6c_score numeric,
	m6d_humm_tuss numeric,
	m6d_cwd numeric,
	m6d_stand_dead numeric,
	m6d_breed_pools numeric,
	m6d_score numeric,
	m5_bog character varying(80),
	m5_fen character varying(80),
	m5_old_growth character varying(80),
	m5_mature_forest character varying(80),
	m5_lp_sandprairie character varying(80),
	m5_rel_wet_prairie character varying(80),
	m5_unrest_coastal character varying(80),
	m5_rest_coastal character varying(80),
	m5_tore_species character varying(80),
	m5_bird_useage character varying(80),
	m5_category1 character varying(80),
	m5_score numeric,
	grand_total numeric,
	oram_cat character varying(20),
	serial_id bigint NOT NULL DEFAULT nextval('wetland_census.wetland_oram_data_serial_id_seq'::regclass),
	CONSTRAINT oram_pkey PRIMARY KEY (reserv,unique_id,oram_id)

);
-- ddl-end --
ALTER TABLE wetland_census.wetland_oram_data_pre_fulcrum OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wetland_oram_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.wetland_oram_id_seq CASCADE;
CREATE SEQUENCE wetland_census.wetland_oram_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1909
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.wetland_oram_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bcr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bcr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.bcr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bcr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bcr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bcr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.bcr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bcr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.cm_wetlands_all | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.cm_wetlands_all CASCADE;
CREATE TABLE wetland_census.cm_wetlands_all(
	unique_id text NOT NULL,
	reserv text NOT NULL,
	geom geometry,
	area_acres numeric,
	poly_type character varying(20),
	cm_id bigint NOT NULL DEFAULT nextval('wetland_census.cm_wetlands_all_cm_id_seq'::regclass),
	CONSTRAINT wetlands_all_pkey PRIMARY KEY (unique_id,reserv)

);
-- ddl-end --
ALTER TABLE wetland_census.cm_wetlands_all OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bcr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.bcr_wetlands_final CASCADE;
CREATE TABLE wetland_census.bcr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('bcr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	hgm_class character varying(20),
	veg_class character varying(20),
	gid integer DEFAULT nextval('wetland_census.bcr_wetlands_final_gid_seq'::regclass),
	CONSTRAINT bcr_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.bcr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bed_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bed_id_seq CASCADE;
CREATE SEQUENCE wetland_census.bed_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bed_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bed_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bed_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.bed_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bed_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bed_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.bed_wetlands_final CASCADE;
CREATE TABLE wetland_census.bed_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('bed_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.bed_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT bed_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.bed_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bre_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bre_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.bre_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bre_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bre_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.bre_wetlands_final CASCADE;
CREATE TABLE wetland_census.bre_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('bre_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	geom geometry,
	gid integer NOT NULL DEFAULT nextval('wetland_census.bre_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT bre_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.bre_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bwr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bwr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.bwr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bwr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bwr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.bwr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.bwr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.bwr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bwr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.bwr_wetlands_final CASCADE;
CREATE TABLE wetland_census.bwr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('bwr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.bwr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT bwr_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.bwr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ecr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.ecr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.ecr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.ecr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ecr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.ecr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.ecr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.ecr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ecr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.ecr_wetlands_final CASCADE;
CREATE TABLE wetland_census.ecr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('ecr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.ecr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT ecr_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.ecr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hin_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.hin_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.hin_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.hin_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hin_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.hin_wetlands_final CASCADE;
CREATE TABLE wetland_census.hin_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('hin_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	geom geometry,
	gid integer NOT NULL DEFAULT nextval('wetland_census.hin_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT hin_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.hin_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hun_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.hun_id_seq CASCADE;
CREATE SEQUENCE wetland_census.hun_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.hun_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hun_wetland_polygons_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.hun_wetland_polygons_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.hun_wetland_polygons_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.hun_wetland_polygons_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hun_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.hun_wetlands_final CASCADE;
CREATE TABLE wetland_census.hun_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('hun_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	geom geometry,
	gid integer NOT NULL,
	CONSTRAINT hun_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.hun_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.msr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.msr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.msr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.msr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.msr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.msr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.msr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.msr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.msr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.msr_wetlands_final CASCADE;
CREATE TABLE wetland_census.msr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('msr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	geom geometry,
	gid integer NOT NULL DEFAULT nextval('wetland_census.msr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(80),
	veg_class character varying(80),
	CONSTRAINT msr_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.msr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ncr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.ncr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.ncr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.ncr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ncr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.ncr_wetlands_final CASCADE;
CREATE TABLE wetland_census.ncr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('ncr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.ncr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT ncr_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.ncr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.rrr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.rrr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.rrr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.rrr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.rrr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.rrr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.rrr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.rrr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.rrr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.rrr_wetlands_final CASCADE;
CREATE TABLE wetland_census.rrr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('rrr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.rrr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT rrr_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.rrr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.scr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.scr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.scr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.scr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.scr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.scr_wetlands_final CASCADE;
CREATE TABLE wetland_census.scr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('scr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	geom geometry,
	gid integer NOT NULL DEFAULT nextval('wetland_census.scr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT scr_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.scr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wcr_wetland_polygons_final_merged_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.wcr_wetland_polygons_final_merged_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.wcr_wetland_polygons_final_merged_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.wcr_wetland_polygons_final_merged_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wcr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.wcr_wetlands_final CASCADE;
CREATE TABLE wetland_census.wcr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('public.seq_test'::regclass), '000'::text),
	reserv text NOT NULL,
	geom geometry,
	gid integer NOT NULL,
	CONSTRAINT wcr_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.wcr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: bre_wetlands_final_geom_gist | type: INDEX --
-- DROP INDEX IF EXISTS wetland_census.bre_wetlands_final_geom_gist CASCADE;
CREATE INDEX bre_wetlands_final_geom_gist ON wetland_census.bre_wetlands_final
	USING gist
	(
	  geom
	)	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: hin_wetlands_final_geom_gist | type: INDEX --
-- DROP INDEX IF EXISTS wetland_census.hin_wetlands_final_geom_gist CASCADE;
CREATE INDEX hin_wetlands_final_geom_gist ON wetland_census.hin_wetlands_final
	USING gist
	(
	  geom
	)	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: hun_wetland_polygons_geom_gist | type: INDEX --
-- DROP INDEX IF EXISTS wetland_census.hun_wetland_polygons_geom_gist CASCADE;
CREATE INDEX hun_wetland_polygons_geom_gist ON wetland_census.hun_wetlands_final
	USING gist
	(
	  geom
	)	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: msr_wetlands_final_geom_gist | type: INDEX --
-- DROP INDEX IF EXISTS wetland_census.msr_wetlands_final_geom_gist CASCADE;
CREATE INDEX msr_wetlands_final_geom_gist ON wetland_census.msr_wetlands_final
	USING gist
	(
	  geom
	)	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: scr_wetlands_final_geom_gist | type: INDEX --
-- DROP INDEX IF EXISTS wetland_census.scr_wetlands_final_geom_gist CASCADE;
CREATE INDEX scr_wetlands_final_geom_gist ON wetland_census.scr_wetlands_final
	USING gist
	(
	  geom
	)	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: wcr_wetland_polygons_final_merged_geom_gist | type: INDEX --
-- DROP INDEX IF EXISTS wetland_census.wcr_wetland_polygons_final_merged_geom_gist CASCADE;
CREATE INDEX wcr_wetland_polygons_final_merged_geom_gist ON wetland_census.wcr_wetlands_final
	USING gist
	(
	  geom
	)	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: classification_coordinates_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_coordinates_log_trigger ON wetland_census.cm_wetland_classification_coordinates CASCADE;
CREATE TRIGGER classification_coordinates_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_coordinates
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_cowardin_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_cowardin_log_trigger ON wetland_census.cm_wetland_cowardin_classification CASCADE;
CREATE TRIGGER classification_cowardin_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_cowardin_classification
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_cowardin_special_mod_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_cowardin_special_mod_log_trigger ON wetland_census.cm_wetland_cowardin_special_modifier CASCADE;
CREATE TRIGGER classification_cowardin_special_mod_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_cowardin_special_modifier
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_cowardin_special_mod_other_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_cowardin_special_mod_other_trigger ON wetland_census.cm_wetland_cowardin_special_modifier_other CASCADE;
CREATE TRIGGER classification_cowardin_special_mod_other_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_cowardin_special_modifier_other
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_cowardin_water_regime_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_cowardin_water_regime_trigger ON wetland_census.cm_wetland_cowardin_water_regime CASCADE;
CREATE TRIGGER classification_cowardin_water_regime_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_cowardin_water_regime
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_dominant_species_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_dominant_species_log_trigger ON wetland_census.cm_wetland_dominant_species CASCADE;
CREATE TRIGGER classification_dominant_species_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_dominant_species
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_geometry_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_geometry_log_trigger ON wetland_census.cm_wetland_classification_geometry CASCADE;
CREATE TRIGGER classification_geometry_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_geometry
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_id_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_id_log_trigger ON wetland_census.cm_wetland_classification_id CASCADE;
CREATE TRIGGER classification_id_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_id
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_inland_landform_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_inland_landform_log_trigger ON wetland_census.cm_wetland_inland_landform_norm CASCADE;
CREATE TRIGGER classification_inland_landform_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_inland_landform_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_landscape_position_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_landscape_position_log_trigger ON wetland_census.cm_wetland_landscape_position_norm CASCADE;
CREATE TRIGGER classification_landscape_position_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_landscape_position_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_llww_modifiers_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_llww_modifiers_log_trigger ON wetland_census.cm_wetland_llww_modifiers CASCADE;
CREATE TRIGGER classification_llww_modifiers_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_llww_modifiers
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_notes_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_notes_log_trigger ON wetland_census.cm_wetland_classification_notes CASCADE;
CREATE TRIGGER classification_notes_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_notes
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_photos_caption_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_photos_caption_log_trigger ON wetland_census.cm_wetland_photos_caption_norm CASCADE;
CREATE TRIGGER classification_photos_caption_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_photos_caption_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_photos_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_photos_log_trigger ON wetland_census.cm_wetland_photos_norm CASCADE;
CREATE TRIGGER classification_photos_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_photos_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_photos_url_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_photos_url_log_trigger ON wetland_census.cm_wetland_photos_url_norm CASCADE;
CREATE TRIGGER classification_photos_url_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_photos_url_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_plant_community_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_plant_community_log_trigger ON wetland_census.cm_wetland_plant_community_norm CASCADE;
CREATE TRIGGER classification_plant_community_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_plant_community_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_plant_community_other_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_plant_community_other_log_trigger ON wetland_census.cm_wetland_plant_community_other CASCADE;
CREATE TRIGGER classification_plant_community_other_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_plant_community_other
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_polygon_id_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_polygon_id_log_trigger ON wetland_census.cm_wetland_classification_polygon_id CASCADE;
CREATE TRIGGER classification_polygon_id_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_polygon_id
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_recorder_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_recorder_log_trigger ON wetland_census.cm_wetland_classification_recorder CASCADE;
CREATE TRIGGER classification_recorder_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_recorder
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_reservation_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_reservation_log_trigger ON wetland_census.cm_wetland_classification_reservation CASCADE;
CREATE TRIGGER classification_reservation_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_classification_reservation
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: classification_water_flow_path_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS classification_water_flow_path_log_trigger ON wetland_census.cm_wetland_water_flow_path CASCADE;
CREATE TRIGGER classification_water_flow_path_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.cm_wetland_water_flow_path
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: cm_wetland_classification_insert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS cm_wetland_classification_insert_trigger ON wetland_census.wetland_classification CASCADE;
CREATE TRIGGER cm_wetland_classification_insert_trigger
	AFTER INSERT 
	ON wetland_census.wetland_classification
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.cm_wetland_classification_insert();
-- ddl-end --

-- object: metric1_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric1_norm_log_trigger ON wetland_census.metric1_norm CASCADE;
CREATE TRIGGER metric1_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric1_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric1_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric1_value_trigger ON wetland_census.metric1_norm CASCADE;
CREATE TRIGGER metric1_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric1_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric1_value();
-- ddl-end --

-- object: metric2a_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric2a_norm_log_trigger ON wetland_census.metric2a_norm CASCADE;
CREATE TRIGGER metric2a_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric2a_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric2a_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric2a_value_trigger ON wetland_census.metric2a_norm CASCADE;
CREATE TRIGGER metric2a_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric2a_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric2a_value();
-- ddl-end --

-- object: metric2b_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric2b_norm_log_trigger ON wetland_census.metric2b_norm CASCADE;
CREATE TRIGGER metric2b_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric2b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric2b_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric2b_value_trigger ON wetland_census.metric2b_norm CASCADE;
CREATE TRIGGER metric2b_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric2b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric2b_value();
-- ddl-end --

-- object: metric3a_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3a_norm_log_trigger ON wetland_census.metric3a_norm CASCADE;
CREATE TRIGGER metric3a_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3a_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric3a_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3a_value_trigger ON wetland_census.metric3a_norm CASCADE;
CREATE TRIGGER metric3a_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3a_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric3a_value();
-- ddl-end --

-- object: metric3b_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3b_norm_log_trigger ON wetland_census.metric3b_norm CASCADE;
CREATE TRIGGER metric3b_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric3b_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3b_value_trigger ON wetland_census.metric3b_norm CASCADE;
CREATE TRIGGER metric3b_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric3b_value();
-- ddl-end --

-- object: metric3c_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3c_norm_log_trigger ON wetland_census.metric3c_norm CASCADE;
CREATE TRIGGER metric3c_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3c_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric3c_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3c_value_trigger ON wetland_census.metric3c_norm CASCADE;
CREATE TRIGGER metric3c_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3c_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric3c_value();
-- ddl-end --

-- object: metric3d_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3d_norm_log_trigger ON wetland_census.metric3d_norm CASCADE;
CREATE TRIGGER metric3d_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3d_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric3d_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3d_value_trigger ON wetland_census.metric3d_norm CASCADE;
CREATE TRIGGER metric3d_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3d_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric3d_value();
-- ddl-end --

-- object: metric3e_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3e_norm_log_trigger ON wetland_census.metric3e_norm CASCADE;
CREATE TRIGGER metric3e_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3e_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric3e_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric3e_value_trigger ON wetland_census.metric3e_norm CASCADE;
CREATE TRIGGER metric3e_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric3e_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric3e_value();
-- ddl-end --

-- object: metric4a_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric4a_norm_log_trigger ON wetland_census.metric4a_norm CASCADE;
CREATE TRIGGER metric4a_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric4a_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric4a_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric4a_value_trigger ON wetland_census.metric4a_norm CASCADE;
CREATE TRIGGER metric4a_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric4a_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric4a_value();
-- ddl-end --

-- object: metric4b_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric4b_norm_log_trigger ON wetland_census.metric4b_norm CASCADE;
CREATE TRIGGER metric4b_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric4b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric4b_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric4b_value_trigger ON wetland_census.metric4b_norm CASCADE;
CREATE TRIGGER metric4b_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric4b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric4b_value();
-- ddl-end --

-- object: metric4c_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric4c_norm_log_trigger ON wetland_census.metric4c_norm CASCADE;
CREATE TRIGGER metric4c_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric4c_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric4c_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric4c_value_trigger ON wetland_census.metric4c_norm CASCADE;
CREATE TRIGGER metric4c_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric4c_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric4c_value();
-- ddl-end --

-- object: metric5_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric5_norm_log_trigger ON wetland_census.metric5_norm CASCADE;
CREATE TRIGGER metric5_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric5_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric5_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric5_value_trigger ON wetland_census.metric5_norm CASCADE;
CREATE TRIGGER metric5_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric5_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric5_value();
-- ddl-end --

-- object: metric6a1_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a1_norm_log_trigger ON wetland_census.metric6a1_norm CASCADE;
CREATE TRIGGER metric6a1_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a1_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a1_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a1_value_trigger ON wetland_census.metric6a1_norm CASCADE;
CREATE TRIGGER metric6a1_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a1_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a1_value();
-- ddl-end --

-- object: metric6a2_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a2_norm_log_trigger ON wetland_census.metric6a2_norm CASCADE;
CREATE TRIGGER metric6a2_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a2_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a2_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a2_value_trigger ON wetland_census.metric6a2_norm CASCADE;
CREATE TRIGGER metric6a2_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a2_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a2_value();
-- ddl-end --

-- object: metric6a3_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a3_norm_log_trigger ON wetland_census.metric6a3_norm CASCADE;
CREATE TRIGGER metric6a3_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a3_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a3_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a3_value_trigger ON wetland_census.metric6a3_norm CASCADE;
CREATE TRIGGER metric6a3_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a3_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a3_value();
-- ddl-end --

-- object: metric6a4_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a4_norm_log_trigger ON wetland_census.metric6a4_norm CASCADE;
CREATE TRIGGER metric6a4_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a4_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a4_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a4_value_trigger ON wetland_census.metric6a4_norm CASCADE;
CREATE TRIGGER metric6a4_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a4_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a4_value();
-- ddl-end --

-- object: metric6a5_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a5_norm_log_trigger ON wetland_census.metric6a5_norm CASCADE;
CREATE TRIGGER metric6a5_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a5_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a5_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a5_value_trigger ON wetland_census.metric6a5_norm CASCADE;
CREATE TRIGGER metric6a5_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a5_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a5_value();
-- ddl-end --

-- object: metric6a6_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a6_norm_log_trigger ON wetland_census.metric6a6_norm CASCADE;
CREATE TRIGGER metric6a6_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a6_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a6_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a6_value_trigger ON wetland_census.metric6a6_norm CASCADE;
CREATE TRIGGER metric6a6_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a6_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a6_value();
-- ddl-end --

-- object: metric6a7_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a7_norm_log_trigger ON wetland_census.metric6a7_norm CASCADE;
CREATE TRIGGER metric6a7_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a7_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6a7_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6a7_value_trigger ON wetland_census.metric6a7_norm CASCADE;
CREATE TRIGGER metric6a7_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6a7_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6a7_value();
-- ddl-end --

-- object: metric6b_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6b_norm_log_trigger ON wetland_census.metric6b_norm CASCADE;
CREATE TRIGGER metric6b_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6b_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6b_value_trigger ON wetland_census.metric6b_norm CASCADE;
CREATE TRIGGER metric6b_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6b_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6b_value();
-- ddl-end --

-- object: metric6c_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6c_norm_log_trigger ON wetland_census.metric6c_norm CASCADE;
CREATE TRIGGER metric6c_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6c_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6c_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6c_value_trigger ON wetland_census.metric6c_norm CASCADE;
CREATE TRIGGER metric6c_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6c_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6c_value();
-- ddl-end --

-- object: metric6d1_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d1_norm_log_trigger ON wetland_census.metric6d1_norm CASCADE;
CREATE TRIGGER metric6d1_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d1_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6d1_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d1_value_trigger ON wetland_census.metric6d1_norm CASCADE;
CREATE TRIGGER metric6d1_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d1_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6d1_value();
-- ddl-end --

-- object: metric6d2_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d2_norm_log_trigger ON wetland_census.metric6d2_norm CASCADE;
CREATE TRIGGER metric6d2_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d2_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6d2_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d2_value_trigger ON wetland_census.metric6d2_norm CASCADE;
CREATE TRIGGER metric6d2_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d2_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6d2_value();
-- ddl-end --

-- object: metric6d3_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d3_norm_log_trigger ON wetland_census.metric6d3_norm CASCADE;
CREATE TRIGGER metric6d3_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d3_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6d3_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d3_value_trigger ON wetland_census.metric6d3_norm CASCADE;
CREATE TRIGGER metric6d3_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d3_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6d3_value();
-- ddl-end --

-- object: metric6d4_norm_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d4_norm_log_trigger ON wetland_census.metric6d4_norm CASCADE;
CREATE TRIGGER metric6d4_norm_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d4_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: metric6d4_value_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric6d4_value_trigger ON wetland_census.metric6d4_norm CASCADE;
CREATE TRIGGER metric6d4_value_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.metric6d4_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric6d4_value();
-- ddl-end --

-- object: metric_insert_all_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS metric_insert_all_trigger ON wetland_census.oram_v2 CASCADE;
CREATE TRIGGER metric_insert_all_trigger
	AFTER INSERT 
	ON wetland_census.oram_v2
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oram_metric_insert_all();
-- ddl-end --

-- object: oram_id_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_id_log_trigger ON wetland_census.oram_id CASCADE;
CREATE TRIGGER oram_id_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_id
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_notes_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_notes_log_trigger ON wetland_census.oram_notes CASCADE;
CREATE TRIGGER oram_notes_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_notes
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_photos_caption_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_photos_caption_log_trigger ON wetland_census.oram_photos_caption_norm CASCADE;
CREATE TRIGGER oram_photos_caption_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_photos_caption_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_photos_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_photos_log_trigger ON wetland_census.oram_photos_norm CASCADE;
CREATE TRIGGER oram_photos_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_photos_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_photos_url_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_photos_url_log_trigger ON wetland_census.oram_photos_url_norm CASCADE;
CREATE TRIGGER oram_photos_url_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_photos_url_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_poly_id_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_poly_id_log_trigger ON wetland_census.oram_poly_id_norm CASCADE;
CREATE TRIGGER oram_poly_id_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_poly_id_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_recorder_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_recorder_log_trigger ON wetland_census.oram_recorder_norm CASCADE;
CREATE TRIGGER oram_recorder_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_recorder_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_reservation_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_reservation_log_trigger ON wetland_census.oram_reservation_norm CASCADE;
CREATE TRIGGER oram_reservation_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_reservation_norm
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: oram_score_lookup_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_score_lookup_log_trigger ON wetland_census.oram_score_lookup_all CASCADE;
CREATE TRIGGER oram_score_lookup_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oram_score_lookup_all
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: bcr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bcr_geom_log_trigger ON wetland_census.bcr_wetlands_final CASCADE;
CREATE TRIGGER bcr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.bcr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: bed_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bed_geom_log_trigger ON wetland_census.bed_wetlands_final CASCADE;
CREATE TRIGGER bed_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.bed_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: bre_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bre_geom_log_trigger ON wetland_census.bre_wetlands_final CASCADE;
CREATE TRIGGER bre_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.bre_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: bwr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bwr_geom_log_trigger ON wetland_census.bwr_wetlands_final CASCADE;
CREATE TRIGGER bwr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.bwr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: ecr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS ecr_geom_log_trigger ON wetland_census.ecr_wetlands_final CASCADE;
CREATE TRIGGER ecr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.ecr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: hin_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS hin_geom_log_trigger ON wetland_census.hin_wetlands_final CASCADE;
CREATE TRIGGER hin_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.hin_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: hun_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS hun_geom_log_trigger ON wetland_census.hun_wetlands_final CASCADE;
CREATE TRIGGER hun_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.hun_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: msr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS msr_geom_log_trigger ON wetland_census.msr_wetlands_final CASCADE;
CREATE TRIGGER msr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.msr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: ncr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS ncr_geom_log_trigger ON wetland_census.ncr_wetlands_final CASCADE;
CREATE TRIGGER ncr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.ncr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: rrr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS rrr_geom_log_trigger ON wetland_census.rrr_wetlands_final CASCADE;
CREATE TRIGGER rrr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.rrr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: scr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS scr_geom_log_trigger ON wetland_census.scr_wetlands_final CASCADE;
CREATE TRIGGER scr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.scr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: wcr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS wcr_geom_log_trigger ON wetland_census.wcr_wetlands_final CASCADE;
CREATE TRIGGER wcr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.wcr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: wetland_census.oec_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.oec_id_seq CASCADE;
CREATE SEQUENCE wetland_census.oec_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.oec_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oec_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.oec_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.oec_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.oec_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oec_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oec_wetlands_final CASCADE;
CREATE TABLE wetland_census.oec_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('oec_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.oec_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT oec_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.oec_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: oec_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oec_geom_log_trigger ON wetland_census.oec_wetlands_final CASCADE;
CREATE TRIGGER oec_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.oec_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: wetland_census.brr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.brr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.brr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.brr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.brr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.brr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.brr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.brr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.brr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.brr_wetlands_final CASCADE;
CREATE TABLE wetland_census.brr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('brr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.brr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT brr_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.brr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: brr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS brr_geom_log_trigger ON wetland_census.brr_wetlands_final CASCADE;
CREATE TRIGGER brr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.brr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: wetland_census.gpr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.gpr_id_seq CASCADE;
CREATE SEQUENCE wetland_census.gpr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.gpr_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.gpr_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.gpr_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.gpr_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.gpr_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.gpr_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.gpr_wetlands_final CASCADE;
CREATE TABLE wetland_census.gpr_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('gpr_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.gpr_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT gpr_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.gpr_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: gpr_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS gpr_geom_log_trigger ON wetland_census.gpr_wetlands_final CASCADE;
CREATE TRIGGER gpr_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.gpr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: wetland_census.war_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.war_id_seq CASCADE;
CREATE SEQUENCE wetland_census.war_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.war_id_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.war_wetlands_final_gid_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS wetland_census.war_wetlands_final_gid_seq CASCADE;
CREATE SEQUENCE wetland_census.war_wetlands_final_gid_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE wetland_census.war_wetlands_final_gid_seq OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.war_wetlands_final | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.war_wetlands_final CASCADE;
CREATE TABLE wetland_census.war_wetlands_final(
	unique_id text NOT NULL DEFAULT to_char(nextval('war_id_seq'::regclass), '000'::text),
	reserv text NOT NULL,
	gid integer NOT NULL DEFAULT nextval('wetland_census.war_wetlands_final_gid_seq'::regclass),
	hgm_class character varying(20),
	veg_class character varying(20),
	CONSTRAINT war_wetlands_final_pkey PRIMARY KEY (unique_id,reserv)

) INHERITS(wetland_census.cm_wetlands_all)
;
-- ddl-end --
ALTER TABLE wetland_census.war_wetlands_final OWNER TO postgres;
-- ddl-end --

-- object: war_geom_log_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS war_geom_log_trigger ON wetland_census.war_wetlands_final CASCADE;
CREATE TRIGGER war_geom_log_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.war_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.change_trigger();
-- ddl-end --

-- object: wetland_census.oram_data_joined | type: VIEW --
-- DROP VIEW IF EXISTS wetland_census.oram_data_joined CASCADE;
CREATE VIEW wetland_census.oram_data_joined
AS 

WITH id_joined AS (
         SELECT a.oram_id,
            a.polygon_id,
            b.reservation
           FROM (oram_poly_id_norm a
             LEFT JOIN oram_reservation_norm b ON ((a.oram_id = b.oram_id)))
        ), metric1 AS (
         SELECT metric1_norm.oram_id,
            metric1_norm.selection AS metric1_selection
           FROM metric1_norm
          GROUP BY metric1_norm.oram_id, metric1_norm.selection
        ), metric2a AS (
         SELECT metric2a_norm.oram_id,
            metric2a_norm.selection AS metric2a_selection
           FROM metric2a_norm
          GROUP BY metric2a_norm.oram_id, metric2a_norm.selection
        ), metric2b_agg AS (
         SELECT metric2b_norm.oram_id,
            string_agg(metric2b_norm.selection, ','::text) AS metric2b_selection
           FROM metric2b_norm
          GROUP BY metric2b_norm.oram_id
        ), metric3a_agg AS (
         SELECT metric3a_norm.oram_id,
            string_agg(metric3a_norm.selection, ','::text) AS metric3a_selection
           FROM metric3a_norm
          GROUP BY metric3a_norm.oram_id
        ), metric3b_agg AS (
         SELECT metric3b_norm.oram_id,
            string_agg(metric3b_norm.selection, ','::text) AS metric3b_selection
           FROM metric3b_norm
          GROUP BY metric3b_norm.oram_id
        ), metric3c AS (
         SELECT metric3c_norm.oram_id,
            metric3c_norm.selection AS metric3c_selection
           FROM metric3c_norm
          GROUP BY metric3c_norm.oram_id, metric3c_norm.selection
        ), metric3d_agg AS (
         SELECT metric3d_norm.oram_id,
            string_agg(metric3d_norm.selection, ','::text) AS metric3d_selection
           FROM metric3d_norm
          GROUP BY metric3d_norm.oram_id
        ), metric3e_agg AS (
         SELECT metric3e_norm.oram_id,
            string_agg(metric3e_norm.selection, ','::text) AS metric3e_selection
           FROM metric3e_norm
          GROUP BY metric3e_norm.oram_id
        ), hydro_disturbance_agg AS (
         SELECT hydro_disturbances_norm.oram_id,
            string_agg(hydro_disturbances_norm.disturbances_hydro, ','::text) AS hydro_disturbances
           FROM hydro_disturbances_norm
          GROUP BY hydro_disturbances_norm.oram_id
        ), metric4a_agg AS (
         SELECT metric4a_norm.oram_id,
            string_agg(metric4a_norm.selection, ','::text) AS metric4a_selection
           FROM metric4a_norm
          GROUP BY metric4a_norm.oram_id
        ), metric4b AS (
         SELECT metric4b_norm.oram_id,
            metric4b_norm.selection AS metric4b_selection
           FROM metric4b_norm
          GROUP BY metric4b_norm.oram_id, metric4b_norm.selection
        ), metric4c_agg AS (
         SELECT metric4c_norm.oram_id,
            string_agg(metric4c_norm.selection, ','::text) AS metric4c_selection
           FROM metric4c_norm
          GROUP BY metric4c_norm.oram_id
        ), substrate_disturbance_agg AS (
         SELECT substrate_disturbances_norm.oram_id,
            string_agg(substrate_disturbances_norm.disturbances_substrate, ','::text) AS substrate_disturbances
           FROM substrate_disturbances_norm
          GROUP BY substrate_disturbances_norm.oram_id
        ), metric5_agg AS (
         SELECT metric5_norm.oram_id,
            string_agg(metric5_norm.selection, ','::text) AS metric5_selection
           FROM metric5_norm
          GROUP BY metric5_norm.oram_id
        ), metric6a1 AS (
         SELECT metric6a1_norm.oram_id,
            string_agg(metric6a1_norm.selection, ','::text) AS metric6a1_selection_aquatic_bed
           FROM metric6a1_norm
          GROUP BY metric6a1_norm.oram_id
        ), metric6a2 AS (
         SELECT metric6a2_norm.oram_id,
            string_agg(metric6a2_norm.selection, ','::text) AS metric6a2_selection_emergent
           FROM metric6a2_norm
          GROUP BY metric6a2_norm.oram_id
        ), metric6a3 AS (
         SELECT metric6a3_norm.oram_id,
            string_agg(metric6a3_norm.selection, ','::text) AS metric6a3_selection_shrub
           FROM metric6a3_norm
          GROUP BY metric6a3_norm.oram_id
        ), metric6a4 AS (
         SELECT metric6a4_norm.oram_id,
            string_agg(metric6a4_norm.selection, ','::text) AS metric6a4_selection_forest
           FROM metric6a4_norm
          GROUP BY metric6a4_norm.oram_id
        ), metric6a5 AS (
         SELECT metric6a5_norm.oram_id,
            string_agg(metric6a5_norm.selection, ','::text) AS metric6a5_selection_mudflat
           FROM metric6a5_norm
          GROUP BY metric6a5_norm.oram_id
        ), metric6a6 AS (
         SELECT metric6a6_norm.oram_id,
            string_agg(metric6a6_norm.selection, ','::text) AS metric6a6_selection_open_water
           FROM metric6a6_norm
          GROUP BY metric6a6_norm.oram_id
        ), metric6a7 AS (
         SELECT metric6a7_norm.oram_id,
            string_agg(metric6a7_norm.selection, ','::text) AS metric6a7_selection_other
           FROM metric6a7_norm
          GROUP BY metric6a7_norm.oram_id
        ), metric6b AS (
         SELECT metric6b_norm.oram_id,
            metric6b_norm.selection AS metric6b_selection
           FROM metric6b_norm
          GROUP BY metric6b_norm.oram_id, metric6b_norm.selection
        ), metric6c AS (
         SELECT metric6c_norm.oram_id,
            metric6c_norm.selection AS metric6c_selection
           FROM metric6c_norm
          GROUP BY metric6c_norm.oram_id, metric6c_norm.selection
        ), metric6d1 AS (
         SELECT metric6d1_norm.oram_id,
            metric6d1_norm.selection AS metric6d1_hummocks_tussocks
           FROM metric6d1_norm
          GROUP BY metric6d1_norm.oram_id, metric6d1_norm.selection
        ), metric6d2 AS (
         SELECT metric6d2_norm.oram_id,
            metric6d2_norm.selection AS metric6d2_cwd
           FROM metric6d2_norm
          GROUP BY metric6d2_norm.oram_id, metric6d2_norm.selection
        ), metric6d3 AS (
         SELECT metric6d3_norm.oram_id,
            metric6d3_norm.selection AS metric6d3_standing_dead
           FROM metric6d3_norm
          GROUP BY metric6d3_norm.oram_id, metric6d3_norm.selection
        ), metric6d4 AS (
         SELECT metric6d4_norm.oram_id,
            metric6d4_norm.selection AS metric6d4_amphibian_pools
           FROM metric6d4_norm
          GROUP BY metric6d4_norm.oram_id, metric6d4_norm.selection
        )
 SELECT id_joined.oram_id,
    id_joined.polygon_id,
    id_joined.reservation,
    metric1.metric1_selection,
    metric2a.metric2a_selection,
    metric2b_agg.metric2b_selection,
    metric3a_agg.metric3a_selection,
    metric3b_agg.metric3b_selection,
    metric3c.metric3c_selection,
    metric3d_agg.metric3d_selection,
    metric3e_agg.metric3e_selection,
    hydro_disturbance_agg.hydro_disturbances,
    metric4a_agg.metric4a_selection,
    metric4b.metric4b_selection,
    metric4c_agg.metric4c_selection,
    substrate_disturbance_agg.substrate_disturbances,
    metric5_agg.metric5_selection,
    metric6a1.metric6a1_selection_aquatic_bed,
    metric6a2.metric6a2_selection_emergent,
    metric6a3.metric6a3_selection_shrub,
    metric6a4.metric6a4_selection_forest,
    metric6a5.metric6a5_selection_mudflat,
    metric6a6.metric6a6_selection_open_water,
    metric6a7.metric6a7_selection_other,
    metric6b.metric6b_selection,
    metric6c.metric6c_selection,
    metric6d1.metric6d1_hummocks_tussocks,
    metric6d2.metric6d2_cwd,
    metric6d3.metric6d3_standing_dead,
    metric6d4.metric6d4_amphibian_pools
   FROM (((((((((((((((((((((((((((id_joined
     LEFT JOIN metric1 USING (oram_id))
     LEFT JOIN metric2a USING (oram_id))
     LEFT JOIN metric2b_agg USING (oram_id))
     LEFT JOIN metric3a_agg USING (oram_id))
     LEFT JOIN metric3b_agg USING (oram_id))
     LEFT JOIN metric3c USING (oram_id))
     LEFT JOIN metric3d_agg USING (oram_id))
     LEFT JOIN metric3e_agg USING (oram_id))
     LEFT JOIN hydro_disturbance_agg USING (oram_id))
     LEFT JOIN metric4a_agg USING (oram_id))
     LEFT JOIN metric4b USING (oram_id))
     LEFT JOIN metric4c_agg USING (oram_id))
     LEFT JOIN substrate_disturbance_agg USING (oram_id))
     LEFT JOIN metric5_agg USING (oram_id))
     LEFT JOIN metric6a1 USING (oram_id))
     LEFT JOIN metric6a2 USING (oram_id))
     LEFT JOIN metric6a3 USING (oram_id))
     LEFT JOIN metric6a4 USING (oram_id))
     LEFT JOIN metric6a5 USING (oram_id))
     LEFT JOIN metric6a6 USING (oram_id))
     LEFT JOIN metric6a7 USING (oram_id))
     LEFT JOIN metric6b USING (oram_id))
     LEFT JOIN metric6c USING (oram_id))
     LEFT JOIN metric6d1 USING (oram_id))
     LEFT JOIN metric6d2 USING (oram_id))
     LEFT JOIN metric6d3 USING (oram_id))
     LEFT JOIN metric6d4 USING (oram_id));
-- ddl-end --
ALTER VIEW wetland_census.oram_data_joined OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bcr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.bcr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.bcr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
	UPDATE bcr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE bcr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.bcr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bed_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.bed_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.bed_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
	UPDATE bed_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE bed_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.bed_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bre_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.bre_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.bre_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE bre_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE bre_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.bre_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.brr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.brr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.brr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE brr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE brr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.brr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.bwr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.bwr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.bwr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
	UPDATE bwr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE bwr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.bwr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ecr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.ecr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.ecr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE ecr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE ecr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.ecr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.gpr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.gpr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.gpr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE gpr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE gpr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.gpr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hin_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.hin_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.hin_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE hin_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE hin_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.hin_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.hun_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.hun_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.hun_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

            BEGIN
            IF(TG_OP='INSERT') THEN
            UPDATE hun_wetlands_final
            SET unique_id = trim(unique_id);
            ELSIF(TP_OP='UPDATE') THEN
            UPDATE hun_wetlands_final
            SET unique_id = trim(unique_id);
            END IF;
            RETURN NEW;
            END;
            
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.hun_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.msr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.msr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.msr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE msr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE msr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.msr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.ncr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.ncr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.ncr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE ncr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE ncr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.ncr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oec_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oec_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.oec_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE oec_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE oec_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oec_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.rrr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.rrr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.rrr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
	UPDATE rrr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE rrr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.rrr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.scr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.scr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.scr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
	UPDATE scr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE scr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.scr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.war_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.war_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.war_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE war_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE war_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.war_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.wcr_wetland_trim | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.wcr_wetland_trim() CASCADE;
CREATE FUNCTION wetland_census.wcr_wetland_trim ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

  BEGIN
  IF(TG_OP='INSERT') THEN
  UPDATE wcr_wetlands_final
		SET unique_id = trim(unique_id);
	ELSIF(TP_OP='UPDATE') THEN
	UPDATE wcr_wetlands_final
		SET unique_id = trim(unique_id);
	END IF;
	RETURN NEW;
END;
 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.wcr_wetland_trim() OWNER TO postgres;
-- ddl-end --

-- object: bcr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bcr_wetland_trim_trigger ON wetland_census.bcr_wetlands_final CASCADE;
CREATE TRIGGER bcr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.bcr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.bcr_wetland_trim();
-- ddl-end --

-- object: bed_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bed_wetland_trim_trigger ON wetland_census.bed_wetlands_final CASCADE;
CREATE TRIGGER bed_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.bed_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.bed_wetland_trim();
-- ddl-end --

-- object: bre_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bre_wetland_trim_trigger ON wetland_census.bre_wetlands_final CASCADE;
CREATE TRIGGER bre_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.bre_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.bre_wetland_trim();
-- ddl-end --

-- object: brr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS brr_wetland_trim_trigger ON wetland_census.brr_wetlands_final CASCADE;
CREATE TRIGGER brr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.brr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.brr_wetland_trim();
-- ddl-end --

-- object: bwr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS bwr_wetland_trim_trigger ON wetland_census.bwr_wetlands_final CASCADE;
CREATE TRIGGER bwr_wetland_trim_trigger
	AFTER INSERT OR DELETE OR UPDATE
	ON wetland_census.bwr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.bwr_wetland_trim();
-- ddl-end --

-- object: ecr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS ecr_wetland_trim_trigger ON wetland_census.ecr_wetlands_final CASCADE;
CREATE TRIGGER ecr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.ecr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.ecr_wetland_trim();
-- ddl-end --

-- object: gpr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS gpr_wetland_trim_trigger ON wetland_census.gpr_wetlands_final CASCADE;
CREATE TRIGGER gpr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.gpr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.gpr_wetland_trim();
-- ddl-end --

-- object: hin_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS hin_wetland_trim_trigger ON wetland_census.hin_wetlands_final CASCADE;
CREATE TRIGGER hin_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.hin_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.hin_wetland_trim();
-- ddl-end --

-- object: hun_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS hun_wetland_trim_trigger ON wetland_census.hun_wetlands_final CASCADE;
CREATE TRIGGER hun_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.hun_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.hun_wetland_trim();
-- ddl-end --

-- object: msr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS msr_wetland_trim_trigger ON wetland_census.msr_wetlands_final CASCADE;
CREATE TRIGGER msr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.msr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.msr_wetland_trim();
-- ddl-end --

-- object: ncr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS ncr_wetland_trim_trigger ON wetland_census.ncr_wetlands_final CASCADE;
CREATE TRIGGER ncr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.ncr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.ncr_wetland_trim();
-- ddl-end --

-- object: oec_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oec_wetland_trim_trigger ON wetland_census.oec_wetlands_final CASCADE;
CREATE TRIGGER oec_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.oec_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.oec_wetland_trim();
-- ddl-end --

-- object: rrr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS rrr_wetland_trim_trigger ON wetland_census.rrr_wetlands_final CASCADE;
CREATE TRIGGER rrr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.rrr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.rrr_wetland_trim();
-- ddl-end --

-- object: scr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS scr_wetland_trim_trigger ON wetland_census.scr_wetlands_final CASCADE;
CREATE TRIGGER scr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.scr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.scr_wetland_trim();
-- ddl-end --

-- object: war_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS war_wetland_trim_trigger ON wetland_census.war_wetlands_final CASCADE;
CREATE TRIGGER war_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.war_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.war_wetland_trim();
-- ddl-end --

-- object: wcr_wetland_trim_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS wcr_wetland_trim_trigger ON wetland_census.wcr_wetlands_final CASCADE;
CREATE TRIGGER wcr_wetland_trim_trigger
	AFTER INSERT 
	ON wetland_census.wcr_wetlands_final
	FOR EACH ROW
	EXECUTE PROCEDURE wetland_census.wcr_wetland_trim();
-- ddl-end --

-- object: wetland_census.cm_wetland_class_oram | type: VIEW --
-- DROP VIEW IF EXISTS wetland_census.cm_wetland_class_oram CASCADE;
CREATE VIEW wetland_census.cm_wetland_class_oram
AS 

WITH joined AS (
         SELECT poly.unique_id,
            poly.reserv,
            poly.geom,
            poly.area_acres,
            poly.poly_type,
            poly.cm_id,
            id.classification_level,
            id.classification_id
           FROM (cm_wetlands_all poly
             LEFT JOIN cm_wetland_classification_id id ON (((poly.unique_id = id.polygon_id) AND (poly.reserv = id.reservation) AND (id.classification_level <> 'secondary'::text) AND (id.classification_level <> 'minor'::text))))
        ), landscape_agg AS (
         SELECT cm_wetland_landscape_position_norm.classification_id,
            string_agg(cm_wetland_landscape_position_norm.landscape_position, ','::text) AS landscape_position
           FROM cm_wetland_landscape_position_norm
          GROUP BY cm_wetland_landscape_position_norm.classification_id
        ), landform_agg AS (
         SELECT cm_wetland_inland_landform_norm.classification_id,
            string_agg(cm_wetland_inland_landform_norm.inland_landform, ','::text) AS landform
           FROM cm_wetland_inland_landform_norm
          GROUP BY cm_wetland_inland_landform_norm.classification_id
        ), waterflow_agg AS (
         SELECT cm_wetland_water_flow_path.classification_id,
            string_agg(cm_wetland_water_flow_path.water_flow_path, ','::text) AS water_flow_path
           FROM cm_wetland_water_flow_path
          GROUP BY cm_wetland_water_flow_path.classification_id
        ), llww_mod_agg AS (
         SELECT cm_wetland_llww_modifiers.classification_id,
            string_agg(cm_wetland_llww_modifiers.llww_modifiers, ','::text) AS llww_modifiers
           FROM cm_wetland_llww_modifiers
          GROUP BY cm_wetland_llww_modifiers.classification_id
        ), cowardin_agg AS (
         SELECT cm_wetland_cowardin_classification.classification_id,
            string_agg(cm_wetland_cowardin_classification.cowardin_classification, ','::text) AS cowardin_classification
           FROM cm_wetland_cowardin_classification
          GROUP BY cm_wetland_cowardin_classification.classification_id
        ), cowardin_water_agg AS (
         SELECT cm_wetland_cowardin_water_regime.classification_id,
            string_agg(cm_wetland_cowardin_water_regime.cowardin_water_regime, ','::text) AS cowardin_water_regime
           FROM cm_wetland_cowardin_water_regime
          GROUP BY cm_wetland_cowardin_water_regime.classification_id
        ), cowardin_special_agg AS (
         SELECT cm_wetland_cowardin_special_modifier.classification_id,
            string_agg(cm_wetland_cowardin_special_modifier.cowardin_special_modifier, ','::text) AS cowardin_special_modifier
           FROM cm_wetland_cowardin_special_modifier
          GROUP BY cm_wetland_cowardin_special_modifier.classification_id
        ), plant_comm_agg AS (
         SELECT cm_wetland_plant_community_norm.classification_id,
            string_agg(cm_wetland_plant_community_norm.plant_community, ','::text) AS plant_community
           FROM cm_wetland_plant_community_norm
          GROUP BY cm_wetland_plant_community_norm.classification_id
        ), oram_poly_res AS (
         SELECT oram_poly_id_norm.oram_id,
            oram_poly_id_norm.polygon_id,
            oram_reservation_norm.reservation,
            cm_wetland_oram_category.grand_total,
            cm_wetland_oram_category.category
           FROM ((oram_poly_id_norm
             LEFT JOIN oram_reservation_norm USING (oram_id))
             LEFT JOIN cm_wetland_oram_category USING (oram_id))
        ), oram_poly_agg AS (
         SELECT oram_poly_res.polygon_id,
            oram_poly_res.reservation,
            string_agg((oram_poly_res.oram_id)::text, ','::text) AS oram_id,
            string_agg((oram_poly_res.grand_total)::text, ','::text) AS grand_total,
            string_agg(oram_poly_res.category, ','::text) AS category
           FROM oram_poly_res
          GROUP BY oram_poly_res.polygon_id, oram_poly_res.reservation
        )
 SELECT joined.classification_id,
    joined.unique_id,
    joined.reserv,
    joined.geom,
    joined.area_acres,
    joined.poly_type,
    joined.cm_id,
    joined.classification_level,
    landscape_agg.landscape_position,
    landform_agg.landform,
    waterflow_agg.water_flow_path,
    llww_mod_agg.llww_modifiers,
    cowardin_agg.cowardin_classification,
    cowardin_water_agg.cowardin_water_regime,
    cowardin_special_agg.cowardin_special_modifier,
    plant_comm_agg.plant_community,
    oram_poly_agg.polygon_id,
    oram_poly_agg.reservation,
    oram_poly_agg.oram_id,
    oram_poly_agg.grand_total,
    oram_poly_agg.category
   FROM (((((((((joined
     LEFT JOIN landscape_agg USING (classification_id))
     LEFT JOIN landform_agg USING (classification_id))
     LEFT JOIN waterflow_agg USING (classification_id))
     LEFT JOIN llww_mod_agg USING (classification_id))
     LEFT JOIN cowardin_agg USING (classification_id))
     LEFT JOIN cowardin_water_agg USING (classification_id))
     LEFT JOIN cowardin_special_agg USING (classification_id))
     LEFT JOIN plant_comm_agg USING (classification_id))
     LEFT JOIN oram_poly_agg ON (((joined.unique_id = oram_poly_agg.polygon_id) AND (joined.reserv = oram_poly_agg.reservation))));
-- ddl-end --
ALTER VIEW wetland_census.cm_wetland_class_oram OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.mapping_pkeys | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.mapping_pkeys CASCADE;
CREATE TABLE wetland_census.mapping_pkeys(
	polygon_id text NOT NULL,
	reservation text NOT NULL,
	cm_id integer NOT NULL,
	CONSTRAINT mapping_pkeys_pkey PRIMARY KEY (cm_id),
	CONSTRAINT mapping_pkeys_polygon_id_reservation_key UNIQUE (polygon_id,reservation)

);
-- ddl-end --
ALTER TABLE wetland_census.mapping_pkeys OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.oram_mapping_pkeys | type: TABLE --
-- DROP TABLE IF EXISTS wetland_census.oram_mapping_pkeys CASCADE;
CREATE TABLE wetland_census.oram_mapping_pkeys(
	polygon_id text NOT NULL,
	reservation text NOT NULL,
	oram_id integer NOT NULL,
	CONSTRAINT oram_mapping_pkey PRIMARY KEY (oram_id,polygon_id)

);
-- ddl-end --
ALTER TABLE wetland_census.oram_mapping_pkeys OWNER TO postgres;
-- ddl-end --

-- object: wetland_census.mapping_pkey_upsert | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.mapping_pkey_upsert() CASCADE;
CREATE FUNCTION wetland_census.mapping_pkey_upsert ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN

INSERT INTO mapping_pkeys SELECT unique_id, reserv, cm_id FROM cm_wetlands_all ON CONFLICT (cm_id) DO UPDATE SET polygon_id = (SELECT unique_id FROM cm_wetlands_all WHERE cm_id = mapping_pkeys.cm_id), reservation = (SELECT reserv FROM cm_wetlands_all WHERE cm_id = mapping_pkeys.cm_id);
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.mapping_pkey_upsert() OWNER TO postgres;
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.bcr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.bed_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bed_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.bre_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bre_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.brr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.brr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.bwr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bwr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.ecr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.ecr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.gpr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.gpr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.hin_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.hin_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.hun_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.hun_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.msr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.msr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.ncr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.ncr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.oec_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.oec_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.rrr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.rrr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.scr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.scr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.war_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.war_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_upsert_trigger ON wetland_census.wcr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.wcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_upsert();
-- ddl-end --

-- object: wetland_census.mapping_pkey_delete | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.mapping_pkey_delete() CASCADE;
CREATE FUNCTION wetland_census.mapping_pkey_delete ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN

DELETE FROM mapping_pkeys WHERE cm_id NOT IN (SELECT cm_id FROM cm_wetlands_all);
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.mapping_pkey_delete() OWNER TO postgres;
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.bcr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.bed_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bed_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.bre_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bre_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.brr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.brr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.bwr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bwr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.ecr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.ecr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.gpr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.gpr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.hin_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.hin_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.hun_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.hun_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.msr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.msr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.ncr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.ncr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.oec_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.oec_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.rrr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.rrr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.scr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.scr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.war_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.war_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS mapping_pkey_delete_trigger ON wetland_census.wcr_wetlands_final CASCADE;
CREATE TRIGGER mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.wcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.mapping_pkey_delete();
-- ddl-end --

-- object: wetland_census.oram_mapping_pkey_upsert | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_mapping_pkey_upsert() CASCADE;
CREATE FUNCTION wetland_census.oram_mapping_pkey_upsert ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN
  
WITH oram_ids_joined AS (
SELECT * FROM oram_poly_id_norm
JOIN oram_reservation_norm USING (oram_id))

INSERT INTO oram_mapping_pkeys SELECT polygon_id, reservation, oram_id FROM  oram_ids_joined ON CONFLICT (oram_id,polygon_id) DO UPDATE SET polygon_id  = (SELECT polygon_id FROM oram_ids_joined WHERE oram_id = oram_mapping_pkeys.oram_id AND polygon_id = oram_mapping_pkeys.polygon_id), reservation = (SELECT reservation FROM oram_ids_joined WHERE oram_id = oram_mapping_pkeys.oram_id AND polygon_id = oram_mapping_pkeys.polygon_id);
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_mapping_pkey_upsert() OWNER TO postgres;
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.bcr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.bed_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bed_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.bre_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bre_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.brr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.brr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.bwr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.bwr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.ecr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.ecr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.gpr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.gpr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.hin_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.hin_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.hun_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.hun_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.msr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.msr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.ncr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.ncr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.oec_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.oec_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.rrr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.rrr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.scr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.scr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.war_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.war_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: oram_mapping_pkey_upsert_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_upsert_trigger ON wetland_census.wcr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_upsert_trigger
	AFTER INSERT OR UPDATE
	ON wetland_census.wcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_upsert();
-- ddl-end --

-- object: wetland_census.oram_mapping_pkey_delete | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.oram_mapping_pkey_delete() CASCADE;
CREATE FUNCTION wetland_census.oram_mapping_pkey_delete ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN

DELETE FROM oram_mapping_pkeys WHERE (polygon_id,reservation) NOT IN (SELECT unique_id AS polygon_id, reserv AS reservation FROM cm_wetlands_all);
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.oram_mapping_pkey_delete() OWNER TO postgres;
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.bcr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.bed_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bed_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.bre_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bre_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.brr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.brr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.bwr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.bwr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.ecr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.ecr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.gpr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.gpr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.hin_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.hin_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.hun_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.hun_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.msr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.msr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.ncr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.ncr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.oec_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.oec_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.rrr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.rrr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.scr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.scr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.war_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.war_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: oram_mapping_pkey_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS oram_mapping_pkey_delete_trigger ON wetland_census.wcr_wetlands_final CASCADE;
CREATE TRIGGER oram_mapping_pkey_delete_trigger
	AFTER DELETE 
	ON wetland_census.wcr_wetlands_final
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.oram_mapping_pkey_delete();
-- ddl-end --

-- object: wetland_census.unused_oram_id_delete | type: FUNCTION --
-- DROP FUNCTION IF EXISTS wetland_census.unused_oram_id_delete() CASCADE;
CREATE FUNCTION wetland_census.unused_oram_id_delete ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	COST 100
	AS $$

BEGIN

DELETE FROM oram_id WHERE (oram_id) NOT IN (SELECT oram_id FROM oram_poly_id_norm);
RETURN NEW;
END 
$$;
-- ddl-end --
ALTER FUNCTION wetland_census.unused_oram_id_delete() OWNER TO postgres;
-- ddl-end --

-- object: unused_oram_id_delete_trigger | type: TRIGGER --
-- DROP TRIGGER IF EXISTS unused_oram_id_delete_trigger ON wetland_census.oram_poly_id_norm CASCADE;
CREATE TRIGGER unused_oram_id_delete_trigger
	AFTER DELETE OR UPDATE
	ON wetland_census.oram_poly_id_norm
	FOR EACH STATEMENT
	EXECUTE PROCEDURE wetland_census.unused_oram_id_delete();
-- ddl-end --

-- object: classification_to_mapping_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_id DROP CONSTRAINT IF EXISTS classification_to_mapping_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_id ADD CONSTRAINT classification_to_mapping_fkey FOREIGN KEY (polygon_id,reservation)
REFERENCES wetland_census.mapping_pkeys (polygon_id,reservation) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_cowardin_classification_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_cowardin_classification DROP CONSTRAINT IF EXISTS cm_wetland_cowardin_classification_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_cowardin_classification ADD CONSTRAINT cm_wetland_cowardin_classification_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_cowardin_special_modifier_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_cowardin_special_modifier DROP CONSTRAINT IF EXISTS cm_wetland_cowardin_special_modifier_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_cowardin_special_modifier ADD CONSTRAINT cm_wetland_cowardin_special_modifier_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_cowardin_water_regime_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_cowardin_water_regime DROP CONSTRAINT IF EXISTS cm_wetland_cowardin_water_regime_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_cowardin_water_regime ADD CONSTRAINT cm_wetland_cowardin_water_regime_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_inland_landform_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_inland_landform_norm DROP CONSTRAINT IF EXISTS cm_wetland_inland_landform_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_inland_landform_norm ADD CONSTRAINT cm_wetland_inland_landform_norm_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_landscape_position_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_landscape_position_norm DROP CONSTRAINT IF EXISTS cm_wetland_landscape_position_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_landscape_position_norm ADD CONSTRAINT cm_wetland_landscape_position_norm_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_llww_modifiers_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_llww_modifiers DROP CONSTRAINT IF EXISTS cm_wetland_llww_modifiers_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_llww_modifiers ADD CONSTRAINT cm_wetland_llww_modifiers_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric1_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric1_value DROP CONSTRAINT IF EXISTS metric1_id_fkey CASCADE;
ALTER TABLE wetland_census.metric1_value ADD CONSTRAINT metric1_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric1_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric1_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric1_value DROP CONSTRAINT IF EXISTS metric1_value_fkey CASCADE;
ALTER TABLE wetland_census.metric1_value ADD CONSTRAINT metric1_value_fkey FOREIGN KEY (metric1_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric2a_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric2a_value DROP CONSTRAINT IF EXISTS metric2a_id_fkey CASCADE;
ALTER TABLE wetland_census.metric2a_value ADD CONSTRAINT metric2a_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric2a_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric2a_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric2a_value DROP CONSTRAINT IF EXISTS metric2a_value_fkey CASCADE;
ALTER TABLE wetland_census.metric2a_value ADD CONSTRAINT metric2a_value_fkey FOREIGN KEY (metric2a_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric2b_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric2b_value DROP CONSTRAINT IF EXISTS metric2b_id_fkey CASCADE;
ALTER TABLE wetland_census.metric2b_value ADD CONSTRAINT metric2b_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric2b_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric2b_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric2b_value DROP CONSTRAINT IF EXISTS metric2b_value_fkey CASCADE;
ALTER TABLE wetland_census.metric2b_value ADD CONSTRAINT metric2b_value_fkey FOREIGN KEY (metric2b_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3a_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3a_value DROP CONSTRAINT IF EXISTS metric3a_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3a_value ADD CONSTRAINT metric3a_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric3a_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3a_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3a_value DROP CONSTRAINT IF EXISTS metric3a_value_fkey CASCADE;
ALTER TABLE wetland_census.metric3a_value ADD CONSTRAINT metric3a_value_fkey FOREIGN KEY (metric3a_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3b_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3b_value DROP CONSTRAINT IF EXISTS metric3b_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3b_value ADD CONSTRAINT metric3b_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric3b_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3b_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3b_value DROP CONSTRAINT IF EXISTS metric3b_value_fkey CASCADE;
ALTER TABLE wetland_census.metric3b_value ADD CONSTRAINT metric3b_value_fkey FOREIGN KEY (metric3b_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3c_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3c_value DROP CONSTRAINT IF EXISTS metric3c_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3c_value ADD CONSTRAINT metric3c_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric3c_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3c_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3c_value DROP CONSTRAINT IF EXISTS metric3c_value_fkey CASCADE;
ALTER TABLE wetland_census.metric3c_value ADD CONSTRAINT metric3c_value_fkey FOREIGN KEY (metric3c_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3d_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3d_value DROP CONSTRAINT IF EXISTS metric3d_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3d_value ADD CONSTRAINT metric3d_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric3d_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3d_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3d_value DROP CONSTRAINT IF EXISTS metric3d_value_fkey CASCADE;
ALTER TABLE wetland_census.metric3d_value ADD CONSTRAINT metric3d_value_fkey FOREIGN KEY (metric3d_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3e_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3e_value DROP CONSTRAINT IF EXISTS metric3e_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3e_value ADD CONSTRAINT metric3e_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric3e_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3e_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3e_value DROP CONSTRAINT IF EXISTS metric3e_value_fkey CASCADE;
ALTER TABLE wetland_census.metric3e_value ADD CONSTRAINT metric3e_value_fkey FOREIGN KEY (metric3e_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4a_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4a_value DROP CONSTRAINT IF EXISTS metric4a_id_fkey CASCADE;
ALTER TABLE wetland_census.metric4a_value ADD CONSTRAINT metric4a_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric4a_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4a_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4a_value DROP CONSTRAINT IF EXISTS metric4a_value_fkey CASCADE;
ALTER TABLE wetland_census.metric4a_value ADD CONSTRAINT metric4a_value_fkey FOREIGN KEY (metric4a_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4b_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4b_value DROP CONSTRAINT IF EXISTS metric4b_id_fkey CASCADE;
ALTER TABLE wetland_census.metric4b_value ADD CONSTRAINT metric4b_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric4b_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4b_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4b_value DROP CONSTRAINT IF EXISTS metric4b_value_fkey CASCADE;
ALTER TABLE wetland_census.metric4b_value ADD CONSTRAINT metric4b_value_fkey FOREIGN KEY (metric4b_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4c_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4c_value DROP CONSTRAINT IF EXISTS metric4c_id_fkey CASCADE;
ALTER TABLE wetland_census.metric4c_value ADD CONSTRAINT metric4c_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric4c_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4c_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4c_value DROP CONSTRAINT IF EXISTS metric4c_value_fkey CASCADE;
ALTER TABLE wetland_census.metric4c_value ADD CONSTRAINT metric4c_value_fkey FOREIGN KEY (metric4c_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric5_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric5_value DROP CONSTRAINT IF EXISTS metric5_id_fkey CASCADE;
ALTER TABLE wetland_census.metric5_value ADD CONSTRAINT metric5_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric5_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric5_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric5_value DROP CONSTRAINT IF EXISTS metric5_value_fkey CASCADE;
ALTER TABLE wetland_census.metric5_value ADD CONSTRAINT metric5_value_fkey FOREIGN KEY (metric5_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a1_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a1_value DROP CONSTRAINT IF EXISTS metric6a1_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a1_value ADD CONSTRAINT metric6a1_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a1_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a1_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a1_value DROP CONSTRAINT IF EXISTS metric6a1_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a1_value ADD CONSTRAINT metric6a1_value_fkey FOREIGN KEY (metric6a1_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a2_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a2_value DROP CONSTRAINT IF EXISTS metric6a2_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a2_value ADD CONSTRAINT metric6a2_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a2_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a2_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a2_value DROP CONSTRAINT IF EXISTS metric6a2_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a2_value ADD CONSTRAINT metric6a2_value_fkey FOREIGN KEY (metric6a2_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a3_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a3_value DROP CONSTRAINT IF EXISTS metric6a3_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a3_value ADD CONSTRAINT metric6a3_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a3_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a3_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a3_value DROP CONSTRAINT IF EXISTS metric6a3_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a3_value ADD CONSTRAINT metric6a3_value_fkey FOREIGN KEY (metric6a3_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a4_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a4_value DROP CONSTRAINT IF EXISTS metric6a4_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a4_value ADD CONSTRAINT metric6a4_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a4_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a4_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a4_value DROP CONSTRAINT IF EXISTS metric6a4_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a4_value ADD CONSTRAINT metric6a4_value_fkey FOREIGN KEY (metric6a4_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a5_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a5_value DROP CONSTRAINT IF EXISTS metric6a5_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a5_value ADD CONSTRAINT metric6a5_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a5_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a5_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a5_value DROP CONSTRAINT IF EXISTS metric6a5_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a5_value ADD CONSTRAINT metric6a5_value_fkey FOREIGN KEY (metric6a5_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a6_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a6_value DROP CONSTRAINT IF EXISTS metric6a6_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a6_value ADD CONSTRAINT metric6a6_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a6_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a6_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a6_value DROP CONSTRAINT IF EXISTS metric6a6_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a6_value ADD CONSTRAINT metric6a6_value_fkey FOREIGN KEY (metric6a6_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a7_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a7_value DROP CONSTRAINT IF EXISTS metric6a7_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a7_value ADD CONSTRAINT metric6a7_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6a7_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a7_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a7_value DROP CONSTRAINT IF EXISTS metric6a7_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6a7_value ADD CONSTRAINT metric6a7_value_fkey FOREIGN KEY (metric6a7_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6b_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6b_value DROP CONSTRAINT IF EXISTS metric6b_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6b_value ADD CONSTRAINT metric6b_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6b_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6b_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6b_value DROP CONSTRAINT IF EXISTS metric6b_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6b_value ADD CONSTRAINT metric6b_value_fkey FOREIGN KEY (metric6b_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6c_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6c_value DROP CONSTRAINT IF EXISTS metric6c_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6c_value ADD CONSTRAINT metric6c_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6c_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6c_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6c_value DROP CONSTRAINT IF EXISTS metric6c_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6c_value ADD CONSTRAINT metric6c_value_fkey FOREIGN KEY (metric6c_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d1_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d1_value DROP CONSTRAINT IF EXISTS metric6d1_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d1_value ADD CONSTRAINT metric6d1_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6d1_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d1_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d1_value DROP CONSTRAINT IF EXISTS metric6d1_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6d1_value ADD CONSTRAINT metric6d1_value_fkey FOREIGN KEY (metric6d1_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d2_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d2_value DROP CONSTRAINT IF EXISTS metric6d2_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d2_value ADD CONSTRAINT metric6d2_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6d2_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d2_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d2_value DROP CONSTRAINT IF EXISTS metric6d2_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6d2_value ADD CONSTRAINT metric6d2_value_fkey FOREIGN KEY (metric6d2_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d3_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d3_value DROP CONSTRAINT IF EXISTS metric6d3_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d3_value ADD CONSTRAINT metric6d3_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6d3_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d3_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d3_value DROP CONSTRAINT IF EXISTS metric6d3_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6d3_value ADD CONSTRAINT metric6d3_value_fkey FOREIGN KEY (metric6d3_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d4_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d4_value DROP CONSTRAINT IF EXISTS metric6d4_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d4_value ADD CONSTRAINT metric6d4_id_fkey FOREIGN KEY (oram_id,selection)
REFERENCES wetland_census.metric6d4_norm (oram_id,selection) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d4_value_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d4_value DROP CONSTRAINT IF EXISTS metric6d4_value_fkey CASCADE;
ALTER TABLE wetland_census.metric6d4_value ADD CONSTRAINT metric6d4_value_fkey FOREIGN KEY (metric6d4_value,lookup_id)
REFERENCES wetland_census.oram_score_lookup_all (value,lookup_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_plant_community_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_plant_community_norm DROP CONSTRAINT IF EXISTS cm_wetland_plant_community_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_plant_community_norm ADD CONSTRAINT cm_wetland_plant_community_norm_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_water_flow_path_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_water_flow_path DROP CONSTRAINT IF EXISTS cm_wetland_water_flow_path_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_water_flow_path ADD CONSTRAINT cm_wetland_water_flow_path_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: poly_id_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_poly_id_norm DROP CONSTRAINT IF EXISTS poly_id_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.oram_poly_id_norm ADD CONSTRAINT poly_id_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: oram_to_mapping_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_poly_id_norm DROP CONSTRAINT IF EXISTS oram_to_mapping_fkey CASCADE;
ALTER TABLE wetland_census.oram_poly_id_norm ADD CONSTRAINT oram_to_mapping_fkey FOREIGN KEY (oram_id,polygon_id)
REFERENCES wetland_census.oram_mapping_pkeys (oram_id,polygon_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: reservation_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_reservation_norm DROP CONSTRAINT IF EXISTS reservation_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.oram_reservation_norm ADD CONSTRAINT reservation_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_classification_coordinates_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_coordinates DROP CONSTRAINT IF EXISTS cm_wetland_classification_coordinates_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_coordinates ADD CONSTRAINT cm_wetland_classification_coordinates_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_classification_coordinates_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_geometry DROP CONSTRAINT IF EXISTS cm_wetland_classification_coordinates_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_geometry ADD CONSTRAINT cm_wetland_classification_coordinates_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_classification_notes_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_notes DROP CONSTRAINT IF EXISTS cm_wetland_classification_notes_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_notes ADD CONSTRAINT cm_wetland_classification_notes_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_classification_polygon_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_polygon_id DROP CONSTRAINT IF EXISTS cm_wetland_classification_polygon_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_polygon_id ADD CONSTRAINT cm_wetland_classification_polygon_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_classification_recorder_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_recorder DROP CONSTRAINT IF EXISTS cm_wetland_classification_recorder_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_recorder ADD CONSTRAINT cm_wetland_classification_recorder_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_classification_reservation_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_classification_reservation DROP CONSTRAINT IF EXISTS cm_wetland_classification_reservation_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_classification_reservation ADD CONSTRAINT cm_wetland_classification_reservation_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_cowardin_special_modifier_other_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_cowardin_special_modifier_other DROP CONSTRAINT IF EXISTS cm_wetland_cowardin_special_modifier_other_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_cowardin_special_modifier_other ADD CONSTRAINT cm_wetland_cowardin_special_modifier_other_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_water_flow_path_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_dominant_species DROP CONSTRAINT IF EXISTS cm_wetland_water_flow_path_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_dominant_species ADD CONSTRAINT cm_wetland_water_flow_path_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_photos_caption_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_photos_caption_norm DROP CONSTRAINT IF EXISTS cm_wetland_photos_caption_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_photos_caption_norm ADD CONSTRAINT cm_wetland_photos_caption_norm_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_photos_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_photos_norm DROP CONSTRAINT IF EXISTS cm_wetland_photos_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_photos_norm ADD CONSTRAINT cm_wetland_photos_norm_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_photos_url_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_photos_url_norm DROP CONSTRAINT IF EXISTS cm_wetland_photos_url_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_photos_url_norm ADD CONSTRAINT cm_wetland_photos_url_norm_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: cm_wetland_plant_community_other_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.cm_wetland_plant_community_other DROP CONSTRAINT IF EXISTS cm_wetland_plant_community_other_id_fkey CASCADE;
ALTER TABLE wetland_census.cm_wetland_plant_community_other ADD CONSTRAINT cm_wetland_plant_community_other_id_fkey FOREIGN KEY (classification_id)
REFERENCES wetland_census.cm_wetland_classification_id (classification_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: hydro_disturbances_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.hydro_disturbances_norm DROP CONSTRAINT IF EXISTS hydro_disturbances_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.hydro_disturbances_norm ADD CONSTRAINT hydro_disturbances_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric1_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric1_norm DROP CONSTRAINT IF EXISTS metric1_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric1_norm ADD CONSTRAINT metric1_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric2a_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric2a_norm DROP CONSTRAINT IF EXISTS metric2a_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric2a_norm ADD CONSTRAINT metric2a_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric2b_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric2b_norm DROP CONSTRAINT IF EXISTS metric2b_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric2b_norm ADD CONSTRAINT metric2b_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3a_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3a_norm DROP CONSTRAINT IF EXISTS metric3a_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3a_norm ADD CONSTRAINT metric3a_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3b_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3b_norm DROP CONSTRAINT IF EXISTS metric3b_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3b_norm ADD CONSTRAINT metric3b_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3c_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3c_norm DROP CONSTRAINT IF EXISTS metric3c_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3c_norm ADD CONSTRAINT metric3c_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3d_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3d_norm DROP CONSTRAINT IF EXISTS metric3d_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3d_norm ADD CONSTRAINT metric3d_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric3e_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric3e_norm DROP CONSTRAINT IF EXISTS metric3e_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric3e_norm ADD CONSTRAINT metric3e_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4a_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4a_norm DROP CONSTRAINT IF EXISTS metric4a_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric4a_norm ADD CONSTRAINT metric4a_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4b_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4b_norm DROP CONSTRAINT IF EXISTS metric4b_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric4b_norm ADD CONSTRAINT metric4b_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric4c_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric4c_norm DROP CONSTRAINT IF EXISTS metric4c_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric4c_norm ADD CONSTRAINT metric4c_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric5_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric5_norm DROP CONSTRAINT IF EXISTS metric5_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric5_norm ADD CONSTRAINT metric5_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a1_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a1_norm DROP CONSTRAINT IF EXISTS metric6a1_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a1_norm ADD CONSTRAINT metric6a1_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a2_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a2_norm DROP CONSTRAINT IF EXISTS metric6a2_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a2_norm ADD CONSTRAINT metric6a2_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a3_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a3_norm DROP CONSTRAINT IF EXISTS metric6a3_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a3_norm ADD CONSTRAINT metric6a3_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a4_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a4_norm DROP CONSTRAINT IF EXISTS metric6a4_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a4_norm ADD CONSTRAINT metric6a4_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a5_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a5_norm DROP CONSTRAINT IF EXISTS metric6a5_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a5_norm ADD CONSTRAINT metric6a5_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a6_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a6_norm DROP CONSTRAINT IF EXISTS metric6a6_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a6_norm ADD CONSTRAINT metric6a6_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6a7_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6a7_norm DROP CONSTRAINT IF EXISTS metric6a7_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6a7_norm ADD CONSTRAINT metric6a7_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6b_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6b_norm DROP CONSTRAINT IF EXISTS metric6b_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6b_norm ADD CONSTRAINT metric6b_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6c_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6c_norm DROP CONSTRAINT IF EXISTS metric6c_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6c_norm ADD CONSTRAINT metric6c_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d1_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d1_norm DROP CONSTRAINT IF EXISTS metric6d1_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d1_norm ADD CONSTRAINT metric6d1_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d2_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d2_norm DROP CONSTRAINT IF EXISTS metric6d2_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d2_norm ADD CONSTRAINT metric6d2_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d3_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d3_norm DROP CONSTRAINT IF EXISTS metric6d3_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d3_norm ADD CONSTRAINT metric6d3_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: metric6d4_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.metric6d4_norm DROP CONSTRAINT IF EXISTS metric6d4_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.metric6d4_norm ADD CONSTRAINT metric6d4_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: oram_notes_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_notes DROP CONSTRAINT IF EXISTS oram_notes_fkey CASCADE;
ALTER TABLE wetland_census.oram_notes ADD CONSTRAINT oram_notes_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: oram_photos_caption_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_photos_caption_norm DROP CONSTRAINT IF EXISTS oram_photos_caption_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.oram_photos_caption_norm ADD CONSTRAINT oram_photos_caption_norm_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: oram_photos_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_photos_norm DROP CONSTRAINT IF EXISTS oram_photos_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.oram_photos_norm ADD CONSTRAINT oram_photos_norm_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: oram_photos_url_norm_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_photos_url_norm DROP CONSTRAINT IF EXISTS oram_photos_url_norm_id_fkey CASCADE;
ALTER TABLE wetland_census.oram_photos_url_norm ADD CONSTRAINT oram_photos_url_norm_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: oram_recorder_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.oram_recorder_norm DROP CONSTRAINT IF EXISTS oram_recorder_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.oram_recorder_norm ADD CONSTRAINT oram_recorder_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: substrate_disturbances_oram_id_fkey | type: CONSTRAINT --
-- ALTER TABLE wetland_census.substrate_disturbances_norm DROP CONSTRAINT IF EXISTS substrate_disturbances_oram_id_fkey CASCADE;
ALTER TABLE wetland_census.substrate_disturbances_norm ADD CONSTRAINT substrate_disturbances_oram_id_fkey FOREIGN KEY (oram_id)
REFERENCES wetland_census.oram_id (oram_id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --


