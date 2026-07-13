-- =====================================================
-- File:        job.sql
-- Purpose:     Creates the JOB table for PrimeAutocare
-- Depends on:  (none)
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS JOB CASCADE;
 
CREATE TABLE JOB (
    job_no   INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT job_pk PRIMARY KEY,
    job_desc VARCHAR(60) NOT NULL
);

COMMENT ON COLUMN JOB.job_no   IS 'Unique job type identifier (auto-generated)';
COMMENT ON COLUMN JOB.job_desc IS 'Description of the service/job type (e.g. Oil Change, Tyre Rotation)';

ALTER TABLE JOB ALTER COLUMN job_no ADD GENERATED ALWAYS AS IDENTITY;