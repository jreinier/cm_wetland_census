--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.3

-- Started on 2017-02-22 10:30:26

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 29 (class 2615 OID 652049)
-- Name: wetland; Type: SCHEMA; Schema: -; Owner: jreinier
--

CREATE SCHEMA wetland;


ALTER SCHEMA wetland OWNER TO jreinier;

SET search_path = wetland, pg_catalog;

--
-- TOC entry 2009 (class 1255 OID 652050)
-- Name: change_trigger(); Type: FUNCTION; Schema: wetland; Owner: postgres
--

CREATE FUNCTION change_trigger() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION wetland.change_trigger() OWNER TO postgres;

--
-- TOC entry 2010 (class 1255 OID 652051)
-- Name: classification_upsert(); Type: FUNCTION; Schema: wetland; Owner: postgres
--

CREATE FUNCTION classification_upsert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
WITH

class_landscape AS (SELECT fulcrum_id, NULLIF (split_part(landscape_position, ',', 1), '') AS landscape_position, NULLIF (split_part(landscape_position, ',', 2), '') AS modifier_one, NULLIF (split_part(landscape_position, ',', 3), '') AS modifier_two, NULLIF (split_part(landscape_position, ',', 4), '') AS modifier_three FROM wetland.wetland_classification),

class_landform AS (SELECT fulcrum_id, inland_landform FROM wetland.wetland_classification),
class_waterflow AS (SELECT fulcrum_id, water_flow_path FROM wetland.wetland_classification),

class_llww_modifiers AS (SELECT fulcrum_id, NULLIF (split_part(llww_modifiers, ',', 1), '') AS mod_one, NULLIF (split_part(llww_modifiers, ',', 2), '') AS mod_two, NULLIF (split_part(llww_modifiers, ',', 3), '') AS mod_three, NULLIF (split_part(llww_modifiers, ',', 4), '') AS mod_four, NULLIF (split_part(llww_modifiers, ',', 5), '') AS mod_five FROM wetland.wetland_classification),

class_cowardin AS (SELECT fulcrum_id, NULLIF (split_part(cowardin_classification, ',', 1), '') AS system, NULLIF (split_part(cowardin_classification, ',', 2), '') AS class, NULLIF (split_part(cowardin_classification, ',', 3), '') AS subclass FROM wetland.wetland_classification),

class_cowardin_special AS (SELECT fulcrum_id, NULLIF (split_part(cowardin_special_modifier, ',', 1), '') AS mod_one, NULLIF (split_part(cowardin_special_modifier, ',', 2), '') AS mod_two, NULLIF (split_part(cowardin_special_modifier, ',', 3), '') AS mod_three, NULLIF (split_part(cowardin_special_modifier, ',', 4), '') AS mod_four, NULLIF (split_part(cowardin_special_modifier, ',', 5), '') AS mod_five, NULLIF (split_part(cowardin_special_modifier, ',', 6), '') AS mod_six FROM wetland.wetland_classification),

class_cowardin_water AS (SELECT fulcrum_id, cowardin_water_regime FROM wetland.wetland_classification),

class_plant_community AS (SELECT fulcrum_id, NULLIF (split_part(plant_community, ',', 1), '') AS plant_community, NULLIF (split_part(plant_community, ',', 2), '') AS modifier_one, NULLIF (split_part(plant_community, ',', 3), '') AS modifier_two, NULLIF (split_part(plant_community, ',', 4), '') AS modifier_three FROM wetland.wetland_classification),


ins1 AS (INSERT INTO wetland.classification_id SELECT polygon_id, reservation, classification_level, fulcrum_id FROM wetland.wetland_classification
ON CONFLICT (fulcrum_id) DO UPDATE SET 
polygon_number = EXCLUDED.polygon_number,
reservation = EXCLUDED.reservation,
classification_level = EXCLUDED.classification_level),


ins2 AS (INSERT INTO wetland.landscape_position SELECT fulcrum_id, landscape_position, modifier_one, modifier_two, modifier_three FROM class_landscape
ON CONFLICT (fulcrum_id) DO UPDATE SET
landscape_position = EXCLUDED.landscape_position,
modifier_one = EXCLUDED.modifier_one,
modifier_two = EXCLUDED.modifier_two,
modifier_three = EXCLUDED.modifier_three),
	
ins3 AS (INSERT INTO wetland.inland_landform SELECT fulcrum_id, inland_landform FROM class_landform
ON CONFLICT (fulcrum_id) DO UPDATE SET
inland_landform = EXCLUDED.inland_landform),
	
ins4 AS (INSERT INTO wetland.water_flow_path SELECT fulcrum_id, water_flow_path FROM class_waterflow
ON CONFLICT (fulcrum_id) DO UPDATE SET
water_flow_path = EXCLUDED.water_flow_path),
	
ins5 AS (INSERT INTO wetland.llww_modifiers SELECT fulcrum_id, mod_one, mod_two, mod_three, mod_four, mod_five FROM class_llww_modifiers
ON CONFLICT (fulcrum_id) DO UPDATE SET
mod_one = EXCLUDED.mod_one,
mod_two = EXCLUDED.mod_two,
mod_three = EXCLUDED.mod_three,
mod_four = EXCLUDED.mod_four,
mod_five = EXCLUDED.mod_five),
	
ins6 AS (INSERT INTO wetland.cowardin_classification SELECT fulcrum_id, system, class, subclass FROM class_cowardin
ON CONFLICT (fulcrum_id) DO UPDATE SET
system = EXCLUDED.system,
class = EXCLUDED.class,
subclass = EXCLUDED.subclass),
	
ins7 AS (INSERT INTO wetland.cowardin_water_regime SELECT fulcrum_id, cowardin_water_regime FROM class_cowardin_water
ON CONFLICT (fulcrum_id) DO UPDATE SET
cowardin_water_regime = EXCLUDED.cowardin_water_regime),
	
ins8 AS (INSERT INTO wetland.cowardin_special_modifiers SELECT fulcrum_id, mod_one, mod_two, mod_three, mod_four, mod_five, mod_six FROM class_cowardin_special
ON CONFLICT (fulcrum_id) DO UPDATE SET
mod_one = EXCLUDED.mod_one,
mod_two = EXCLUDED.mod_two,
mod_three = EXCLUDED.mod_three,
mod_four = EXCLUDED.mod_four,
mod_five = EXCLUDED.mod_five,
mod_six = EXCLUDED.mod_six)
	
INSERT INTO wetland.plant_community_classification SELECT fulcrum_id, plant_community, modifier_one, modifier_two, modifier_three FROM class_plant_community
ON CONFLICT (fulcrum_id) DO UPDATE SET
plant_community = EXCLUDED.plant_community,
modifier_one = EXCLUDED.modifier_one,
modifier_two = EXCLUDED.modifier_two,
modifier_three = EXCLUDED.modifier_three
	
;	
	
RETURN NEW;
END $$;


ALTER FUNCTION wetland.classification_upsert() OWNER TO postgres;

--
-- TOC entry 2011 (class 1255 OID 652052)
-- Name: oram_upsert(); Type: FUNCTION; Schema: wetland; Owner: postgres
--

CREATE FUNCTION oram_upsert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
WITH poly_split AS (SELECT reservation, regexp_split_to_table(polygon_id, ',') AS polygon_number, fulcrum_id FROM wetland.oram_v2),

metric2b_split AS(
SELECT fulcrum_id, NULLIF (split_part(m2b_surrounding_land_use,',',1), '') AS m2b_surrounding_land_use1, NULLIF (split_part(m2b_surrounding_land_use,',',2), '') AS m2b_surrounding_land_use2 FROM wetland.oram_v2
),
metric3a_split AS(
SELECT fulcrum_id, NULLIF (split_part(m3a_sources_of_water,',',1), '') AS m3a_sources_of_water1, NULLIF (split_part(m3a_sources_of_water,',',2), '') AS m3a_sources_of_water2, NULLIF (split_part(m3a_sources_of_water,',',3), '') AS m3a_sources_of_water3, NULLIF (split_part(m3a_sources_of_water,',',4), '') AS m3a_sources_of_water4, NULLIF (split_part(m3a_sources_of_water,',',5), '') AS m3a_sources_of_water5 FROM wetland.oram_v2
),
metric3b_split AS(
SELECT fulcrum_id, NULLIF (split_part(m3b_connectivity,',',1), '') AS m3b_connectivity1, NULLIF (split_part(m3b_connectivity,',',2), '') AS m3b_connectivity2, NULLIF (split_part(m3b_connectivity,',',3), '') AS m3b_connectivity3, NULLIF (split_part(m3b_connectivity,',',4), '') AS m3b_connectivity4 FROM wetland.oram_v2
),
metric3d_split AS(
SELECT fulcrum_id, NULLIF (split_part(m3d_duration_inundation_saturation,',',1), '') AS m3d_duration_inundation_saturation1, NULLIF (split_part(m3d_duration_inundation_saturation,',',2), '') AS m3d_duration_inundation_saturation2 FROM wetland.oram_v2
),
metric3e_split AS(
SELECT fulcrum_id, NULLIF (split_part(m3e_modifications_to_hydrologic_regime,',',1), '') AS m3e_modifications_to_hydrologic_regime1, NULLIF (split_part(m3e_modifications_to_hydrologic_regime,',',2), '') AS m3e_modifications_to_hydrologic_regime2 FROM wetland.oram_v2
),
disturbances_hydro_split AS(
SELECT fulcrum_id, NULLIF (split_part(disturbances_hydro,',',1), '') AS disturbances_hydro1, NULLIF (split_part(disturbances_hydro,',',2), '') AS disturbances_hydro2, NULLIF (split_part(disturbances_hydro,',',3), '') AS disturbances_hydro3, NULLIF (split_part(disturbances_hydro,',',4), '') AS disturbances_hydro4, NULLIF (split_part(disturbances_hydro,',',5), '') AS disturbances_hydro5, NULLIF (split_part(disturbances_hydro,',',6), '') AS disturbances_hydro6, NULLIF (split_part(disturbances_hydro,',',7), '') AS disturbances_hydro7, NULLIF (split_part(disturbances_hydro,',',8), '') AS disturbances_hydro8, NULLIF (split_part(disturbances_hydro,',',9), '') AS disturbances_hydro9, NULLIF (split_part(disturbances_hydro,',',10), '') AS disturbances_hydro10 FROM wetland.oram_v2
),
metric4a_split AS(
SELECT fulcrum_id, NULLIF (split_part(m4a_substrate_disturbance,',',1), '') AS m4a_substrate_disturbance1, NULLIF (split_part(m4a_substrate_disturbance,',',2), '') AS m4a_substrate_disturbance2 FROM wetland.oram_v2
),
metric4c_split AS(
SELECT fulcrum_id, NULLIF (split_part(m4c_habitat_alteration,',',1), '') AS m4c_habitat_alteration1, NULLIF (split_part(m4c_habitat_alteration,',',2), '') AS m4c_habitat_alteration2 FROM wetland.oram_v2
),
disturbances_substrate_split AS(
SELECT fulcrum_id, NULLIF (split_part(disturbances_substrate,',',1), '') AS disturbances_substrate1, NULLIF (split_part(disturbances_substrate,',',2), '') AS disturbances_substrate2, NULLIF (split_part(disturbances_substrate,',',3), '') AS disturbances_substrate3, NULLIF (split_part(disturbances_substrate,',',4), '') AS disturbances_substrate4, NULLIF (split_part(disturbances_substrate,',',5), '') AS disturbances_substrate5, NULLIF (split_part(disturbances_substrate,',',6), '') AS disturbances_substrate6, NULLIF (split_part(disturbances_substrate,',',7), '') AS disturbances_substrate7, NULLIF (split_part(disturbances_substrate,',',8), '') AS disturbances_substrate8, NULLIF (split_part(disturbances_substrate,',',9), '') AS disturbances_substrate9, NULLIF (split_part(disturbances_substrate,',',10), '') AS disturbances_substrate10, NULLIF (split_part(disturbances_substrate,',',11), '') AS disturbances_substrate11, NULLIF (split_part(disturbances_substrate,',',12), '') AS disturbances_substrate12 FROM wetland.oram_v2
),
metric5_split AS(
SELECT fulcrum_id, NULLIF (split_part(m5_special_wetlands,',',1), '') AS m5_special_wetlands1, NULLIF (split_part(m5_special_wetlands,',',2), '') AS m5_special_wetlands2 FROM wetland.oram_v2
),

joined AS ( 
SELECT a.fulcrum_id, a.m1_wetland_area, a.m2a_upland_buffer_width, b.m2b_surrounding_land_use1, b.m2b_surrounding_land_use2, c.m3a_sources_of_water1, c.m3a_sources_of_water2, c.m3a_sources_of_water3, c.m3a_sources_of_water4, c.m3a_sources_of_water5, d.m3b_connectivity1, d.m3b_connectivity2, d.m3b_connectivity3, d.m3b_connectivity4, a.m3c_maximum_water_depth, e.m3d_duration_inundation_saturation1, e.m3d_duration_inundation_saturation2, f.m3e_modifications_to_hydrologic_regime1, f.m3e_modifications_to_hydrologic_regime2, i.disturbances_hydro1, i.disturbances_hydro2, i.disturbances_hydro3, i.disturbances_hydro4, i.disturbances_hydro5, i.disturbances_hydro6, i.disturbances_hydro7, i.disturbances_hydro8, i.disturbances_hydro9, i.disturbances_hydro10, g.m4a_substrate_disturbance1, g.m4a_substrate_disturbance2, a.m4b_habitat_development, h.m4c_habitat_alteration1, h.m4c_habitat_alteration2, j.disturbances_substrate1, j.disturbances_substrate2, j.disturbances_substrate3, j.disturbances_substrate4, j.disturbances_substrate5, j.disturbances_substrate6, j.disturbances_substrate7, j.disturbances_substrate8, j.disturbances_substrate9, j.disturbances_substrate10, j.disturbances_substrate11, j.disturbances_substrate12, a.disturbances_substrate_other, k.m5_special_wetlands1, k.m5_special_wetlands2, a.m6a_aquatic_bed, a.m6a_emergent, a.m6a_shrub, a.m6a_forest, a.m6a_mudflats, a.m6a_open_water, a.m6a_other, a.m6b_horizontal_plan_view_interspersion, a.m6c_coverage_of_invasive_plants, a.m6d_microtopography_vegetation_hummuckstussuck, a.m6d_microtopography_course_woody_debris_15cm_6in, a.m6d_microtopography_standing_dead_25cm_10in_dbh, a.m6d_microtopography_amphibian_breeding_pools FROM wetland.oram_v2 a LEFT JOIN metric2b_split b ON a.fulcrum_id = b.fulcrum_id LEFT JOIN metric3a_split c ON a.fulcrum_id = c.fulcrum_id LEFT JOIN metric3b_split d ON a.fulcrum_id = d.fulcrum_id LEFT JOIN metric3d_split e ON a.fulcrum_id = e.fulcrum_id LEFT JOIN metric3e_split f ON a.fulcrum_id = f.fulcrum_id LEFT JOIN metric4a_split g ON a.fulcrum_id = g.fulcrum_id LEFT JOIN metric4c_split h ON a.fulcrum_id = h.fulcrum_id LEFT JOIN disturbances_hydro_split i ON a.fulcrum_id = i.fulcrum_id LEFT JOIN disturbances_substrate_split j ON a.fulcrum_id = j.fulcrum_id LEFT JOIN metric5_split k ON a.fulcrum_id = k.fulcrum_id),


id_insert AS (INSERT INTO wetland.oram_ids SELECT reservation, polygon_number, fulcrum_id FROM poly_split
ON CONFLICT (reservation, polygon_number, fulcrum_id) DO NOTHING),

metric_upsert AS (INSERT INTO wetland.oram_metrics SELECT * FROM joined ON CONFLICT (fulcrum_id) DO UPDATE SET

  metric1_selection = EXCLUDED.metric1_selection,
  metric2a_selection = EXCLUDED.metric2a_selection,
  metric2b_selection1 = EXCLUDED.metric2b_selection1,
  metric2b_selection2 = EXCLUDED.metric2b_selection2,
  metric3a_selection1 = EXCLUDED.metric3a_selection1,
  metric3a_selection2 = EXCLUDED.metric3a_selection2,
  metric3a_selection3 = EXCLUDED.metric3a_selection3,
  metric3a_selection4 = EXCLUDED.metric3a_selection4,
  metric3a_selection5 = EXCLUDED.metric3a_selection5,
  metric3b_selection1 = EXCLUDED.metric3b_selection1,
  metric3b_selection2 = EXCLUDED.metric3b_selection2,
  metric3b_selection3 = EXCLUDED.metric3b_selection3,
  metric3b_selection4 = EXCLUDED.metric3b_selection4,
  metric3c_selection = EXCLUDED.metric3c_selection,
  metric3d_selection1 = EXCLUDED.metric3d_selection1,
  metric3d_selection2 = EXCLUDED.metric3d_selection2,
  metric3e_selection1 = EXCLUDED.metric3e_selection1,
  metric3e_selection2 = EXCLUDED.metric3e_selection2,
  hydro_disturbance1 = EXCLUDED.hydro_disturbance1,
  hydro_disturbance2 = EXCLUDED.hydro_disturbance2,
  hydro_disturbance3 = EXCLUDED.hydro_disturbance3,
  hydro_disturbance4 = EXCLUDED.hydro_disturbance4,
  hydro_disturbance5 = EXCLUDED.hydro_disturbance5,
  hydro_disturbance6 = EXCLUDED.hydro_disturbance6,
  hydro_disturbance7 = EXCLUDED.hydro_disturbance7,
  hydro_disturbance8 = EXCLUDED.hydro_disturbance8,
  hydro_disturbance9 = EXCLUDED.hydro_disturbance9,
  hydro_disturbance_other = EXCLUDED.hydro_disturbance_other,
  metric4a_selection1 = EXCLUDED.metric4a_selection1,
  metric4a_selection2 = EXCLUDED.metric4a_selection2,
  metric4b_selection = EXCLUDED.metric4b_selection,
  metric4c_selection1 = EXCLUDED.metric4c_selection1,
  metric4c_selection2 = EXCLUDED.metric4c_selection2,
  habitat_disturbance1 = EXCLUDED.habitat_disturbance1,
  habitat_disturbance2 = EXCLUDED.habitat_disturbance2,
  habitat_disturbance3 = EXCLUDED.habitat_disturbance3,
  habitat_disturbance4 = EXCLUDED.habitat_disturbance4,
  habitat_disturbance5 = EXCLUDED.habitat_disturbance5,
  habitat_disturbance6 = EXCLUDED.habitat_disturbance6,
  habitat_disturbance7 = EXCLUDED.habitat_disturbance7,
  habitat_disturbance8 = EXCLUDED.habitat_disturbance8,
  habitat_disturbance9 = EXCLUDED.habitat_disturbance9,
  habitat_disturbance10 = EXCLUDED.habitat_disturbance10,
  habitat_disturbance11 = EXCLUDED.habitat_disturbance11,
  habitat_disturbance12 = EXCLUDED.habitat_disturbance12,
  habitat_disturbance_other = EXCLUDED.habitat_disturbance_other,
  metric5_selection1 = EXCLUDED.metric5_selection1,
  metric5_selection2 = EXCLUDED.metric5_selection2,
  metric6a1_aquatic_bed = EXCLUDED.metric6a1_aquatic_bed,
  metric6a2_emergent = EXCLUDED.metric6a2_emergent,
  metric6a3_shrub = EXCLUDED.metric6a3_shrub,
  metric6a4_forest = EXCLUDED.metric6a4_forest,
  metric6a5_mudflats = EXCLUDED.metric6a5_mudflats,
  metric6a6_open_water = EXCLUDED.metric6a6_open_water,
  metric6a_other1 = EXCLUDED.metric6a_other1,
  metric6b_selection = EXCLUDED.metric6b_selection,
  metric6c_selection = EXCLUDED.metric6c_selection,
  metric6d1_selection = EXCLUDED.metric6d1_selection,
  metric6d2_selection = EXCLUDED.metric6d2_selection,
  metric6d3_selection = EXCLUDED.metric6d3_selection,
  metric6d4_selection = EXCLUDED.metric6d4_selection
  )


DELETE FROM wetland.oram_ids WHERE fulcrum_id NOT IN (SELECT DISTINCT fulcrum_id FROM wetland.oram_v2)

;

RETURN NEW;
END $$;


ALTER FUNCTION wetland.oram_upsert() OWNER TO postgres;

--
-- TOC entry 2012 (class 1255 OID 652055)
-- Name: refresh_wetland_materialized_views(); Type: FUNCTION; Schema: wetland; Owner: jreinier
--

CREATE FUNCTION refresh_wetland_materialized_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram WITH DATA;
  REFRESH MATERIALIZED VIEW wwetland.cm_wetland_class_oram_avg WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_max WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_avg_landform_updated WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_avg_landform_updated_merge WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_avg_landform_updated_merge_simplified WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_landform_updated WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_landform_updated_merge WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_landform_updated_merge_simplified WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_max_landform_updated WITH DATA;
  REFRESH MATERIALIZED VIEW rwetland.cm_wetland_class_oram_max_landform_updated_merge WITH DATA;
  REFRESH MATERIALIZED VIEW wetland.cm_wetland_class_oram_max_landform_updated_merge_simplified WITH DATA;
END;
$$;


ALTER FUNCTION wetland.refresh_wetland_materialized_views() OWNER TO jreinier;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 712 (class 1259 OID 652062)
-- Name: classification_dominant_species; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE classification_dominant_species (
    fulcrum_id character varying(100) NOT NULL,
    sp1 text,
    sp2 text,
    sp3 text,
    sp4 text,
    sp5 text,
    sp6 text,
    sp7 text,
    sp8 text,
    sp9 text,
    sp10 text
);


ALTER TABLE classification_dominant_species OWNER TO jreinier;

--
-- TOC entry 713 (class 1259 OID 652074)
-- Name: classification_id; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE classification_id (
    polygon_number text,
    reservation text,
    classification_level text,
    fulcrum_id character varying(100) NOT NULL
);


ALTER TABLE classification_id OWNER TO jreinier;

--
-- TOC entry 714 (class 1259 OID 652092)
-- Name: cm_oram_data; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE cm_oram_data (
    fulcrum_id text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by text,
    updated_by text,
    system_created_at timestamp without time zone,
    system_updated_at timestamp without time zone,
    version bigint,
    status text,
    project text,
    assigned_to text,
    latitude numeric,
    longitude numeric,
    geometry public.geometry,
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
    photos_url text
);


ALTER TABLE cm_oram_data OWNER TO postgres;

--
-- TOC entry 720 (class 1259 OID 652140)
-- Name: cm_wetland_classification_to_fulcrum_format; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE cm_wetland_classification_to_fulcrum_format (
    fulcrum_id text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by text,
    updated_by text,
    system_created_at timestamp without time zone,
    system_updated_at timestamp without time zone,
    version bigint,
    status text,
    project text,
    assigned_to text,
    latitude numeric,
    longitude numeric,
    eight_digit_huc text,
    twelve_digit_huc text,
    geometry public.geometry,
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
    classification_id bigint NOT NULL
);


ALTER TABLE cm_wetland_classification_to_fulcrum_format OWNER TO postgres;

--
-- TOC entry 715 (class 1259 OID 652104)
-- Name: cm_wetlands; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE cm_wetlands (
    polygon_number text NOT NULL,
    reservation text NOT NULL,
    geom public.geometry(MultiPolygon),
    area_acres numeric,
    poly_type character varying(20)
);


ALTER TABLE cm_wetlands OWNER TO jreinier;

--
-- TOC entry 721 (class 1259 OID 652146)
-- Name: cowardin_classification; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE cowardin_classification (
    fulcrum_id character varying(100) NOT NULL,
    system text,
    class text,
    subclass text
);


ALTER TABLE cowardin_classification OWNER TO jreinier;

--
-- TOC entry 722 (class 1259 OID 652152)
-- Name: cowardin_special_modifiers; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE cowardin_special_modifiers (
    fulcrum_id character varying(100) NOT NULL,
    mod_one text,
    mod_two text,
    mod_three text,
    mod_four text,
    mod_five text,
    mod_six text
);


ALTER TABLE cowardin_special_modifiers OWNER TO jreinier;

--
-- TOC entry 723 (class 1259 OID 652158)
-- Name: cowardin_water_regime; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE cowardin_water_regime (
    fulcrum_id character varying(100) NOT NULL,
    cowardin_water_regime text
);


ALTER TABLE cowardin_water_regime OWNER TO jreinier;

--
-- TOC entry 724 (class 1259 OID 652164)
-- Name: inland_landform; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE inland_landform (
    fulcrum_id character varying(100) NOT NULL,
    inland_landform text
);


ALTER TABLE inland_landform OWNER TO jreinier;

--
-- TOC entry 725 (class 1259 OID 652170)
-- Name: landscape_position; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE landscape_position (
    fulcrum_id character varying(100) NOT NULL,
    landscape_position text,
    modifier_one text,
    modifier_two text,
    modifier_three text
);


ALTER TABLE landscape_position OWNER TO jreinier;

--
-- TOC entry 726 (class 1259 OID 652176)
-- Name: llww_modifiers; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE llww_modifiers (
    fulcrum_id character varying(100) NOT NULL,
    mod_one text,
    mod_two text,
    mod_three text,
    mod_four text,
    mod_five text
);


ALTER TABLE llww_modifiers OWNER TO jreinier;

--
-- TOC entry 745 (class 1259 OID 654655)
-- Name: lookup_cowardin_class; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE lookup_cowardin_class (
    class text NOT NULL
);


ALTER TABLE lookup_cowardin_class OWNER TO jreinier;

--
-- TOC entry 746 (class 1259 OID 654668)
-- Name: lookup_cowardin_subclass; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE lookup_cowardin_subclass (
    subclass text NOT NULL
);


ALTER TABLE lookup_cowardin_subclass OWNER TO jreinier;

--
-- TOC entry 744 (class 1259 OID 654629)
-- Name: lookup_cowardin_system; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE lookup_cowardin_system (
    system text NOT NULL
);


ALTER TABLE lookup_cowardin_system OWNER TO jreinier;

--
-- TOC entry 727 (class 1259 OID 652188)
-- Name: oram_ids; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE oram_ids (
    reservation text NOT NULL,
    polygon_number text NOT NULL,
    fulcrum_id character varying(100) NOT NULL
);


ALTER TABLE oram_ids OWNER TO jreinier;

--
-- TOC entry 716 (class 1259 OID 652110)
-- Name: oram_v2; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE oram_v2 (
    fulcrum_id character varying(100) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by text,
    updated_by text,
    system_created_at timestamp without time zone,
    system_updated_at timestamp without time zone,
    version bigint,
    status text,
    project text,
    assigned_to text,
    latitude double precision,
    longitude double precision,
    geometry public.geometry(Point,4326),
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


ALTER TABLE oram_v2 OWNER TO postgres;

--
-- TOC entry 717 (class 1259 OID 652116)
-- Name: oram_metric_values; Type: VIEW; Schema: wetland; Owner: jreinier
--

CREATE VIEW oram_metric_values AS
 WITH metric2b_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m2b_surrounding_land_use, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m2b_surrounding_land_use, ','::text, 2), ''::text) AS selection2
           FROM oram_v2
        ), metric3a_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m3a_sources_of_water, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m3a_sources_of_water, ','::text, 2), ''::text) AS selection2,
            NULLIF(split_part(oram_v2.m3a_sources_of_water, ','::text, 3), ''::text) AS selection3,
            NULLIF(split_part(oram_v2.m3a_sources_of_water, ','::text, 4), ''::text) AS selection4,
            NULLIF(split_part(oram_v2.m3a_sources_of_water, ','::text, 5), ''::text) AS selection5
           FROM oram_v2
        ), metric3b_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m3b_connectivity, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m3b_connectivity, ','::text, 2), ''::text) AS selection2,
            NULLIF(split_part(oram_v2.m3b_connectivity, ','::text, 3), ''::text) AS selection3,
            NULLIF(split_part(oram_v2.m3b_connectivity, ','::text, 4), ''::text) AS selection4
           FROM oram_v2
        ), metric3d_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m3d_duration_inundation_saturation, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m3d_duration_inundation_saturation, ','::text, 2), ''::text) AS selection2
           FROM oram_v2
        ), metric3e_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m3e_modifications_to_hydrologic_regime, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m3e_modifications_to_hydrologic_regime, ','::text, 2), ''::text) AS selection2
           FROM oram_v2
        ), metric4a_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m4a_substrate_disturbance, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m4a_substrate_disturbance, ','::text, 2), ''::text) AS selection2
           FROM oram_v2
        ), metric4c_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m4c_habitat_alteration, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m4c_habitat_alteration, ','::text, 2), ''::text) AS selection2
           FROM oram_v2
        ), metric5_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.m5_special_wetlands, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.m5_special_wetlands, ','::text, 2), ''::text) AS selection2
           FROM oram_v2
        ), disturbances_hydro_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 2), ''::text) AS selection2,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 3), ''::text) AS selection3,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 4), ''::text) AS selection4,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 5), ''::text) AS selection5,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 6), ''::text) AS selection6,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 7), ''::text) AS selection7,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 8), ''::text) AS selection8,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 9), ''::text) AS selection9,
            NULLIF(split_part(oram_v2.disturbances_hydro, ','::text, 10), ''::text) AS selection10
           FROM oram_v2
        ), disturbances_substrate_split AS (
         SELECT oram_v2.fulcrum_id,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 1), ''::text) AS selection1,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 2), ''::text) AS selection2,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 3), ''::text) AS selection3,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 4), ''::text) AS selection4,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 5), ''::text) AS selection5,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 6), ''::text) AS selection6,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 7), ''::text) AS selection7,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 8), ''::text) AS selection8,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 9), ''::text) AS selection9,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 10), ''::text) AS selection10,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 11), ''::text) AS selection11,
            NULLIF(split_part(oram_v2.disturbances_substrate, ','::text, 12), ''::text) AS selection12
           FROM oram_v2
        )
 SELECT a.fulcrum_id,
        CASE a.m1_wetland_area
            WHEN '<0.1 acres (0.04 ha) (0)'::text THEN 0
            WHEN '0.1 to <0.33 acres (0.04 to <0.12 ha) (1)'::text THEN 1
            WHEN '0.3 to <3 acres (0.12 to <1.2 ha) (2)'::text THEN 2
            WHEN '3 to <10 acres (1.2 to <4 ha) (3)'::text THEN 3
            WHEN '10 to <25 acres (4 to <10.1 ha) (4)'::text THEN 4
            WHEN '25 to <50 acres (10.1 to 20.2 ha) (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric1_value,
        CASE a.m2a_upland_buffer_width
            WHEN 'very narrow'::text THEN 0
            WHEN 'narrow'::text THEN 1
            WHEN 'medium'::text THEN 4
            WHEN 'wide'::text THEN 7
            ELSE NULL::integer
        END AS metric2a_value,
        CASE b.selection1
            WHEN 'high'::text THEN 1
            WHEN 'moderately high'::text THEN 3
            WHEN 'low'::text THEN 5
            WHEN 'very low'::text THEN 7
            ELSE NULL::integer
        END AS metric2b1_value,
        CASE b.selection2
            WHEN 'high'::text THEN 1
            WHEN 'moderately high'::text THEN 3
            WHEN 'low'::text THEN 5
            WHEN 'very low'::text THEN 7
            ELSE NULL::integer
        END AS metric2b2_value,
        CASE c.selection1
            WHEN 'Precipitation (1)'::text THEN 1
            WHEN 'Other groundwater (3)'::text THEN 3
            WHEN 'Seasonal or intermittent surface water (3)'::text THEN 3
            WHEN 'Perennial surface water -- lake or stream (5)'::text THEN 5
            WHEN 'High pH groundwater (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric3a1_value,
        CASE c.selection2
            WHEN 'Precipitation (1)'::text THEN 1
            WHEN 'Other groundwater (3)'::text THEN 3
            WHEN 'Seasonal or intermittent surface water (3)'::text THEN 3
            WHEN 'Perennial surface water -- lake or stream (5)'::text THEN 5
            WHEN 'High pH groundwater (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric3a2_value,
        CASE c.selection3
            WHEN 'Precipitation (1)'::text THEN 1
            WHEN 'Other groundwater (3)'::text THEN 3
            WHEN 'Seasonal or intermittent surface water (3)'::text THEN 3
            WHEN 'Perennial surface water -- lake or stream (5)'::text THEN 5
            WHEN 'High pH groundwater (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric3a3_value,
        CASE c.selection4
            WHEN 'Precipitation (1)'::text THEN 1
            WHEN 'Other groundwater (3)'::text THEN 3
            WHEN 'Seasonal or intermittent surface water (3)'::text THEN 3
            WHEN 'Perennial surface water -- lake or stream (5)'::text THEN 5
            WHEN 'High pH groundwater (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric3a4_value,
        CASE c.selection5
            WHEN 'Precipitation (1)'::text THEN 1
            WHEN 'Other groundwater (3)'::text THEN 3
            WHEN 'Seasonal or intermittent surface water (3)'::text THEN 3
            WHEN 'Perennial surface water -- lake or stream (5)'::text THEN 5
            WHEN 'High pH groundwater (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric3a5_value,
        CASE d.selection1
            WHEN 'Part of wetland / upland (e.g. forest) complex (1)'::text THEN 1
            WHEN '100 year flood plain (1)'::text THEN 1
            WHEN 'Between stream / lake and other human use (1)'::text THEN 1
            WHEN 'Part of riparian or upland corridor (1)'::text THEN 1
            ELSE NULL::integer
        END AS metric3b1_value,
        CASE d.selection2
            WHEN 'Part of wetland / upland (e.g. forest) complex (1)'::text THEN 1
            WHEN '100 year flood plain (1)'::text THEN 1
            WHEN 'Between stream / lake and other human use (1)'::text THEN 1
            WHEN 'Part of riparian or upland corridor (1)'::text THEN 1
            ELSE NULL::integer
        END AS metric3b2_value,
        CASE d.selection3
            WHEN 'Part of wetland / upland (e.g. forest) complex (1)'::text THEN 1
            WHEN '100 year flood plain (1)'::text THEN 1
            WHEN 'Between stream / lake and other human use (1)'::text THEN 1
            WHEN 'Part of riparian or upland corridor (1)'::text THEN 1
            ELSE NULL::integer
        END AS metric3b3_value,
        CASE d.selection4
            WHEN 'Part of wetland / upland (e.g. forest) complex (1)'::text THEN 1
            WHEN '100 year flood plain (1)'::text THEN 1
            WHEN 'Between stream / lake and other human use (1)'::text THEN 1
            WHEN 'Part of riparian or upland corridor (1)'::text THEN 1
            ELSE NULL::integer
        END AS metric3b4_value,
        CASE a.m3c_maximum_water_depth
            WHEN '<0.4 m (<15.7 in) (1)'::text THEN 1
            WHEN '0.4 to 0.7 m (15.7 to 27.6 in) (2)'::text THEN 2
            WHEN '>0.7 m (>27.6 in) (3)'::text THEN 3
            ELSE NULL::integer
        END AS metric3c_value,
        CASE e.selection1
            WHEN 'Seasonally saturated in upper 30 cm (12 in) (1)'::text THEN 1
            WHEN 'Seasonally inundated (2)'::text THEN 2
            WHEN 'Regularly inundated/saturated (3)'::text THEN 3
            WHEN 'Semi to permanently inundated/saturated (4)'::text THEN 4
            ELSE NULL::integer
        END AS metric3d1_value,
        CASE e.selection2
            WHEN 'Seasonally saturated in upper 30 cm (12 in) (1)'::text THEN 1
            WHEN 'Seasonally inundated (2)'::text THEN 2
            WHEN 'Regularly inundated/saturated (3)'::text THEN 3
            WHEN 'Semi to permanently inundated/saturated (4)'::text THEN 4
            ELSE NULL::integer
        END AS metric3d2_value,
        CASE f.selection1
            WHEN 'Recent or no recovery (1)'::text THEN 1
            WHEN 'Recovering (3)'::text THEN 3
            WHEN 'Recovered (7)'::text THEN 7
            WHEN 'None or none apparent (12)'::text THEN 12
            ELSE NULL::integer
        END AS metric3e1_value,
        CASE f.selection2
            WHEN 'Recent or no recovery (1)'::text THEN 1
            WHEN 'Recovering (3)'::text THEN 3
            WHEN 'Recovered (7)'::text THEN 7
            WHEN 'None or none apparent (12)'::text THEN 12
            ELSE NULL::integer
        END AS metric3e2_value,
        CASE g.selection1
            WHEN 'Recent or no recovery (1)'::text THEN 1
            WHEN 'Recovering (2)'::text THEN 2
            WHEN 'Recovered (3)'::text THEN 3
            WHEN 'None or none apparent (4)'::text THEN 4
            ELSE NULL::integer
        END AS metric4a1_value,
        CASE g.selection2
            WHEN 'Recent or no recovery (1)'::text THEN 1
            WHEN 'Recovering (2)'::text THEN 2
            WHEN 'Recovered (3)'::text THEN 3
            WHEN 'None or none apparent (4)'::text THEN 4
            ELSE NULL::integer
        END AS metric4a2_value,
        CASE a.m4b_habitat_development
            WHEN 'Poor (1)'::text THEN 1
            WHEN 'Poor to Fair (2)'::text THEN 2
            WHEN 'Fair (3)'::text THEN 3
            WHEN 'Moderately Good (4)'::text THEN 4
            WHEN 'Good (5)'::text THEN 5
            WHEN 'Very Good (6)'::text THEN 6
            WHEN 'Excellent (7)'::text THEN 7
            ELSE NULL::integer
        END AS metric4b_value,
        CASE h.selection1
            WHEN 'Recent or no recovery (1)'::text THEN 1
            WHEN 'Recovering (3)'::text THEN 3
            WHEN 'Recovered (6)'::text THEN 6
            WHEN 'None or none apparent (9)'::text THEN 9
            ELSE NULL::integer
        END AS metric4c1_value,
        CASE h.selection2
            WHEN 'Recent or no recovery (1)'::text THEN 1
            WHEN 'Recovering (3)'::text THEN 3
            WHEN 'Recovered (6)'::text THEN 6
            WHEN 'None or none apparent (9)'::text THEN 9
            ELSE NULL::integer
        END AS metric4c2_value,
        CASE i.selection1
            WHEN 'Category 1 wetland. See question 1 qualitative rating (-10)'::text THEN '-10'::integer
            WHEN 'Mature forested wetland (5)'::text THEN 5
            WHEN 'Bog (10)'::text THEN 10
            WHEN 'Significant migratory songbird/water fowl habitat or usage (10)'::text THEN 10
            WHEN 'Known occurrence state/federal threatened or endangered species (10)'::text THEN 10
            WHEN 'Lake Erie coastal/tributary wetland - restricted hydrology (10)'::text THEN 10
            WHEN 'Lake Erie coastal/tributary wetland - unrestricted hydrology (10)'::text THEN 10
            WHEN 'Relict wet prairies (10)'::text THEN 10
            WHEN 'Lake plain sand prairies (Oak Openings) (10)'::text THEN 10
            WHEN 'Old growth forest (10)'::text THEN 10
            WHEN 'Fen (10)'::text THEN 10
            ELSE NULL::integer
        END AS metric5_value1,
        CASE i.selection2
            WHEN 'Category 1 wetland. See question 1 qualitative rating (-10)'::text THEN '-10'::integer
            WHEN 'Mature forested wetland (5)'::text THEN 5
            WHEN 'Bog (10)'::text THEN 10
            WHEN 'Significant migratory songbird/water fowl habitat or usage (10)'::text THEN 10
            WHEN 'Known occurrence state/federal threatened or endangered species (10)'::text THEN 10
            WHEN 'Lake Erie coastal/tributary wetland - restricted hydrology (10)'::text THEN 10
            WHEN 'Lake Erie coastal/tributary wetland - unrestricted hydrology (10)'::text THEN 10
            WHEN 'Relict wet prairies (10)'::text THEN 10
            WHEN 'Lake plain sand prairies (Oak Openings) (10)'::text THEN 10
            WHEN 'Old growth forest (10)'::text THEN 10
            WHEN 'Fen (10)'::text THEN 10
            ELSE NULL::integer
        END AS metric5_value2,
        CASE a.m6a_aquatic_bed
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a1_value,
        CASE a.m6a_emergent
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a2_value,
        CASE a.m6a_shrub
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a3_value,
        CASE a.m6a_forest
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a4_value,
        CASE a.m6a_mudflats
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a5_value,
        CASE a.m6a_open_water
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a6_value,
        CASE a.m6a_other
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6a_other_value1,
        CASE a.m6b_horizontal_plan_view_interspersion
            WHEN 'None (0)'::text THEN 0
            WHEN 'Low (1)'::text THEN 1
            WHEN 'Moderately low (2)'::text THEN 2
            WHEN 'Moderate (3)'::text THEN 3
            WHEN 'Moderately high (4)'::text THEN 4
            WHEN 'High (5)'::text THEN 5
            ELSE NULL::integer
        END AS metric6b_value,
        CASE a.m6c_coverage_of_invasive_plants
            WHEN 'Extensive > 75% cover (-5)'::text THEN '-5'::integer
            WHEN 'Moderate 25-75% cover (-3)'::text THEN '-3'::integer
            WHEN 'Sparse 5-25% cover (-1)'::text THEN '-1'::integer
            WHEN 'Nearly absent < 5% cover (0)'::text THEN 0
            WHEN 'Absent (1)'::text THEN 1
            ELSE NULL::integer
        END AS metric6c_value,
        CASE a.m6d_microtopography_vegetation_hummuckstussuck
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6d1_value,
        CASE a.m6d_microtopography_course_woody_debris_15cm_6in
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6d2_value,
        CASE a.m6d_microtopography_standing_dead_25cm_10in_dbh
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6d3_value,
        CASE a.m6d_microtopography_amphibian_breeding_pools
            WHEN '0'::text THEN 0
            WHEN '1'::text THEN 1
            WHEN '2'::text THEN 2
            WHEN '3'::text THEN 3
            ELSE NULL::integer
        END AS metric6d4_value
   FROM ((((((((oram_v2 a
     LEFT JOIN metric2b_split b ON (((b.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric3a_split c ON (((c.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric3b_split d ON (((d.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric3d_split e ON (((e.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric3e_split f ON (((f.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric4a_split g ON (((g.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric4c_split h ON (((h.fulcrum_id)::text = (a.fulcrum_id)::text)))
     LEFT JOIN metric5_split i ON (((i.fulcrum_id)::text = (a.fulcrum_id)::text)));


ALTER TABLE oram_metric_values OWNER TO jreinier;

--
-- TOC entry 728 (class 1259 OID 652194)
-- Name: oram_metrics; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE oram_metrics (
    fulcrum_id character varying(100) NOT NULL,
    metric1_selection text,
    metric2a_selection text,
    metric2b_selection1 text,
    metric2b_selection2 text,
    metric3a_selection1 text,
    metric3a_selection2 text,
    metric3a_selection3 text,
    metric3a_selection4 text,
    metric3a_selection5 text,
    metric3b_selection1 text,
    metric3b_selection2 text,
    metric3b_selection3 text,
    metric3b_selection4 text,
    metric3c_selection text,
    metric3d_selection1 text,
    metric3d_selection2 text,
    metric3e_selection1 text,
    metric3e_selection2 text,
    hydro_disturbance1 text,
    hydro_disturbance2 text,
    hydro_disturbance3 text,
    hydro_disturbance4 text,
    hydro_disturbance5 text,
    hydro_disturbance6 text,
    hydro_disturbance7 text,
    hydro_disturbance8 text,
    hydro_disturbance9 text,
    hydro_disturbance_other text,
    metric4a_selection1 text,
    metric4a_selection2 text,
    metric4b_selection text,
    metric4c_selection1 text,
    metric4c_selection2 text,
    habitat_disturbance1 text,
    habitat_disturbance2 text,
    habitat_disturbance3 text,
    habitat_disturbance4 text,
    habitat_disturbance5 text,
    habitat_disturbance6 text,
    habitat_disturbance7 text,
    habitat_disturbance8 text,
    habitat_disturbance9 text,
    habitat_disturbance10 text,
    habitat_disturbance11 text,
    habitat_disturbance12 text,
    habitat_disturbance_other text,
    metric5_selection1 text,
    metric5_selection2 text,
    metric6a1_aquatic_bed text,
    metric6a2_emergent text,
    metric6a3_shrub text,
    metric6a4_forest text,
    metric6a5_mudflats text,
    metric6a6_open_water text,
    metric6a_other1 text,
    metric6b_selection text,
    metric6c_selection text,
    metric6d1_selection text,
    metric6d2_selection text,
    metric6d3_selection text,
    metric6d4_selection text
);


ALTER TABLE oram_metrics OWNER TO jreinier;

--
-- TOC entry 718 (class 1259 OID 652121)
-- Name: oram_scores; Type: VIEW; Schema: wetland; Owner: jreinier
--

CREATE VIEW oram_scores AS
 WITH a AS (
         SELECT oram_metric_values.fulcrum_id,
            oram_metric_values.metric1_value AS metric1_score,
            oram_metric_values.metric2a_value AS metric2a_score,
                CASE
                    WHEN (oram_metric_values.metric2b2_value IS NOT NULL) THEN ((COALESCE((oram_metric_values.metric2b1_value)::numeric, (0)::numeric) + COALESCE((oram_metric_values.metric2b2_value)::numeric, (0)::numeric)) / (2)::numeric)
                    ELSE (oram_metric_values.metric2b1_value)::numeric
                END AS metric2b_score,
            ((((COALESCE(oram_metric_values.metric3a1_value, 0) + COALESCE(oram_metric_values.metric3a2_value, 0)) + COALESCE(oram_metric_values.metric3a3_value, 0)) + COALESCE(oram_metric_values.metric3a4_value, 0)) + COALESCE(oram_metric_values.metric3a5_value, 0)) AS metric3a_score,
            (((COALESCE(oram_metric_values.metric3b1_value, 0) + COALESCE(oram_metric_values.metric3b2_value, 0)) + COALESCE(oram_metric_values.metric3b3_value, 0)) + COALESCE(oram_metric_values.metric3b4_value, 0)) AS metric3b_score,
            oram_metric_values.metric3c_value AS metric3c_score,
                CASE
                    WHEN (oram_metric_values.metric3d2_value IS NOT NULL) THEN ((COALESCE((oram_metric_values.metric3d1_value)::numeric, (0)::numeric) + COALESCE((oram_metric_values.metric3d2_value)::numeric, (0)::numeric)) / (2)::numeric)
                    ELSE (oram_metric_values.metric3d1_value)::numeric
                END AS metric3d_score,
                CASE
                    WHEN (oram_metric_values.metric3e2_value IS NOT NULL) THEN ((COALESCE((oram_metric_values.metric3e1_value)::numeric, (0)::numeric) + COALESCE((oram_metric_values.metric3e2_value)::numeric, (0)::numeric)) / (2)::numeric)
                    ELSE (oram_metric_values.metric3e1_value)::numeric
                END AS metric3e_score,
                CASE
                    WHEN (oram_metric_values.metric4a2_value IS NOT NULL) THEN ((COALESCE((oram_metric_values.metric4a1_value)::numeric, (0)::numeric) + COALESCE((oram_metric_values.metric4a2_value)::numeric, (0)::numeric)) / (2)::numeric)
                    ELSE (oram_metric_values.metric4a1_value)::numeric
                END AS metric4a_score,
            oram_metric_values.metric4b_value AS metric4b_score,
                CASE
                    WHEN (oram_metric_values.metric4c2_value IS NOT NULL) THEN ((COALESCE((oram_metric_values.metric4c1_value)::numeric, (0)::numeric) + COALESCE((oram_metric_values.metric4c2_value)::numeric, (0)::numeric)) / (2)::numeric)
                    ELSE (oram_metric_values.metric4c1_value)::numeric
                END AS metric4c_score,
                CASE
                    WHEN ((COALESCE(oram_metric_values.metric5_value1, 0) + COALESCE(oram_metric_values.metric5_value2, 0)) > 10) THEN 10
                    ELSE oram_metric_values.metric5_value1
                END AS metric5_score,
            ((((((COALESCE(oram_metric_values.metric6a1_value, 0) + COALESCE(oram_metric_values.metric6a2_value, 0)) + COALESCE(oram_metric_values.metric6a3_value, 0)) + COALESCE(oram_metric_values.metric6a4_value, 0)) + COALESCE(oram_metric_values.metric6a5_value, 0)) + COALESCE(oram_metric_values.metric6a6_value, 0)) + COALESCE(oram_metric_values.metric6a_other_value1, 0)) AS metric6a_score,
            oram_metric_values.metric6b_value AS metric6b_score,
            oram_metric_values.metric6c_value AS metric6c_score,
            (((COALESCE(oram_metric_values.metric6d1_value, 0) + COALESCE(oram_metric_values.metric6d2_value, 0)) + COALESCE(oram_metric_values.metric6d3_value, 0)) + COALESCE(oram_metric_values.metric6d4_value, 0)) AS metric6d_score
           FROM oram_metric_values
        ), b AS (
         SELECT a_1.fulcrum_id,
            a_1.metric1_score,
            a_1.metric2a_score,
            a_1.metric2b_score,
            a_1.metric3a_score,
            a_1.metric3b_score,
            a_1.metric3c_score,
            a_1.metric3d_score,
            a_1.metric3e_score,
            a_1.metric4a_score,
            a_1.metric4b_score,
            a_1.metric4c_score,
            a_1.metric5_score,
            a_1.metric6a_score,
            a_1.metric6b_score,
            a_1.metric6c_score,
            a_1.metric6d_score,
            ((((((((((((((((COALESCE(a_1.metric1_score, 0) + COALESCE(a_1.metric2a_score, 0)))::numeric + COALESCE(a_1.metric2b_score, (0)::numeric)) + (COALESCE(a_1.metric3a_score, 0))::numeric) + (COALESCE(a_1.metric3b_score, 0))::numeric) + (COALESCE(a_1.metric3c_score, 0))::numeric) + COALESCE(a_1.metric3d_score, (0)::numeric)) + COALESCE(a_1.metric3e_score, (0)::numeric)) + COALESCE(a_1.metric4a_score, (0)::numeric)) + (COALESCE(a_1.metric4b_score, 0))::numeric) + COALESCE(a_1.metric4c_score, (0)::numeric)) + (COALESCE(a_1.metric5_score, 0))::numeric) + (COALESCE(a_1.metric6a_score, 0))::numeric) + (COALESCE(a_1.metric6b_score, 0))::numeric) + (COALESCE(a_1.metric6c_score, 0))::numeric) + (COALESCE(a_1.metric6d_score, 0))::numeric) AS grand_total
           FROM a a_1
        ), c AS (
         SELECT b_1.fulcrum_id,
                CASE
                    WHEN (b_1.grand_total < 30.0) THEN '1'::text
                    WHEN ((b_1.grand_total > 29.9) AND (b_1.grand_total < 50.0)) THEN '2a'::text
                    WHEN ((b_1.grand_total > 49.9) AND (b_1.grand_total < 60.0)) THEN '2b'::text
                    WHEN (b_1.grand_total > 59.0) THEN '3'::text
                    ELSE NULL::text
                END AS category
           FROM b b_1
        )
 SELECT a.fulcrum_id,
    a.metric1_score,
    a.metric2a_score,
    a.metric2b_score,
    a.metric3a_score,
    a.metric3b_score,
    a.metric3c_score,
    a.metric3d_score,
    a.metric3e_score,
    a.metric4a_score,
    a.metric4b_score,
    a.metric4c_score,
    a.metric5_score,
    a.metric6a_score,
    a.metric6b_score,
    a.metric6c_score,
    a.metric6d_score,
    b.grand_total,
    c.category
   FROM ((a
     LEFT JOIN b ON (((a.fulcrum_id)::text = (b.fulcrum_id)::text)))
     LEFT JOIN c ON (((a.fulcrum_id)::text = (c.fulcrum_id)::text)));


ALTER TABLE oram_scores OWNER TO jreinier;

--
-- TOC entry 729 (class 1259 OID 652230)
-- Name: oram_v2_photos; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE oram_v2_photos (
    fulcrum_id text,
    fulcrum_parent_id text,
    fulcrum_record_id text,
    version bigint,
    caption text,
    latitude double precision,
    longitude double precision,
    geometry public.geometry(Point,4326),
    file_size bigint,
    uploaded_at timestamp without time zone,
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


ALTER TABLE oram_v2_photos OWNER TO postgres;

--
-- TOC entry 730 (class 1259 OID 652254)
-- Name: plant_community_classification; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE plant_community_classification (
    fulcrum_id character varying(100) NOT NULL,
    plant_community text,
    modifier_one text,
    modifier_two text,
    modifier_three text
);


ALTER TABLE plant_community_classification OWNER TO jreinier;

--
-- TOC entry 731 (class 1259 OID 652266)
-- Name: water_flow_path; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE water_flow_path (
    fulcrum_id character varying(100) NOT NULL,
    water_flow_path text
);


ALTER TABLE water_flow_path OWNER TO jreinier;

--
-- TOC entry 719 (class 1259 OID 652126)
-- Name: wetland_classification; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE wetland_classification (
    fulcrum_id character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by text,
    updated_by text,
    system_created_at timestamp without time zone,
    system_updated_at timestamp without time zone,
    version bigint,
    status text,
    project text,
    assigned_to text,
    latitude double precision,
    longitude double precision,
    geometry public.geometry(Point,4326),
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
    photos_url text
);


ALTER TABLE wetland_classification OWNER TO jreinier;

--
-- TOC entry 732 (class 1259 OID 652272)
-- Name: wetland_classification_photos; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE wetland_classification_photos (
    fulcrum_id text,
    fulcrum_parent_id text,
    fulcrum_record_id text,
    version bigint,
    caption text,
    latitude double precision,
    longitude double precision,
    geometry public.geometry(Point,4326),
    file_size bigint,
    uploaded_at timestamp without time zone,
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


ALTER TABLE wetland_classification_photos OWNER TO postgres;

--
-- TOC entry 733 (class 1259 OID 652278)
-- Name: wetland_classification_pre_fulcrum; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE wetland_classification_pre_fulcrum (
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
    serial_id bigint NOT NULL
);


ALTER TABLE wetland_classification_pre_fulcrum OWNER TO postgres;

--
-- TOC entry 734 (class 1259 OID 652284)
-- Name: wetland_grts_large_polys; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE wetland_grts_large_polys (
    gid integer NOT NULL,
    siteid character varying(25),
    xcoord numeric,
    ycoord numeric,
    mdcaty character varying(16),
    wgt numeric,
    stratum character varying(4),
    panel character varying(8),
    evalstatus character varying(7),
    evalreason character varying(1),
    __gid numeric,
    reserv character varying(19),
    area_acres double precision,
    poly_type character varying(7),
    size_class character varying(18),
    cm_id character varying(4),
    area numeric,
    perimeter numeric,
    ap_ratio double precision,
    geom public.geometry(Point)
);


ALTER TABLE wetland_grts_large_polys OWNER TO jreinier;

--
-- TOC entry 735 (class 1259 OID 652290)
-- Name: wetland_grts_large_polys_gid_seq; Type: SEQUENCE; Schema: wetland; Owner: jreinier
--

CREATE SEQUENCE wetland_grts_large_polys_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wetland_grts_large_polys_gid_seq OWNER TO jreinier;

--
-- TOC entry 5796 (class 0 OID 0)
-- Dependencies: 735
-- Name: wetland_grts_large_polys_gid_seq; Type: SEQUENCE OWNED BY; Schema: wetland; Owner: jreinier
--

ALTER SEQUENCE wetland_grts_large_polys_gid_seq OWNED BY wetland_grts_large_polys.gid;


--
-- TOC entry 736 (class 1259 OID 652292)
-- Name: wetland_grts_small_polys; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE wetland_grts_small_polys (
    gid integer NOT NULL,
    siteid character varying(36),
    xcoord numeric,
    ycoord numeric,
    mdcaty character varying(16),
    wgt double precision,
    stratum character varying(4),
    panel character varying(8),
    evalstatus character varying(7),
    evalreason character varying(1),
    reserv character varying(19),
    area_acres double precision,
    poly_type character varying(7),
    size_class character varying(18),
    cm_id character varying(4),
    area numeric,
    perimeter numeric,
    ap_ratio numeric,
    geom public.geometry(Point)
);


ALTER TABLE wetland_grts_small_polys OWNER TO jreinier;

--
-- TOC entry 737 (class 1259 OID 652298)
-- Name: wetland_grts_small_polys_gid_seq; Type: SEQUENCE; Schema: wetland; Owner: jreinier
--

CREATE SEQUENCE wetland_grts_small_polys_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wetland_grts_small_polys_gid_seq OWNER TO jreinier;

--
-- TOC entry 5797 (class 0 OID 0)
-- Dependencies: 737
-- Name: wetland_grts_small_polys_gid_seq; Type: SEQUENCE OWNED BY; Schema: wetland; Owner: jreinier
--

ALTER SEQUENCE wetland_grts_small_polys_gid_seq OWNED BY wetland_grts_small_polys.gid;


--
-- TOC entry 738 (class 1259 OID 652300)
-- Name: wetland_grts_xlarge_polys; Type: TABLE; Schema: wetland; Owner: jreinier
--

CREATE TABLE wetland_grts_xlarge_polys (
    gid integer NOT NULL,
    siteid character varying(26),
    xcoord numeric,
    ycoord numeric,
    mdcaty character varying(16),
    wgt numeric,
    stratum character varying(4),
    panel character varying(8),
    evalstatus character varying(7),
    evalreason character varying(1),
    __gid numeric,
    reserv character varying(15),
    area_acres numeric,
    poly_type character varying(7),
    size_class character varying(10),
    cm_id character varying(4),
    area numeric,
    perimeter numeric,
    ap_ratio double precision,
    geom public.geometry(Point)
);


ALTER TABLE wetland_grts_xlarge_polys OWNER TO jreinier;

--
-- TOC entry 739 (class 1259 OID 652306)
-- Name: wetland_grts_xlarge_polys_gid_seq; Type: SEQUENCE; Schema: wetland; Owner: jreinier
--

CREATE SEQUENCE wetland_grts_xlarge_polys_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wetland_grts_xlarge_polys_gid_seq OWNER TO jreinier;

--
-- TOC entry 5798 (class 0 OID 0)
-- Dependencies: 739
-- Name: wetland_grts_xlarge_polys_gid_seq; Type: SEQUENCE OWNED BY; Schema: wetland; Owner: jreinier
--

ALTER SEQUENCE wetland_grts_xlarge_polys_gid_seq OWNED BY wetland_grts_xlarge_polys.gid;


--
-- TOC entry 740 (class 1259 OID 652308)
-- Name: wetland_oram_data_pre_fulcrum; Type: TABLE; Schema: wetland; Owner: postgres
--

CREATE TABLE wetland_oram_data_pre_fulcrum (
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
    serial_id bigint NOT NULL
);


ALTER TABLE wetland_oram_data_pre_fulcrum OWNER TO postgres;

--
-- TOC entry 741 (class 1259 OID 652314)
-- Name: wetland_oram_data_serial_id_seq; Type: SEQUENCE; Schema: wetland; Owner: postgres
--

CREATE SEQUENCE wetland_oram_data_serial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wetland_oram_data_serial_id_seq OWNER TO postgres;

--
-- TOC entry 5799 (class 0 OID 0)
-- Dependencies: 741
-- Name: wetland_oram_data_serial_id_seq; Type: SEQUENCE OWNED BY; Schema: wetland; Owner: postgres
--

ALTER SEQUENCE wetland_oram_data_serial_id_seq OWNED BY wetland_oram_data_pre_fulcrum.serial_id;


--
-- TOC entry 5444 (class 2604 OID 652316)
-- Name: gid; Type: DEFAULT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY wetland_grts_large_polys ALTER COLUMN gid SET DEFAULT nextval('wetland_grts_large_polys_gid_seq'::regclass);


--
-- TOC entry 5445 (class 2604 OID 652317)
-- Name: gid; Type: DEFAULT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY wetland_grts_small_polys ALTER COLUMN gid SET DEFAULT nextval('wetland_grts_small_polys_gid_seq'::regclass);


--
-- TOC entry 5446 (class 2604 OID 652318)
-- Name: gid; Type: DEFAULT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY wetland_grts_xlarge_polys ALTER COLUMN gid SET DEFAULT nextval('wetland_grts_xlarge_polys_gid_seq'::regclass);


--
-- TOC entry 5447 (class 2604 OID 652319)
-- Name: serial_id; Type: DEFAULT; Schema: wetland; Owner: postgres
--

ALTER TABLE ONLY wetland_oram_data_pre_fulcrum ALTER COLUMN serial_id SET DEFAULT nextval('wetland_oram_data_serial_id_seq'::regclass);


--
-- TOC entry 5455 (class 2606 OID 652441)
-- Name: wetlands_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cm_wetlands
    ADD CONSTRAINT wetlands_pkey PRIMARY KEY (reservation, polygon_number);


--
-- TOC entry 742 (class 1259 OID 653290)
-- Name: cm_wetland_class_oram; Type: MATERIALIZED VIEW; Schema: wetland; Owner: jreinier
--

CREATE MATERIALIZED VIEW cm_wetland_class_oram AS
 WITH oram_poly AS (
         SELECT a_1.fulcrum_id,
            regexp_split_to_table(a_1.polygon_id, ','::text) AS polygon_number,
            a_1.reservation,
            (b_1.grand_total)::text AS grand_total,
            b_1.category
           FROM (oram_v2 a_1
             LEFT JOIN oram_scores b_1 ON (((b_1.fulcrum_id)::text = (a_1.fulcrum_id)::text)))
        )
 SELECT a.polygon_number,
    a.reservation,
    a.poly_type,
    a.area_acres,
    a.geom,
    b.classification_level,
    b.landscape_position,
    b.inland_landform,
    b.water_flow_path,
    b.llww_modifiers,
    b.cowardin_classification,
    b.cowardin_water_regime,
    b.cowardin_special_modifier,
    b.cowardin_special_modifier_other,
    b.plant_community,
    b.plant_community_other,
    string_agg(c.grand_total, ','::text) AS oram_score,
    string_agg(c.category, ','::text) AS oram_category
   FROM ((cm_wetlands a
     LEFT JOIN wetland_classification b ON (((a.polygon_number = b.polygon_id) AND (a.reservation = b.reservation) AND (b.classification_level <> 'secondary'::text) AND (b.classification_level <> 'minor'::text))))
     LEFT JOIN oram_poly c ON (((a.polygon_number = c.polygon_number) AND (a.reservation = c.reservation))))
  GROUP BY a.polygon_number, a.reservation, a.poly_type, a.geom, b.classification_level, b.landscape_position, b.inland_landform, b.water_flow_path, b.llww_modifiers, b.cowardin_classification, b.cowardin_water_regime, b.cowardin_special_modifier, b.cowardin_special_modifier_other, b.plant_community, b.plant_community_other
  ORDER BY a.reservation, a.polygon_number
  WITH NO DATA;


ALTER TABLE cm_wetland_class_oram OWNER TO jreinier;

--
-- TOC entry 743 (class 1259 OID 653914)
-- Name: cm_wetland_class_oram_updated; Type: MATERIALIZED VIEW; Schema: wetland; Owner: jreinier
--

CREATE MATERIALIZED VIEW cm_wetland_class_oram_updated AS
 SELECT poly.polygon_number,
    poly.reservation,
    poly.geom,
    poly.area_acres,
    poly.poly_type,
    poly.classification_level,
    poly.landscape_position,
    landscape.landscape_position_new,
    poly.inland_landform,
    landform.landform_new,
    poly.water_flow_path,
    poly.llww_modifiers,
    poly.cowardin_classification,
    poly.cowardin_water_regime,
    poly.cowardin_special_modifier,
    poly.plant_community,
    poly.oram_score,
    poly.oram_category
   FROM ((cm_wetland_class_oram poly
     LEFT JOIN ( SELECT DISTINCT poly_1.polygon_number,
            poly_1.reservation,
                CASE poly_1.inland_landform
                    WHEN 'basin-woodland vernal'::text THEN 'floodplain-basin'::text
                    WHEN 'basin'::text THEN 'floodplain-basin'::text
                    WHEN 'flat'::text THEN 'floodplain'::text
                    ELSE poly_1.inland_landform
                END AS landform_new
           FROM cm_wetland_class_oram poly_1,
            nr_misc.flood_zones_oh_leap_3734 floodzone
          WHERE (public.st_intersects(poly_1.geom, floodzone.geom) AND (poly_1.inland_landform !~~ '%floodplain%'::text) AND (poly_1.inland_landform IS NOT NULL))) landform ON (((landform.reservation = poly.reservation) AND (landform.polygon_number = poly.polygon_number))))
     LEFT JOIN ( SELECT DISTINCT poly2.polygon_number,
            poly2.reservation,
                CASE poly2.landscape_position
                    WHEN 'terrene'::text THEN 'terrene riparian'::text
                    WHEN 'terrene non-riparian'::text THEN 'terrene riparian'::text
                    ELSE poly2.landscape_position
                END AS landscape_position_new
           FROM cm_wetland_class_oram poly2,
            nr_misc.flood_zones_oh_leap_3734 floodzone
          WHERE (public.st_intersects(poly2.geom, floodzone.geom) AND (poly2.landscape_position <> 'terrene riparian'::text) AND (poly2.landscape_position IS NOT NULL))) landscape ON (((landscape.reservation = poly.reservation) AND (landscape.polygon_number = poly.polygon_number))))
  WITH NO DATA;


ALTER TABLE cm_wetland_class_oram_updated OWNER TO jreinier;

--
-- TOC entry 5481 (class 2606 OID 652371)
-- Name: class_pkey; Type: CONSTRAINT; Schema: wetland; Owner: postgres
--

ALTER TABLE ONLY wetland_classification_pre_fulcrum
    ADD CONSTRAINT class_pkey PRIMARY KEY (unique_id, reserv);


--
-- TOC entry 5449 (class 2606 OID 652375)
-- Name: classification_dominant_species_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY classification_dominant_species
    ADD CONSTRAINT classification_dominant_species_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5451 (class 2606 OID 652379)
-- Name: classification_id_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY classification_id
    ADD CONSTRAINT classification_id_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5453 (class 2606 OID 652385)
-- Name: cm_oram_data_pkey; Type: CONSTRAINT; Schema: wetland; Owner: postgres
--

ALTER TABLE ONLY cm_oram_data
    ADD CONSTRAINT cm_oram_data_pkey PRIMARY KEY (oram_id);


--
-- TOC entry 5459 (class 2606 OID 652387)
-- Name: cm_wetland_classification_to_fulcrum_format_pkey; Type: CONSTRAINT; Schema: wetland; Owner: postgres
--

ALTER TABLE ONLY cm_wetland_classification_to_fulcrum_format
    ADD CONSTRAINT cm_wetland_classification_to_fulcrum_format_pkey PRIMARY KEY (classification_id);


--
-- TOC entry 5461 (class 2606 OID 652389)
-- Name: cowardin_classification_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_classification
    ADD CONSTRAINT cowardin_classification_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5463 (class 2606 OID 652391)
-- Name: cowardin_special_modifiers_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_special_modifiers
    ADD CONSTRAINT cowardin_special_modifiers_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5465 (class 2606 OID 652393)
-- Name: cowardin_water_regime_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_water_regime
    ADD CONSTRAINT cowardin_water_regime_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5467 (class 2606 OID 652395)
-- Name: inland_landform_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY inland_landform
    ADD CONSTRAINT inland_landform_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5469 (class 2606 OID 652397)
-- Name: landscape_position_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY landscape_position
    ADD CONSTRAINT landscape_position_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5471 (class 2606 OID 652399)
-- Name: llww_modifiers_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY llww_modifiers
    ADD CONSTRAINT llww_modifiers_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5496 (class 2606 OID 654662)
-- Name: lookup_cowardin_class_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY lookup_cowardin_class
    ADD CONSTRAINT lookup_cowardin_class_pkey PRIMARY KEY (class);


--
-- TOC entry 5498 (class 2606 OID 654675)
-- Name: lookup_cowardin_subclass_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY lookup_cowardin_subclass
    ADD CONSTRAINT lookup_cowardin_subclass_pkey PRIMARY KEY (subclass);


--
-- TOC entry 5494 (class 2606 OID 654636)
-- Name: lookup_cowardin_system_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY lookup_cowardin_system
    ADD CONSTRAINT lookup_cowardin_system_pkey PRIMARY KEY (system);


--
-- TOC entry 5473 (class 2606 OID 652405)
-- Name: oram_ids_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY oram_ids
    ADD CONSTRAINT oram_ids_pkey PRIMARY KEY (reservation, polygon_number, fulcrum_id);


--
-- TOC entry 5475 (class 2606 OID 652407)
-- Name: oram_metrics_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY oram_metrics
    ADD CONSTRAINT oram_metrics_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5492 (class 2606 OID 652417)
-- Name: oram_pkey; Type: CONSTRAINT; Schema: wetland; Owner: postgres
--

ALTER TABLE ONLY wetland_oram_data_pre_fulcrum
    ADD CONSTRAINT oram_pkey PRIMARY KEY (reserv, unique_id, oram_id);


--
-- TOC entry 5457 (class 2606 OID 652421)
-- Name: oram_v2_pkey; Type: CONSTRAINT; Schema: wetland; Owner: postgres
--

ALTER TABLE ONLY oram_v2
    ADD CONSTRAINT oram_v2_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5477 (class 2606 OID 652431)
-- Name: plant_community_classification_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY plant_community_classification
    ADD CONSTRAINT plant_community_classification_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5479 (class 2606 OID 652433)
-- Name: water_flow_path_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY water_flow_path
    ADD CONSTRAINT water_flow_path_pkey PRIMARY KEY (fulcrum_id);


--
-- TOC entry 5484 (class 2606 OID 652435)
-- Name: wetland_grts_large_polys_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY wetland_grts_large_polys
    ADD CONSTRAINT wetland_grts_large_polys_pkey PRIMARY KEY (gid);


--
-- TOC entry 5487 (class 2606 OID 652437)
-- Name: wetland_grts_small_polys_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY wetland_grts_small_polys
    ADD CONSTRAINT wetland_grts_small_polys_pkey PRIMARY KEY (gid);


--
-- TOC entry 5490 (class 2606 OID 652439)
-- Name: wetland_grts_xlarge_polys_pkey; Type: CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY wetland_grts_xlarge_polys
    ADD CONSTRAINT wetland_grts_xlarge_polys_pkey PRIMARY KEY (gid);


--
-- TOC entry 5482 (class 1259 OID 652442)
-- Name: wetland_grts_large_polys_geom_idx; Type: INDEX; Schema: wetland; Owner: jreinier
--

CREATE INDEX wetland_grts_large_polys_geom_idx ON wetland_grts_large_polys USING gist (geom);


--
-- TOC entry 5485 (class 1259 OID 652443)
-- Name: wetland_grts_small_polys_geom_idx; Type: INDEX; Schema: wetland; Owner: jreinier
--

CREATE INDEX wetland_grts_small_polys_geom_idx ON wetland_grts_small_polys USING gist (geom);


--
-- TOC entry 5488 (class 1259 OID 652444)
-- Name: wetland_grts_xlarge_polys_geom_idx; Type: INDEX; Schema: wetland; Owner: jreinier
--

CREATE INDEX wetland_grts_xlarge_polys_geom_idx ON wetland_grts_xlarge_polys USING gist (geom);


--
-- TOC entry 5520 (class 2620 OID 652446)
-- Name: classification_cowardin_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_cowardin_log_trigger AFTER INSERT OR DELETE OR UPDATE ON cowardin_classification FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5521 (class 2620 OID 652447)
-- Name: classification_cowardin_special_mod_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_cowardin_special_mod_log_trigger AFTER INSERT OR DELETE OR UPDATE ON cowardin_special_modifiers FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5522 (class 2620 OID 652448)
-- Name: classification_cowardin_water_regime_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_cowardin_water_regime_trigger AFTER INSERT OR DELETE OR UPDATE ON cowardin_water_regime FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5516 (class 2620 OID 652449)
-- Name: classification_dominant_species_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_dominant_species_log_trigger AFTER INSERT OR DELETE OR UPDATE ON classification_dominant_species FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5517 (class 2620 OID 652451)
-- Name: classification_id_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_id_log_trigger AFTER INSERT OR DELETE OR UPDATE ON classification_id FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5523 (class 2620 OID 652452)
-- Name: classification_inland_landform_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_inland_landform_log_trigger AFTER INSERT OR DELETE OR UPDATE ON inland_landform FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5524 (class 2620 OID 652453)
-- Name: classification_landscape_position_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_landscape_position_log_trigger AFTER INSERT OR DELETE OR UPDATE ON landscape_position FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5525 (class 2620 OID 652454)
-- Name: classification_llww_modifiers_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_llww_modifiers_log_trigger AFTER INSERT OR DELETE OR UPDATE ON llww_modifiers FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5526 (class 2620 OID 652459)
-- Name: classification_plant_community_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_plant_community_log_trigger AFTER INSERT OR DELETE OR UPDATE ON plant_community_classification FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5527 (class 2620 OID 652462)
-- Name: classification_water_flow_path_log_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER classification_water_flow_path_log_trigger AFTER INSERT OR DELETE OR UPDATE ON water_flow_path FOR EACH ROW EXECUTE PROCEDURE change_trigger();


--
-- TOC entry 5519 (class 2620 OID 652463)
-- Name: cm_wetland_classification_upsert_trigger; Type: TRIGGER; Schema: wetland; Owner: jreinier
--

CREATE TRIGGER cm_wetland_classification_upsert_trigger AFTER INSERT ON wetland_classification FOR EACH STATEMENT EXECUTE PROCEDURE classification_upsert();


--
-- TOC entry 5518 (class 2620 OID 652464)
-- Name: oram_upsert_trigger; Type: TRIGGER; Schema: wetland; Owner: postgres
--

CREATE TRIGGER oram_upsert_trigger AFTER INSERT ON oram_v2 FOR EACH STATEMENT EXECUTE PROCEDURE oram_upsert();


--
-- TOC entry 5499 (class 2606 OID 652470)
-- Name: classification_dominant_species_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY classification_dominant_species
    ADD CONSTRAINT classification_dominant_species_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5500 (class 2606 OID 652490)
-- Name: classification_to_mapping_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY classification_id
    ADD CONSTRAINT classification_to_mapping_fkey FOREIGN KEY (polygon_number, reservation) REFERENCES cm_wetlands(polygon_number, reservation) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5503 (class 2606 OID 654663)
-- Name: cowardin_classification_class_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_classification
    ADD CONSTRAINT cowardin_classification_class_fkey FOREIGN KEY (class) REFERENCES lookup_cowardin_class(class);


--
-- TOC entry 5501 (class 2606 OID 654681)
-- Name: cowardin_classification_class_fkey1; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_classification
    ADD CONSTRAINT cowardin_classification_class_fkey1 FOREIGN KEY (class) REFERENCES lookup_cowardin_class(class);


--
-- TOC entry 5505 (class 2606 OID 652495)
-- Name: cowardin_classification_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_classification
    ADD CONSTRAINT cowardin_classification_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5502 (class 2606 OID 654676)
-- Name: cowardin_classification_subclass_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_classification
    ADD CONSTRAINT cowardin_classification_subclass_fkey FOREIGN KEY (subclass) REFERENCES lookup_cowardin_subclass(subclass);


--
-- TOC entry 5504 (class 2606 OID 654637)
-- Name: cowardin_classification_system_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_classification
    ADD CONSTRAINT cowardin_classification_system_fkey FOREIGN KEY (system) REFERENCES lookup_cowardin_system(system);


--
-- TOC entry 5506 (class 2606 OID 652500)
-- Name: cowardin_special_modifier_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_special_modifiers
    ADD CONSTRAINT cowardin_special_modifier_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5507 (class 2606 OID 652505)
-- Name: cowardin_water_regime_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY cowardin_water_regime
    ADD CONSTRAINT cowardin_water_regime_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5508 (class 2606 OID 652510)
-- Name: inland_landform_norm_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY inland_landform
    ADD CONSTRAINT inland_landform_norm_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5509 (class 2606 OID 652515)
-- Name: landscape_position_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY landscape_position
    ADD CONSTRAINT landscape_position_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5510 (class 2606 OID 652520)
-- Name: llww_modifiers_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY llww_modifiers
    ADD CONSTRAINT llww_modifiers_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5512 (class 2606 OID 652525)
-- Name: oram_fulcrum_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY oram_ids
    ADD CONSTRAINT oram_fulcrum_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES oram_v2(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5513 (class 2606 OID 652530)
-- Name: oram_metrics_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY oram_metrics
    ADD CONSTRAINT oram_metrics_fkey FOREIGN KEY (fulcrum_id) REFERENCES oram_v2(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5511 (class 2606 OID 652555)
-- Name: oram_poly_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY oram_ids
    ADD CONSTRAINT oram_poly_id_fkey FOREIGN KEY (reservation, polygon_number) REFERENCES cm_wetlands(reservation, polygon_number) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5514 (class 2606 OID 652580)
-- Name: plant_community_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY plant_community_classification
    ADD CONSTRAINT plant_community_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5515 (class 2606 OID 652590)
-- Name: water_flow_path_id_fkey; Type: FK CONSTRAINT; Schema: wetland; Owner: jreinier
--

ALTER TABLE ONLY water_flow_path
    ADD CONSTRAINT water_flow_path_id_fkey FOREIGN KEY (fulcrum_id) REFERENCES classification_id(fulcrum_id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2017-02-22 10:30:37

--
-- PostgreSQL database dump complete
--

