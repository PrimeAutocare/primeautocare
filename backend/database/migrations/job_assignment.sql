-- =====================================================
-- File:        job_assignment.sql
-- Purpose:     Creates the JOB_ASSIGNMENT table for PrimeAutocare
-- Depends on:  employee.sql, job.sql, vehicle_visit.sql
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS JOB_ASSIGNMENT CASCADE;

CREATE TABLE JOB_ASSIGNMENT (
    jobassign_id          INTEGER      CONSTRAINT job_assignment_pk PRIMARY KEY,
    visit_id              INTEGER      NOT NULL,
    job_no                INTEGER      NOT NULL,
    jobassign_assigned_by INTEGER      NOT NULL,
    jobassign_assign_dt   DATE         NOT NULL,
    jobassign_start_dt    DATE,
    jobassign_complete_dt DATE,
    jobassign_status      CHAR(1)      NOT NULL,
    jobassign_cost        NUMERIC(9, 2),
    jobassign_notes       VARCHAR(100)
);

COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_id          IS 'Unique job assignment identifier';
COMMENT ON COLUMN JOB_ASSIGNMENT.visit_id              IS 'Reference to the VEHICLE_VISIT this assignment belongs to';
COMMENT ON COLUMN JOB_ASSIGNMENT.job_no                IS 'Reference to the JOB type being performed';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_assigned_by IS 'emp_no of the employee who created this assignment';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_assign_dt   IS 'Date the job was assigned';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_start_dt    IS 'Date work started; NULL until the technician begins';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_complete_dt IS 'Date work was completed; NULL until finished';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_status      IS 'Status code: P = Pending/Not yet started, I = In-progress, C = Completed, X = Cancelled';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_cost        IS 'Cost charged for this assignment; NULL until finalised';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_notes       IS 'Optional free-text notes on the assignment';

ALTER TABLE JOB_ASSIGNMENT
    ADD CONSTRAINT vehicle_visit_job_assignment_fk
        FOREIGN KEY (visit_id) REFERENCES VEHICLE_VISIT (visit_id);

ALTER TABLE JOB_ASSIGNMENT
    ADD CONSTRAINT job_job_assignment_fk
        FOREIGN KEY (job_no) REFERENCES JOB (job_no);

ALTER TABLE JOB_ASSIGNMENT
    ADD CONSTRAINT employee_job_assignment_fk
        FOREIGN KEY (jobassign_assigned_by) REFERENCES EMPLOYEE (emp_no);

ALTER TABLE JOB_ASSIGNMENT
    ADD CONSTRAINT jobassign_status_chk CHECK (jobassign_status IN ('P', 'I', 'C', 'X'));