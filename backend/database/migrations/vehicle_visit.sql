-- =====================================================
-- File:        vehicle_visit.sql
-- Purpose:     Creates the VEHICLE_VISIT table for PrimeAutocare
-- Depends on:  vehicle.sql
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE VEHICLE_VISIT CASCADE CONSTRAINTS;

CREATE TABLE VEHICLE_VISIT (
    visit_id           NUMBER(5) CONSTRAINT vehicle_visit_pk PRIMARY KEY,
    vehi_id            NUMBER(5) NOT NULL,
    visit_check_in_dt  DATE      NOT NULL,
    visit_check_out_dt DATE,
    visit_status       CHAR(1)   NOT NULL
);

COMMENT ON COLUMN VEHICLE_VISIT.visit_id           IS 'Unique visit identifier';
COMMENT ON COLUMN VEHICLE_VISIT.vehi_id            IS 'Reference to the VEHICLE being serviced';
COMMENT ON COLUMN VEHICLE_VISIT.visit_check_in_dt  IS 'Date the vehicle was checked in for service';
COMMENT ON COLUMN VEHICLE_VISIT.visit_check_out_dt IS 'Date the vehicle was collected by the owner; NULL until the vehicle is picked up';
COMMENT ON COLUMN VEHICLE_VISIT.visit_status       IS 'Visit status: C = Checked-In, I = In-progress, D = Done, O = Out / Picked Up';

ALTER TABLE VEHICLE_VISIT
    ADD CONSTRAINT vehicle_vehicle_visit_fk
        FOREIGN KEY (vehi_id) REFERENCES VEHICLE (vehi_id);

ALTER TABLE VEHICLE_VISIT
    ADD CONSTRAINT visit_status_chk CHECK (visit_status IN ('C', 'I', 'D', 'O'));
