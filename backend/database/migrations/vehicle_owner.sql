-- =====================================================
-- File:        vehicle_owner.sql
-- Purpose:     Creates the VEHICLE_OWNER table for PrimeAutocare
-- Depends on:  (none)
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS VEHICLE_OWNER CASCADE;
 
CREATE TABLE VEHICLE_OWNER (
    owner_no    INTEGER     CONSTRAINT vehicle_owner_pk PRIMARY KEY,
    owner_name  VARCHAR(30) NOT NULL,
    owner_phone VARCHAR(13) NOT NULL,
    owner_email VARCHAR(30) NOT NULL
);
 
COMMENT ON COLUMN VEHICLE_OWNER.owner_no    IS 'Unique vehicle owner number';
COMMENT ON COLUMN VEHICLE_OWNER.owner_name  IS 'Full name of the vehicle owner';
COMMENT ON COLUMN VEHICLE_OWNER.owner_phone IS 'Contact number — format: +94112233445';
COMMENT ON COLUMN VEHICLE_OWNER.owner_email IS 'Email address; must be unique across all owners';
 
ALTER TABLE VEHICLE_OWNER
    ADD CONSTRAINT owner_email_uq UNIQUE (owner_email);