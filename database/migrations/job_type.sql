-- =====================================================
-- File:        job_type.sql
-- Purpose:     Creates the JOB table (job type catalog) for PrimeAutocare
-- Depends on:  (none)
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS JOB CASCADE;
DROP SEQUENCE IF EXISTS job_seq CASCADE;
CREATE SEQUENCE job_seq;
CREATE TABLE JOB (
    job_no   VARCHAR(6)  CONSTRAINT job_pk PRIMARY KEY
                         DEFAULT 'JO' || LPAD(NEXTVAL('job_seq')::TEXT, 4, '0'),
    job_desc VARCHAR(60) NOT NULL
);
ALTER SEQUENCE job_seq OWNED BY JOB.job_no;
COMMENT ON COLUMN JOB.job_no   IS 'Unique job type code — JO + 4 digits (e.g. JO0001)';
COMMENT ON COLUMN JOB.job_desc IS 'Description of the service/job type (e.g. Oil Change, Tyre Rotation)';
ALTER TABLE JOB ADD CONSTRAINT job_no_fmt_chk CHECK (job_no ~ '^JO[0-9]{4}$');
