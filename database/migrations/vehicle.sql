-- =====================================================
-- File:        vehicle.sql
-- Purpose:     Creates the VEHICLE table for PrimeAutocare
-- Depends on:  CUSTOMER
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS VEHICLE CASCADE;
DROP SEQUENCE IF EXISTS vehicle_seq CASCADE;
CREATE SEQUENCE vehicle_seq;
CREATE TABLE VEHICLE (
    vehi_id      VARCHAR(6)  CONSTRAINT vehicle_pk PRIMARY KEY
                             DEFAULT 'VE' || LPAD(NEXTVAL('vehicle_seq')::TEXT, 4, '0'),
    cust_no      VARCHAR(6),
    vehi_license VARCHAR(10) NOT NULL,
    vehi_make    VARCHAR(20) NOT NULL,
    vehi_model   VARCHAR(20) NOT NULL,
    vehi_year    INTEGER     NOT NULL
);
ALTER SEQUENCE vehicle_seq OWNED BY VEHICLE.vehi_id;
COMMENT ON COLUMN VEHICLE.vehi_id      IS 'Unique vehicle code — VE + 4 digits (e.g. VE0001)';
COMMENT ON COLUMN VEHICLE.cust_no      IS 'Reference to the owning CUSTOMER; nullable until a customer is linked';
COMMENT ON COLUMN VEHICLE.vehi_license IS 'Licence plate number. ERD specified VARCHAR(5); extended to VARCHAR(10) to accommodate real-world plate lengths (e.g. CAB-1234)';
COMMENT ON COLUMN VEHICLE.vehi_make    IS 'Vehicle manufacturer (e.g. Toyota, Honda)';
COMMENT ON COLUMN VEHICLE.vehi_model   IS 'Vehicle model name (e.g. Corolla, Civic)';
COMMENT ON COLUMN VEHICLE.vehi_year    IS 'Four-digit manufacture year (e.g. 2021)';
ALTER TABLE VEHICLE ADD CONSTRAINT customer_vehicle_fk FOREIGN KEY (cust_no) REFERENCES CUSTOMER (cust_no);
ALTER TABLE VEHICLE ADD CONSTRAINT vehi_id_fmt_chk CHECK (vehi_id ~ '^VE[0-9]{4}$');
ALTER TABLE VEHICLE ADD CONSTRAINT vehi_license_uq UNIQUE (vehi_license);
