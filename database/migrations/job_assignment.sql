-- =====================================================
-- File:        job_assignment.sql
-- Purpose:     Creates the JOB_ASSIGNMENT table for PrimeAutocare
-- Depends on:  VEHICLE_VISIT, JOB, EMPLOYEE
-- Author:      Senuka Wijerathna
-- Created:     2026-07-01
-- =====================================================

DROP TABLE IF EXISTS JOB_ASSIGNMENT CASCADE;
DROP SEQUENCE IF EXISTS job_assignment_seq CASCADE;
CREATE SEQUENCE job_assignment_seq;
CREATE TABLE JOB_ASSIGNMENT (
    jobassign_id          VARCHAR(6)   CONSTRAINT job_assignment_pk PRIMARY KEY
                                       DEFAULT 'JA' || LPAD(NEXTVAL('job_assignment_seq')::TEXT, 4, '0'),
    visit_id              VARCHAR(6)   NOT NULL,
    job_no                VARCHAR(6)   NOT NULL,
    jobassign_assigned_by VARCHAR(6)   NOT NULL,
    jobassign_performed_by VARCHAR(6),
    jobassign_hours       NUMERIC(5, 2),
    jobassign_assign_dt   DATE         NOT NULL,
    jobassign_start_dt    DATE,
    jobassign_complete_dt DATE,
    jobassign_status      CHAR(1)      NOT NULL,
    jobassign_cost        NUMERIC(9, 2),
    jobassign_notes       VARCHAR(100)
);
ALTER SEQUENCE job_assignment_seq OWNED BY JOB_ASSIGNMENT.jobassign_id;
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_id          IS 'Unique job assignment code — JA + 4 digits (e.g. JA0001)';
COMMENT ON COLUMN JOB_ASSIGNMENT.visit_id              IS 'Reference to the VEHICLE_VISIT this assignment belongs to';
COMMENT ON COLUMN JOB_ASSIGNMENT.job_no                IS 'Reference to the JOB type being performed';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_assigned_by IS 'emp_no of the employee who created this assignment';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_performed_by IS 'emp_no of the technician who carried out the work; NULL until work starts';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_hours IS 'Labour hours logged against this assignment; basis for utilization and payroll';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_assign_dt   IS 'Date the job was assigned';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_start_dt    IS 'Date work started; NULL until the technician begins';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_complete_dt IS 'Date work was completed; NULL until finished';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_status      IS 'Status code: P = Pending/Not yet started, I = In-progress, C = Completed, X = Cancelled';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_cost        IS 'Cost charged for this assignment; NULL until finalised';
COMMENT ON COLUMN JOB_ASSIGNMENT.jobassign_notes       IS 'Optional free-text notes on the assignment';
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT vehicle_visit_job_assignment_fk FOREIGN KEY (visit_id) REFERENCES VEHICLE_VISIT (visit_id);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT job_job_assignment_fk FOREIGN KEY (job_no) REFERENCES JOB (job_no);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT employee_job_assignment_fk FOREIGN KEY (jobassign_assigned_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT performer_job_assignment_fk FOREIGN KEY (jobassign_performed_by) REFERENCES EMPLOYEE (emp_no);
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_status_chk CHECK (jobassign_status IN ('P', 'I', 'C', 'X'));
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_id_fmt_chk CHECK (jobassign_id ~ '^JA[0-9]{4}$');
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_hours_chk CHECK (jobassign_hours IS NULL OR jobassign_hours > 0);
-- Work that has started or finished must name the technician who did it,
-- otherwise utilization silently under-reports.
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_performer_req_chk
    CHECK (jobassign_status NOT IN ('I', 'C') OR jobassign_performed_by IS NOT NULL);
-- Completed work must have logged hours, otherwise payroll silently under-pays.
ALTER TABLE JOB_ASSIGNMENT ADD CONSTRAINT jobassign_hours_req_chk
    CHECK (jobassign_status <> 'C' OR jobassign_hours IS NOT NULL);
