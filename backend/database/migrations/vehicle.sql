-- =====================================================
-- File:        vehicle.sql
-- Purpose:     Creates the VEHICLE table for PrimeAutocare
-- Depends on:  vehicle_owner.sql
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS VEHICLE CASCADE;
 
CREATE TABLE VEHICLE (
    vehi_id      INTEGER     CONSTRAINT vehicle_pk PRIMARY KEY,
    owner_no     INTEGER     NOT NULL,
    vehi_license VARCHAR(10) NOT NULL,
    vehi_make    VARCHAR(20) NOT NULL,
    vehi_model   VARCHAR(20) NOT NULL,
    vehi_year    INTEGER     NOT NULL
);
 
COMMENT ON COLUMN VEHICLE.vehi_id      IS 'Unique vehicle identifier';
COMMENT ON COLUMN VEHICLE.owner_no     IS 'Reference to the owning VEHICLE_OWNER';
COMMENT ON COLUMN VEHICLE.vehi_license IS 'Licence plate number. ERD specified VARCHAR(5); extended to VARCHAR(10) to accommodate real-world plate lengths (e.g. CAB-1234)';
COMMENT ON COLUMN VEHICLE.vehi_make    IS 'Vehicle manufacturer (e.g. Toyota, Honda)';
COMMENT ON COLUMN VEHICLE.vehi_model   IS 'Vehicle model name (e.g. Corolla, Civic)';
COMMENT ON COLUMN VEHICLE.vehi_year    IS 'Four-digit manufacture year (e.g. 2021)';
 
ALTER TABLE VEHICLE
    ADD CONSTRAINT vehicle_owner_vehicle_fk
        FOREIGN KEY (owner_no) REFERENCES VEHICLE_OWNER (owner_no);