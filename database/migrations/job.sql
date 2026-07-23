-- =====================================================
-- File:        job.sql
-- Purpose:     Creates the JOBS table for PrimeAutocare — merges job
--              creation and job execution into a single record, replacing
--              the old VEHICLE_VISIT + JOB_ASSIGNMENT pair.
-- Depends on:  JOB (type catalog), VEHICLE, EMPLOYEE
-- Author:      Senuka Wijerathna
-- Created:     2026-07-23
-- =====================================================

DROP TABLE IF EXISTS JOBS CASCADE;
DROP SEQUENCE IF EXISTS jobs_seq CASCADE;
CREATE SEQUENCE jobs_seq;
CREATE TABLE JOBS (
    job_id       VARCHAR(6)   CONSTRAINT jobs_pk PRIMARY KEY
                              DEFAULT 'JB' || LPAD(NEXTVAL('jobs_seq')::TEXT, 4, '0'),
    job_no       VARCHAR(6)   NOT NULL,
    vehi_id      VARCHAR(6)   NOT NULL,
    emp_no       VARCHAR(6)   NOT NULL,
    performed_by VARCHAR(6),
    status       CHAR(1)      NOT NULL,
    hours        NUMERIC(5, 2),
    cost         NUMERIC(9, 2),
    notes        VARCHAR(100),
    created_by   VARCHAR(6)   NOT NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);
ALTER SEQUENCE jobs_seq OWNED BY JOBS.job_id;
COMMENT ON COLUMN JOBS.job_id       IS 'Unique job code — JB + 4 digits (e.g. JB0001)';
COMMENT ON COLUMN JOBS.job_no       IS 'Reference to the JOB type being performed';
COMMENT ON COLUMN JOBS.vehi_id      IS 'Reference to the VEHICLE being serviced';
COMMENT ON COLUMN JOBS.emp_no       IS 'emp_no of the employee assigned to this job';
COMMENT ON COLUMN JOBS.performed_by IS 'emp_no of the technician who carried out the work; NULL until work starts';
COMMENT ON COLUMN JOBS.status       IS 'Status code: P = Pending, I = In-progress, C = Completed, X = Cancelled';
COMMENT ON COLUMN JOBS.hours        IS 'Labour hours logged against this job; basis for utilization and invoicing';
COMMENT ON COLUMN JOBS.cost         IS 'Cost charged for this job; NULL until finalised';
COMMENT ON COLUMN JOBS.notes        IS 'Optional free-text notes on the job';
COMMENT ON COLUMN JOBS.created_by   IS 'emp_no of the employee who created this job';
COMMENT ON COLUMN JOBS.created_at   IS 'Timestamp the job record was created';
COMMENT ON COLUMN JOBS.updated_at   IS 'Timestamp the job record was last updated';
ALTER TABLE JOBS ADD CONSTRAINT job_jobs_fk FOREIGN KEY (job_no) REFERENCES JOB (job_no);
ALTER TABLE JOBS ADD CONSTRAINT vehicle_jobs_fk FOREIGN KEY (vehi_id) REFERENCES VEHICLE (vehi_id);
ALTER TABLE JOBS ADD CONSTRAINT employee_jobs_fk FOREIGN KEY (emp_no) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOBS ADD CONSTRAINT performer_jobs_fk FOREIGN KEY (performed_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOBS ADD CONSTRAINT creator_jobs_fk FOREIGN KEY (created_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOBS ADD CONSTRAINT jobs_status_chk CHECK (status IN ('P', 'I', 'C', 'X'));
ALTER TABLE JOBS ADD CONSTRAINT jobs_id_fmt_chk CHECK (job_id ~ '^JB[0-9]{4}$');
ALTER TABLE JOBS ADD CONSTRAINT jobs_hours_chk CHECK (hours IS NULL OR hours > 0);
-- Work that has started or finished must name the technician who did it,
-- otherwise utilization silently under-reports.
ALTER TABLE JOBS ADD CONSTRAINT jobs_performer_req_chk
    CHECK (status NOT IN ('I', 'C') OR performed_by IS NOT NULL);
-- Completed work must have logged hours, otherwise payroll silently under-pays.
ALTER TABLE JOBS ADD CONSTRAINT jobs_hours_req_chk
    CHECK (status <> 'C' OR hours IS NOT NULL);
